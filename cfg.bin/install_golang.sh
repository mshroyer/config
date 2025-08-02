#!/bin/sh

# Install or update to the latest version of Go for Linux

set -e

INSTALL=/usr/local

installed_version=none
if [ -x "$INSTALL/go/bin/go" ]; then
	installed_version="$("$INSTALL"/go/bin/go version | awk '{ print $3; }')"
fi
latest_version=$(curl -sL 'https://golang.org/VERSION?m=text' | head -n1)

if [ $latest_version = $installed_version ]; then
	echo "Already have latest version $latest_version."
	exit 0
fi
echo "Currently installed: $installed_version"
echo "Installing:          $latest_version"

curl -L -o /tmp/go.tar.gz "https://golang.org/dl/${latest_version}.linux-amd64.tar.gz"

sudo rm -rf "$INSTALL/go"
sudo tar -C "$INSTALL" -xzf /tmp/go.tar.gz
