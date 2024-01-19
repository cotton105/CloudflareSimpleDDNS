#!/bin/sh
version=$(cat version)

COPYFILE_DISABLE=true tar -czv --owner=0 --group=0 --exclude-vcs-ignores --exclude-vcs --exclude package.sh -f "auto-dns-update-$version.tar.gz" .
