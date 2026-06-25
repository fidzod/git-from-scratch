package object_store

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
