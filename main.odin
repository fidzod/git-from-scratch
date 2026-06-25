package main

import "core:fmt"
import "object_store"

main :: proc() {
  root_tree_hash, ok := object_store.write_directory_tree("./test_project")
  root_tree_hash_str := object_store.hash_to_hex(root_tree_hash)
  defer delete(root_tree_hash_str)
  fmt.println(root_tree_hash_str)
  return
}
