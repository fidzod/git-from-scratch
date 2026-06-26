package main

import "core:os"
import "cli"

main :: proc() {
  cli.run(os.args)
	return
}
