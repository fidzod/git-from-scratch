package object_store

write_blob :: proc(data: []u8) -> (Hash, bool) {
  return write_object(.Blob, data)
}

