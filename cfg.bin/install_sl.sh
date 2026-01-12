#!/bin/sh

# Install Sapling from my latest RPM build on GitHub.

set -e

if [ "$(uname -s)" != "Linux" ]; then
	echo "Not supported on non-Linux operating systems" >&2
	exit 1
fi

. /etc/os-release
if [ "$PLATFORM_ID" != "platform:el10" ]; then
	echo "Only supported on el10" >&2
	exit 1
fi

REPO="mshroyer/sapling-builds"

run_id="$(gh api "repos/${REPO}/actions/runs" \
	     --paginate --slurp \
	     | jq '[ .[].workflow_runs[]
			     | select(.name=="sapling")
			     | select(.conclusion=="success") ]
			     | sort_by(.created_at)
			     | reverse
			     | .[0]
			     | .id')"

echo "Fetching artifacts from sapling run ${run_id}"
echo "https://github.com/${REPO}/actions/runs/${run_id}/"

tempdir="$(mktemp -d)"
cleanup_tempdir() {
	rm -rf "$tempdir"
}
trap cleanup_tempdir INT TERM EXIT

gh run download "$run_id" --repo "$REPO" --dir "$tempdir"
find "$tempdir" -type f -name '*.rpm' | xargs sudo dnf install -y
