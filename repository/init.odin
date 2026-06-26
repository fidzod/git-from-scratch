package repository

import "core:fmt"
import "core:os"

init :: proc() -> bool {
	if os.is_dir(".gitfs") {
		fmt.eprintln("error in init: .gitfs dir already exists")
		return false
	}

	if !_create_directory(".gitfs") do return false
	if !_create_file(".gitfs" + "/" + "HEAD", "ref: refs/heads/main") do return false
	if !_create_directory(".gitfs" + "/" + "refs") do return false

  heads_path :: ".gitfs" + "/" + "refs" + "/" + "heads"
	if !_create_directory(heads_path) do return false
	if !_create_file(heads_path + "/" + "main") do return false

	if !_create_directory(".gitfs" + "/" + "objects") do return false

	return true
}
