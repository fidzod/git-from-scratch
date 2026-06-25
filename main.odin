package main

import "core:strings"
import "core:fmt"
import "object_store"

main :: proc() {
  data_str := "Hello World"
  hash, write_ok := object_store.write_blob(transmute([]u8)data_str)

  hash_str := object_store.hash_to_hex(hash)
  defer delete(hash_str)
  if write_ok do fmt.println("wrote:", hash_str)

  read_data, read_ok := object_store.read_object(hash)
  defer delete(read_data)
  read_data_str := strings.string_from_ptr(&read_data[0], len(read_data))
  fmt.println("read:", read_data_str)

  return
}
