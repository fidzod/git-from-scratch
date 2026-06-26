package cli

import "../repository"
import "core:fmt"
import "core:os"

USAGE_STR :: `
Usage: gitfs <command> [options]

Commands:
  init              Initialise a new repository
  commit <message>  Create a commit with the given message
  log               Display commit history
  checkout <hash>   Switch to a specific commit by hash

Examples:
  gitfs init
  gitfs commit "Initial commit"
  gitfs log
  gitfs checkout abc123def
`

run :: proc(args: []string) {
	usage :: proc() {
		fmt.eprintln(USAGE_STR)
		os.exit(1)
	}

	if len(args) == 1 do usage()

	switch args[1] {
	case "init":
		ok := repository.init()
		if !ok {
			fmt.eprintln("Failed to initialise a new repository")
			return
		}
		fmt.println("Initialised a new repository")
		break
	case "commit":
		commit_hash, ok := repository.commit(args[2])
		defer delete(commit_hash)
		if !ok {
			fmt.eprintln("Failed to create commit")
			return
		}
		fmt.println("Commit:", commit_hash)
		break
	case "log":
		repository.log()
		break
	case:
		fmt.eprintfln("Unrecognised command: %s", args[1])
		usage()
		break
	}
	return
}
