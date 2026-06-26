package repository

import "../object_store"

load_commit :: proc(hash: object_store.Hash) -> (object_store.Commit, bool) {
	data, read_ok := object_store.read_object(hash)
	if !read_ok do return {}, false
	defer delete(data)

	obj, parse1_ok := object_store.parse_object(data)
	if !parse1_ok do return {}, false
	defer delete(obj.payload)

	commit, parse2_ok := object_store.parse_commit(obj.payload)
	if !parse2_ok do return {}, false
	return commit, true
}

commit :: proc(message: string) -> (string, bool) {
	root_tree_hash, ok1 := object_store.write_directory_tree("./test_project")
	if !ok1 do return "", false
	head_ref, _ := read_head()
	defer delete(head_ref)
	parent_hash, has_parent := read_ref(head_ref)

	commit := object_store.Commit {
		tree    = root_tree_hash,
		orphan  = !has_parent,
		parent  = parent_hash,
		message = message,
	}

	commit_hash, ok2 := object_store.write_commit(commit)
	if !ok2 do return "", false

	write_ref(head_ref, commit_hash)

	commit_hash_str := object_store.hash_to_hex(commit_hash)
	return commit_hash_str, true
}
