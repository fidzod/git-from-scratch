package main

// import "object_store"
import "repository"

main :: proc() {
  /* repository.init()

  root_tree_hash, _ := object_store.write_directory_tree("./test_project")

  parent_hash, _ := object_store.hash_from_hex("0bef5e2b86ddb3fdff06c4118575eaa76866294a")
  commit := object_store.Commit{
    tree = root_tree_hash,
    orphan = false,
    parent = parent_hash,
    message = "Update README.",
  }

  commit_hash, _ := object_store.write_commit(commit)

  head_ref, _ := repository.read_head()
  defer delete(head_ref)
  repository.write_ref(head_ref, commit_hash)
  */
  repository.log()

	return
}
