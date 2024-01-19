#!/bin/sh
COPYFILE_DISABLE=true tar -c --zstd --exclude-vcs-ignores --exclude-vcs --exclude package.sh -f auto-dns-update.tar.zd .
