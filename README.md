# Gitfs
A version control system implemented from scratch in Odin to explore how Git
works under the hood.

Gitfs is an educational project that recreates Git's core architecture from
first principles, starting with a content-addressed object database and
gradually building up higher-level repository operations. Rather than aiming to
be a production-ready replacement for Git, the focus is on understanding the
design decisions that make Git fast, reliable and elegant.

Current implementation includes:

- Content-addressed immutable object database

- Blob, tree and commit objects

- Repository references (`HEAD` and branches)

- Recursive directory snapshots

- Commit history (`log`)

- A simple command-line interface

The project is being developed incrementally, this is reflected in the commit
history. I plan to write a blog post documenting the journey and the
architectural decisions made along the way.

## Architecture

The implementation is organised into clean layers:

```text
        CLI
         ↓
Repository Operations
         ↓
    Object Store
         ↓
    File System
```

The object store is responsible exclusively for reading and writing immutable
Git objects. Higher-level repository operations such as commits and history are
built by composing these primatives. Each layer is a self-contained package.
