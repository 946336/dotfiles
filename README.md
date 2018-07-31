# Dotfiles

This repository may contain some of my own configuration files. Unless you
want them, you should fork this repository. This script makes no effort to be
race-condition free.

I assume that the act of deploying configuration is idempotent. Thus, a
failure at one step of the process need not require a full rollback and in
particular, may be fixed by simply fixing the installation procedure and
trying again.

## Structure

This repository contains scattered, free-form configurations of arbitrary
format and complexity. Each set of configurations is located in its own
directory at the top level of this repository and must provide its own
executable installation/update script called `dotfile-install.sh`

If installation is simply copying or symlinking a location to a dotfile or
directory in this repository, it is permissible to provide in the place of
`dotfile-install.sh` a readable rules file `dotfile-links.txt` or
`dotfile-copy.txt` listing the places that pieces configuration must be
liked/copied to.

Installation instructions are tested for in the following order:

1. `dotfile-links.txt`
2. `dotfile-copy.txt`
3. `dotfile-install.sh`

## Rules Files (`dotfile-links.txt` and `dotfile-copy.txt`)

Rules files are comprised of lines that are either comments ( lines beginning
with \# ) or rules stating where to place the files and/or directories
provided.

Rules have the following format:

    { Destination } | { Configuration }

`Destination` should be an absolute path, but may contain `~`.

`Configuration` should be a path relative to the Rules file.

## `dotfile-install.sh`

If `dotfile-install.sh` begins with a shebang, it will be run respecting the
shebang. Otherwise, it is run by `sh`.

`dotfile-install.sh` is executed from within its directory.

When the tool is invoked with `--upgrade`, the environment variable
`DOTFILE_UPGRADE` is set to `1`.

When the tool is invoked with `--verbose`, the environment variable
`DOTFILE_VERBOSE` is set to `1`.

If `dotfile-install.sh` exits with a nonzero return value,
`dotfile-rollback.sh` is invoked in the same manner that `dotfile-install.sh`
was. An error is reported regardless.

