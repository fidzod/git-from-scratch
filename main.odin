package main

import "object_store"
import "repository"

main :: proc() {
	head, _ := object_store.hash_from_hex("5665a4fbcad978cff66b315912c80ffa9f3606a1")

	repository.log(head)

	return
}
