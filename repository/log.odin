package repository

import "../object_store"
import "core:fmt"

log :: proc() {
  head_ref, _ := read_head()
  defer delete(head_ref)
  current, _ := read_ref(head_ref)
	for {
		commit, _ := load_commit(current)
		defer delete(commit.message)
    hex_str := object_store.hash_to_hex(current)
    defer delete(hex_str)
		fmt.println(hex_str[:6], commit.message)
		if commit.orphan do break
		current = commit.parent
	}
}
