package main

import "core:fmt"
import "object_store"

main :: proc() {
  root_tree_hash, _ := object_store.write_directory_tree("./test_project")
  root_tree_hash_str := object_store.hash_to_hex(root_tree_hash)
  defer delete(root_tree_hash_str)
  fmt.println(root_tree_hash_str)

  commit := object_store.Commit{
    tree = root_tree_hash,
    orphan = true,
    message = "Initial commit.",
  }

  commit_hash, _ := object_store.write_commit(commit)
  commit_hash_str := object_store.hash_to_hex(commit_hash)
  defer delete(commit_hash_str)
  fmt.println(commit_hash_str)

  data, _ := object_store.read_object(commit_hash)
  defer delete(data)
  obj, _ := object_store.parse_object(data)
  defer delete(obj.payload)

  parsed_commit, _ := object_store.parse_commit(obj.payload)
  defer delete(parsed_commit.message)

  assert(parsed_commit.tree == root_tree_hash)
  assert(parsed_commit.message == "Initial commit.")
  return
}
