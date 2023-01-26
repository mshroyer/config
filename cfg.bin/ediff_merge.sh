#!/bin/sh

set -e

in_local="$(realpath $1)"
in_other="$(realpath $2)"
in_base="$(realpath $3)"
out="$(realpath $4)"

emacsclient -c -nw --alternate-editor=emacs -q --eval \
	    "(ediff-merge-with-ancestor \""$in_local"\" \""$in_other"\" \""$in_base"\" nil \""$out"\")"
