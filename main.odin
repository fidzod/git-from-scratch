package main

import "core:fmt"
import "object_store"

main :: proc() {
  data_string := "Hello World"
  hash, ok := object_store.write_blob(transmute([]u8)data_string)

  hash_str := object_store.hash_to_hex(hash)
  defer delete(hash_str)
  if ok do fmt.println(hash_str)

  return
}
