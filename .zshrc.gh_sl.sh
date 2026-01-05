### Provides a `gh` wrapper to support .sl mode Sapling repos.

# Find the root directory of whatever source code repository the current
# directory is in, if any.
_repo_root() {
	(
		while [ "$PWD" != "/" ]; do
			if [ -d "$PWD/.git" ] || [ -d "$PWD/.sl" ]; then
				echo "$PWD"
				break
			fi
			cd ..
		done
	)
}

_gh_repo_from_url() {
	url="$1"
	path="${url#https://github.com/}"
	path="${path#git@github.com:}"

	if [ "$path" = "$url" ]; then
		# Didn't have a github prefix
		return
	fi
	path="${path%.git/}"
	path="${path%.git}"
	echo "$path"
}

# Get the GitHub repo name, if any, of a Sapling or git clone.
gh_repo_name() {
	repo="$(_repo_root)"
	if [ -z "$repo" ]; then
		return
	fi

	if [ -d "${repo}/.sl" ]; then
		default_path=
		default_path="$(cd "$repo" && sl config paths.default)" || {}
		repo="$(_gh_repo_from_url "$default_path")"
		echo "$repo"
	elif [ -d "${repo}/.git" ]; then
		origin=
		origin="$(cd "$repo" && git remote -v | awk '{ if ( $1 == "origin" ) { print $2; exit; } }')" || {}
		repo="$(_gh_repo_from_url "$origin")"
		echo "$repo"
	fi
}

# Pass explicit repo name to the gh cli
#
# This way I can run `gh run watch` and so on in repos I've cloned in .sl mode
# with sapling, where gh won't automatically detect the repo name.
gh() {
	case "$1" in
		pr|run|workflow)
			local subcommand="$1"
			shift

			local repo="$(gh_repo_name)"
			if [ -n "$repo" ]; then
				command gh "$subcommand" -R "$repo" $@
			else
				command gh "$subcommand" $@
			fi
		;;

		*)
			command gh $@
		;;
	esac
}
