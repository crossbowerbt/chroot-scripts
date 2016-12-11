#!/bin/bash

#
# Extracts from a strace log the list of files successfully opened.
# These files can be copied in the chroot base directory.
#
# You must already have a log file. You can obtain one with:
# $ strace command_and_options 2>log.strace
# 
# Usage: strace_log_open_files.sh <strace_log_file>
#

set -e

logfile="$1"

prefixes_to_mark=(
	/dev/
	/proc/
	/sys/
)

function mark_prefix {

	# this functions marks problematic file prefixes
	# (e.g. files in virtual filesystems)

	local expr=`echo "^(${prefixes_to_mark[@]})" | tr ' ' '|'`

	while read line; do
		if echo "$line" | egrep "$expr" > /dev/null; then
			echo "!$line"
		else
			echo "$line"
		fi
	done
}

cat "$logfile"             |
	egrep '^open\('    | # select open syscalls
	grep -v ' -1 '     | # exclude open failures
	egrep -o '"[^"]+"' | # get first argument (filie path)
	tr -d '"'          | # delete quote marks
	sort               | # reorder files
	uniq               | # delete duplicates
	mark_prefix        | # mark problematic files
	sort               | # re-sort for problematic files
	cat
