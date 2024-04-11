#!/bin/sh

# Run socat for access to win-gpg-agent
#
# This script starts a background socat process to listen for SSH agent
# requests on a unix-domain socket, forwarding requests to win-gpg-agent
# through its sorelay.exe.
#
# Meant to be invoked from .zprofile on WSL2.  If socat is already running,
# this script is a no-op.
#
# (Normally I'd use sytemd sockets to handle this sort of startup logic, but
# WSL2 distributions don't run systemd by default.)
#
# TODO: Consider migrating to U2F keys now that win-gpg-agent is no longer
# maintained.
# https://blog.dan.drown.org/u2f-fido2-based-ssh-keys-on-windows/

set -e
set -o noclobber

# Path at which to create the listening socket.
SOCKET="$HOME/.gnupg/S.gpg-agent.ssh"

# File containing socat's pid, if it's running.
PIDFILE=/tmp/sorelay.pid

# For prevening concurrent sorelay startup sequences.
LOCKFILE=/tmp/sorelay-startup.lock

script=$(realpath $0)
is_child=$1

cleanup() {
	if [ ! -z "$LOCKFILE" ]; then
		rm "$LOCKFILE"
	fi
}

# Launch a new instance of this script in dedicated session so it doesn't exit
# if we close our terminal.
if [ -z "$is_child" ]; then
	# noclobber will fail this if the file already exists.
	echo $$ >"$LOCKFILE"

	setsid -f "$script" 1
	exit
else
	trap cleanup EXIT
fi

if [ -f "$PIDFILE" ]; then
	if pgrep -F "$PIDFILE" >/dev/null 2>&1; then
		exit
	else
		rm "$PIDFILE"
	fi
fi

echo "Starting socat" >&2
rm -f $SOCKET
socat UNIX-LISTEN:$SOCKET,fork 'EXEC:/mnt/c/Program\\ Files/win-gpg-agent/sorelay.exe c\:/Users/mshroyer/AppData/Local/gnupg/agent-gui/S.gpg-agent.ssh,nofork' >/dev/null 2>&1 &

echo $! >"$PIDFILE"
rm "$LOCKFILE"

# Unset LOCKFILE to disarm the EXIT trap, in case another invocation happens
# concurrently after this point.
LOCKFILE=

wait $(cat "$PIDFILE")
echo "Removing $PIDFILE" >&2
rm "$PIDFILE"
