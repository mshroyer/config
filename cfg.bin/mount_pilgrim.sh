#!/bin/sh

# Mounts my home directory on pilgrim.  On Linux, this may require cifs-utils
# to be installed first.

set -e

function mount_linux() {
	local mountpoint="$HOME/h"

	if [ ! -d "$mountpoint" ]; then
		mkdir "$mountpoint"
	fi

	sudo mount -t cifs -o username=$(whoami),uid=$(id -u),gid=$(id -g) \
	     //pilgrim.homestarmy.net/$(whoami) "$mountpoint"
}

function mount_macos() {
	local mountpoint="$HOME/h"

	# Take advantage of Keychain password caching.
	echo "mount volume \"smb://pilgrim.homestarmy.net/$(whoami)\"" \
		| /usr/bin/osascript

	if [ ! -e "$mountpoint" ]; then
		ln -s "/Volumes/$(whoami)" "$mountpoint"
	fi
}

if [ "$(uname)" = "Linux" ]; then
	mount_linux
elif [ "$(uname)" = "Darwin" ]; then
	mount_macos
else
	echo "Unsupported on $(uname)" >&1
	exit 1
fi
