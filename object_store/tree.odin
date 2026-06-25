package object_store

import "core:bytes"

Tree_Entry :: struct {
  name: string,
  hash: Hash
}

serialise_tree :: proc(entries: []Tree_Entry) -> []u8 {
  tree := make([dynamic]u8)
  for entry in entries {
    append(&tree, ..transmute([]u8)entry.name)
    append(&tree, ' ')
    hash_str := hash_to_hex(entry.hash)
    defer delete(hash_str)
    append(&tree, ..transmute([]u8)hash_str)
    append(&tree, '\n')
  }
  return tree[:]
}

write_tree :: proc(entries: []Tree_Entry) -> (Hash, bool) {
  payload := serialise_tree(entries)
  defer delete(payload)
  return write_object(.Tree, payload)
}

parse_tree :: proc(payload: []u8) -> ([]Tree_Entry, bool) {
  entries := make([dynamic]Tree_Entry)
  rows := bytes.split(payload, {'\n'})
  defer delete(rows)

  for row in rows {
    parts : = bytes.split(row, {' '})
    defer delete(parts)
    if len(row) == 0 do continue
    if len(parts) != 2 do return {}, false

    hash, ok := hash_from_hex(string(parts[1]))
    if !ok do return {}, false

    entry := Tree_Entry{
      name = string(parts[0]),
      hash = hash
    }
    append(&entries, entry)
  }

  return entries[:], true
}
