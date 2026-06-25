package main

import "core:fmt"
import "object_store"

main :: proc() {
  data_str := "Hello World"
  hash, write_ok := object_store.write_blob(transmute([]u8)data_str)

  hash_str := object_store.hash_to_hex(hash)
  defer delete(hash_str)
  if write_ok do fmt.println(hash_str)

  read_data, read_ok := object_store.read_object(hash)
  defer delete(read_data)

  parsed_object, parse_ok := object_store.parse_object(read_data)
  defer object_store.destroy_object(parsed_object)
  fmt.println("kind:", parsed_object.kind)
  fmt.println("payload:", string(parsed_object.payload))

  return
}
