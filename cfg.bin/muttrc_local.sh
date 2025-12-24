#!/bin/sh

# Emit a local mutt configuration, if present.
#
# This allows us to include an optional ~/.muttrc.local file from our
# checked-in ~/.muttrc, without throwing an error if it doesn't exist.

set -e

if [ -f "$HOME/.muttrc.local" ]; then
	cat "$HOME/.muttrc.local"
fi
