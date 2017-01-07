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

# create destination directory
mkdir -p "$rootdir/$destdir"

# set destination directory permissions and ownership
chown --reference="$destdir" "$rootdir/$destdir"
chmod --reference="$destdir" "$rootdir/$destdir"

# if file already exists do not copy
if [ -e "$rootdir/$curfile" ]; then
	exit 0
fi

# is directory?
if [ -d "$curfile" ]; then

	# copy files recursively

	for f in "$curfile"/.* "$curfile"/*; do

		if [ "$f" != "." ] && [ "$f" != ".." ]; then
			$0 "$f" "$rootdir" || true
		fi
		
	done

# is symbolic link?
elif [ -L "$curfile" ]; then

	cp -vp "$curfile" "$rootdir/$curfile"

	# get next link in chain, with canonical path
	
	pushd `dirname "$curfile"` > /dev/null
	origfile=`readlink "$curfile"`
	origfile=`realpath -s "$origfile"`
	popd > /dev/null
	
	$0 "$origfile" "$rootdir" || true

# if regular file, try to copy libraries
elif [ -f "$curfile" ]; then

	cp -vp "$curfile" "$rootdir/$curfile"

	# get shared libraries

	libraries=`ldd "$curfile" | egrep -o '/[^ ]+'`

	for library in $libraries; do
		$0 "$library" "$rootdir" || true
	done

fi

