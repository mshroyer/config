#!/bin/sh

# Mounts my home directory on pilgrim, on Linux.  May require cifs-utils to be
# installed first.

set -e

local mountpoint="$HOME/h"

if [ ! -d "$mountpoint" ]; then
	mkdir "$mountpoint"
fi

sudo mount -t cifs -o username=$(whoami),uid=$(id -u),gid=$(id -g) \
      //pilgrim.homestarmy.net/$(whoami) "$mountpoint"
