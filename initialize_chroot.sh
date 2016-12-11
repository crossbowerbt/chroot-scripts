#!/bin/sh

#
# Initialized a directory to be used 
# as a skelethon for a chrooted environment.
#
# Run as root.
#
# Usage: initialize_chroot.sh <directory>
#

set -e

rootdir="$1"

subdirs=(
	dev etc proc sys tmp

	bin sbin
	lib lib64

	usr/bin
	usr/lib
	usr/lib64

	var/run
	var/log
	var/lib
)

# create root directory if it doesn't exists
mkdir -p "$rootdir"

# create subdirectories
for subdir in "${subdirs[@]}"; do
	mkdir -p "$rootdir/$subdir"
done

# set permissions for certain subdirectories
chmod 1777 "$rootdir/tmp"

