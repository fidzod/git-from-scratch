package repository

import "../object_store"

load_commit :: proc(hash: object_store.Hash) -> (object_store.Commit, bool) {
  data, read_ok := object_store.read_object(hash)
  if !read_ok do return {}, false
  defer delete(data)

  obj, parse1_ok := object_store.parse_object(data)
  if !parse1_ok do return {}, false
  defer delete(obj.payload)

  commit, parse2_ok := object_store.parse_commit(obj.payload)
  if !parse2_ok do return {}, false
  return commit, true
}
