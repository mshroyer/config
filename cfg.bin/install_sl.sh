#!/bin/sh

# Install Sapling from my latest RPM build on GitHub.

set -e

REPO="mshroyer/sapling-builds"

run_id="$(gh api "repos/${REPO}/actions/runs" \
	     --paginate -q \
	     '[ .workflow_runs
			     | sort_by(.created_at)
			     | reverse
			     | .[]
			     | select(.name=="sapling")
			     | select(.conclusion=="success") ]
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
find "$tempdir" -type f | xargs sudo dnf install
