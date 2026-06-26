package repository

import "../object_store"
import "core:fmt"

log :: proc(head: object_store.Hash) {
	current := head
	for {
		commit, _ := load_commit(current)
		defer delete(commit.message)
		fmt.println(commit.message)
		if commit.orphan do break
		current = commit.parent
	}
}
