#!/bin/sh

# Installs or updates the AWS CLI v2
#
# Currently only supports Linux x86_64

set -e

if [ "$(uname)" != "Linux" ]; then
	echo "Only supported on Linux" >&1
	exit 1
fi

if [ "$(uname -p)" != "x86_64" ]; then
	echo "Only supported on x86_64" >&1
	exit 1
fi

cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
if [ -f /usr/local/bin/aws ]; then
	sudo ./aws/install --update
else
	sudo ./aws/install
fi
rm -rf aws awscliv2.zip
