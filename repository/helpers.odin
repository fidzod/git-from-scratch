#+private
package repository

import "core:os"

_create_file :: proc(path: string, contents: string = "") -> bool {
  file, os_err1 := os.create(path)
  if os_err1 != os.ERROR_NONE do return false
  defer os.close(file)
  _, os_err2 := os.write_string(file, contents)
  if os_err2 != os.ERROR_NONE do return false
  return true
}

_create_directory :: proc(path: string) -> bool {
  os_err := os.make_directory(path)
  if os_err != os.ERROR_NONE do return false
  return true
}
