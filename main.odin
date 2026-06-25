package main

import "core:fmt"
import "object_store"

main :: proc() {
  readme_hash, _ := object_store.write_blob(transmute([]u8)string("Hello"))
  main_hash, _ := object_store.write_blob(transmute([]u8)string("main :: proc() {}"))

  entries := []object_store.Tree_Entry{
    {
      name = "README.md",
      hash = readme_hash,
    },
    {
      name = "main.odin",
      hash = main_hash
    },
  }

  tree_hash, write_ok := object_store.write_tree(entries)
  tree_data, read_ok := object_store.read_object(tree_hash)
  defer delete(tree_data)
  obj, _ := object_store.parse_object(tree_data)
  defer object_store.destroy_object(obj)
  parsed_entries, parse_ok := object_store.parse_tree(obj.payload)
  defer delete(parsed_entries)

  hash0 := object_store.hash_to_hex(parsed_entries[0].hash)
  defer delete(hash0)
  hash1 := object_store.hash_to_hex(parsed_entries[1].hash)
  defer delete(hash1)
  fmt.println(parsed_entries[0].name, hash0)
  fmt.println(parsed_entries[1].name, hash1)

  return
}
