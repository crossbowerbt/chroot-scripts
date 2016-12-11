#!/bin/bash

#
# Utility that recursively copies a program
# and its library dependencies inside a directory
# to be used as a chroot base.
#
# Run as root. you must provide the complete path for
# the file to be copied.
#
# Usage: recursive_ldd.sh <file_path> <directory> 
#

set -e

curfile="$1"
rootdir="$2"

destdir=`dirname "$curfile"`

# copy file
mkdir -p "$rootdir/$destdir"
cp -rvp "$curfile" "$rootdir/$curfile"

# is symbolic link?
if [ -L "$curfile" ]; then

	origfile=`readlink -f "$curfile"`
	$0 "$origfile" "$rootdir"

# copy libraries
else

	libraries=`ldd "$curfile" | egrep -o '/[^ ]+'`

	for library in $libraries; do
		$0 "$library" "$rootdir"
	done

fi

