package object_store

import "core:bytes"
import "core:os"
import "core:slice"

Tree_Entry :: struct {
	name: string,
	hash: Hash,
}

Tree :: []Tree_Entry

serialise_tree :: proc(entries: Tree) -> []u8 {
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

write_tree :: proc(entries: Tree) -> (Hash, bool) {
	slice.sort_by(entries[:], proc(a, b: Tree_Entry) -> bool {
		return a.name < b.name
	})
	payload := serialise_tree(entries)
	defer delete(payload)
	return write_object(.Tree, payload)
}

parse_tree :: proc(payload: []u8) -> (Tree, bool) {
	entries := make([dynamic]Tree_Entry)
	rows := bytes.split(payload, {'\n'})
	defer delete(rows)

	for row in rows {
		parts := bytes.split(row, {' '})
		defer delete(parts)
		if len(row) == 0 do continue
		if len(parts) != 2 do return {}, false

		hash, ok := hash_from_hex(string(parts[1]))
		if !ok do return {}, false

		entry := Tree_Entry {
			name = string(parts[0]),
			hash = hash,
		}
		append(&entries, entry)
	}

	return entries[:], true
}

write_directory_tree :: proc(path: string) -> (Hash, bool) {
	if !os.is_dir(path) do return {}, false
	dir_entries, os_err := os.read_directory_by_path(path, -1, context.allocator)
	if os_err != os.ERROR_NONE do return {}, false

	defer {
		for entry in dir_entries do delete(entry.fullpath)
		delete(dir_entries)
	}

	tree_entries := make([dynamic]Tree_Entry)
	defer delete(tree_entries)
	for entry in dir_entries {
		if entry.name == ".gitfs" || entry.name == ".git" do continue
		entry_hash: Hash; write_ok: bool
		if os.is_dir(entry.fullpath) {
			entry_hash, write_ok = write_directory_tree(entry.fullpath)
			if !write_ok do return {}, false
		} else {
			contents, os_err := os.read_entire_file_from_path(entry.fullpath, context.allocator)
			if os_err != os.ERROR_NONE do return {}, false
			defer delete(contents)
			entry_hash, write_ok = write_blob(contents)
			if !write_ok do return {}, false
		}
		entry := Tree_Entry {
			name = entry.name,
			hash = entry_hash,
		}
		append(&tree_entries, entry)
	}

	tree_hash, ok := write_tree(tree_entries[:])
	if !ok do return {}, false

	return tree_hash, true
}
