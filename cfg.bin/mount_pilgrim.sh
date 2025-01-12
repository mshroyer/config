#!/bin/sh

# Mounts my home directory on pilgrim, on Linux.  May require cifs-utils to be
# installed first.

set -e

if [ ! -d "$HOME/h" ]; then
	mkdir "$HOME/h"
fi

sudo mount -t cifs -o username=$(whoami),uid=$(id -u),gid=$(id -g) \
      //pilgrim.homestarmy.net/$(whoami) "$HOME/h"
