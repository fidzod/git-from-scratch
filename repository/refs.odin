package repository

import "../object_store"
import "core:bytes"
import "core:os"
import "core:strings"

read_head :: proc() -> (string, bool) {
	data, os_err := os.read_entire_file_from_path(".gitfs" + "/" + "HEAD", context.allocator)
	if os_err != os.ERROR_NONE do return "", false
	defer delete(data)

	parts := bytes.split(data, {' '})
	defer delete(parts)
	if len(parts) != 2 do return "", false
	if string(parts[0]) != "ref:" do return "", false
	ref := bytes.clone(parts[1])
	return string(ref), true
}

write_head :: proc() {}

read_ref :: proc(path: string) -> (object_store.Hash, bool) {
	full_path := strings.concatenate({".gitfs", "/", path})
	defer delete(full_path)
	data, os_err := os.read_entire_file_from_path(full_path, context.allocator)
	if os_err != os.ERROR_NONE do return {}, false
	defer delete(data)
	if len(data) == 0 do return {}, false
	commit_hash, ok := object_store.hash_from_hex(string(data))
	if !ok do return {}, false
	return commit_hash, true
}

write_ref :: proc(ref: string, commit_hash: object_store.Hash) -> bool {
	full_path := strings.concatenate({".gitfs", "/", ref})
	defer delete(full_path)
	commit_hash_str := object_store.hash_to_hex(commit_hash)
	defer delete(commit_hash_str)
	os_err := os.write_entire_file_from_string(full_path, commit_hash_str)
	if os_err != os.ERROR_NONE do return false
	return true
}

create_branch :: proc() {}
