package object_store

import "core:bytes"
import "core:fmt"

Commit :: struct {
	tree:    Hash,
	parent:  Hash,
	message: string,
	orphan:  bool,
}

serialise_commit :: proc(commit: Commit) -> []u8 {
	tree_str := hash_to_hex(commit.tree)
	defer delete(tree_str)

  if commit.orphan {
    content := fmt.tprintf("tree %s\nparent\n%s", tree_str, commit.message)
    return transmute([]u8)content
  }
  parent_str := hash_to_hex(commit.parent)
	defer delete(parent_str)

	content := fmt.tprintf("tree %s\nparent %s\n%s", tree_str, parent_str, commit.message)
	return transmute([]u8)content
}

write_commit :: proc(commit: Commit) -> (Hash, bool) {
	payload := serialise_commit(commit)
	defer delete(payload)
	return write_object(.Commit, payload)
}

parse_commit :: proc(payload: []u8) -> (Commit, bool) {
	rows := bytes.split(payload, {'\n'})
	defer delete(rows)

	if len(rows) < 3 do return {}, false

	message_bytes := make([dynamic]u8)
	for row in rows[2:] do append(&message_bytes, ..row)
	message := string(message_bytes[:])

	tree_parts := bytes.split(rows[0], {' '})
  defer delete(tree_parts)
	if len(tree_parts) != 2 do return {}, false
	if string(tree_parts[0]) != "tree" do return {}, false
	tree_hash, tree_hash_ok := hash_from_hex(string(tree_parts[1]))
  if !tree_hash_ok do return {}, false

	parent_parts := bytes.split(rows[1], {' '})
  defer delete(parent_parts)
	if len(parent_parts) == 1 {
		return {tree = tree_hash, orphan = true, message = message}, true
	}
	if len(parent_parts) > 2 do return {}, false
	if string(parent_parts[0]) != "parent" do return {}, false
	parent_hash, parent_hash_ok := hash_from_hex(string(parent_parts[1]))
  if !parent_hash_ok do return {}, false
	return {tree = tree_hash, parent = parent_hash, orphan = false, message = message}, true
}
