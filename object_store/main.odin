package object_store

import "core:strconv"
import "core:bytes"
import "core:os"
import "core:path/slashpath"
import "core:encoding/hex"
import "core:crypto/legacy/sha1"
import "core:fmt"

Hash :: [20]u8

Object_Type :: enum {
  Blob,
  Tree,
  Commit,
}

Object :: struct {
  kind: Object_Type,
  payload: []u8,
}

destroy_object :: proc(object: Object) {
  delete(object.payload)
}

write_object :: proc(kind: Object_Type, payload: []u8) -> (Hash, bool) {
  serialised := serialise_object(kind, payload)
  defer delete(serialised)
  hash := compute_hash(serialised)
  ok := store_object(hash, serialised)
  return hash, ok
}

write_blob :: proc(data: []u8) -> (Hash, bool) {
  return write_object(.Blob, data)
}

object_type_string :: proc(kind: Object_Type) -> string {
  switch kind {
  case .Blob:   return "blob"
  case .Tree:   return "tree"
  case .Commit: return "commit"
  }
  unreachable()
}

object_type_from_string :: proc(kind: string) -> Object_Type {
  switch kind {
  case "blob": return .Blob
  case "tree": return .Tree
  case "commit": return .Commit
  }
  unreachable()
}

serialise_object :: proc(kind: Object_Type, payload: []u8) -> []u8 {
  header := fmt.tprintf("%s %d\x00", object_type_string(kind), len(payload))
  header_as_bytes := transmute([]u8)header
  object := make([dynamic]u8)
  append(&object, ..header_as_bytes)
  append(&object, ..payload)
  return object[:]
}

compute_hash :: proc(data: []u8) -> Hash {
  ctx: sha1.Context
  sha1.init(&ctx)
  sha1.update(&ctx, data)
  hash : [sha1.DIGEST_SIZE]u8
  sha1.final(&ctx, hash[:])
  return hash
}

hash_to_hex :: proc(hash: Hash) -> string {
  hash_copy := hash
  encoded := hex.encode(hash_copy[:])
  return string(encoded[:])
}

object_path :: proc(hash: string) -> string {
  return fmt.tprintf(".gitfs/objects/%s/%s", hash[:2], hash[2:])
}

store_object :: proc(hash: Hash, data: []u8) -> bool {
  hash_string := hash_to_hex(hash)
  defer delete(hash_string)
  file_path := object_path(hash_string)
  parent_dir := slashpath.dir(file_path)
  defer delete(parent_dir)
  if os.exists(file_path) do return true
  if !os.is_dir(parent_dir) do os.make_directory(parent_dir)
  os_err := os.write_entire_file_from_bytes(file_path, data)
  if (os_err != os.ERROR_NONE) do return false
  return true
}

read_object :: proc(hash: Hash) -> ([]u8, bool) {
  hash_string := hash_to_hex(hash)
  defer delete(hash_string)
  file_path := object_path(hash_string)
  if !os.exists(file_path) do return {}, false
  data, os_err := os.read_entire_file_from_path(file_path, context.allocator)
  if (os_err != os.ERROR_NONE) do return {}, false
  return data, true
}

parse_object :: proc(data: []u8) -> (Object, bool) {
  parts := bytes.split(data[:], {'\x00'})
  defer delete(parts)
  if len(parts) != 2 do return {}, false

  header := bytes.split(parts[0], {' '})
  defer delete(header)
  if len(header) != 2 do return {}, false

  kind := string(header[0])
  data_sz, parse_sz_ok := strconv.parse_int(string(header[1]))
  if !parse_sz_ok do return {}, false

  payload := bytes.clone(parts[1])

  if len(payload) != data_sz do return {}, false

  return {
    kind = object_type_from_string(kind),
    payload = payload
  }, true
}

