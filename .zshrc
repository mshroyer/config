HISTFILE=~/.zsh_histfile
HISTSIZE=10000
SAVEHIST=10000

# Uncomment to enable startup profiling.  Also needs zprof uncommented at the
# bottom.
#zmodload zsh/zprof

if [ -d "$HOME/bin" ]; then
	PATH="$PATH:$HOME/bin"
fi
export PATH="$PATH:$HOME/cfg.bin"

setopt appendhistory sharehistory
setopt HIST_IGNORE_SPACE

# Use Emacs-style key bindings
bindkey -e

# Completion
fpath+=~/.zfunc
zstyle :compinstall filename "$HOME/.zshrc"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh_cache
autoload bashcompinit && bashcompinit
autoload -Uz compinit
# https://scottspence.com/posts/speeding-up-my-zsh-shell
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
	compinit
	touch ~/.zcompdump
else
	compinit -C
fi;

# Left and right prompt style
setopt prompt_subst
PROMPT=$'%{\e[38;5;178m%}[%m:%28<...<\${PWD/#\$HOME/~}%<<]%# %{\e[0m%}'
precmd () { RPROMPT=$'%(?..%{\e[38;5;196m%}[%?]%{\e[0m%})' }

# Use meta-backspace to delete individual path components, not entire path...
WORDCHARS=${WORDCHARS//\/}

# Color ls output.
local platform=$(uname)
if [[ $platform = Linux ]] || [[ $platform = Darwin ]]; then
	alias ls='ls --color=auto'
elif [[ $platform = FreeBSD ]]; then
	alias ls='ls -G'
elif [[ $platform = OpenBSD ]] || [[ $platform = NetBSD ]]; then
	# OpenBSD and NetBSD rely on a non-base package for color ls output.
	if type colorls >/dev/null; then
		alias ls='colorls -G'
	fi
fi

# My tmux configuration sets the default terminal to tmux-256color, which I
# have available everywhere I'm running this configuration set.  On many Linux
# systems, I also have the tmux-direct terminfo available, which when set will
# convince Emacs to enable true color support.  On other systems, such as
# Amazon Linux 2023, we don't have tmux-direct but can still convince Emacs to
# use true colors by setting COLORTERM.
#
# See Chad's post for details:
# https://chadaustin.me/2024/01/truecolor-terminal-emacs/
if [[ $TERM = tmux-256color ]]; then
	if [[ -x /usr/bin/toe ]] && \
		   [[ ! -z $(/usr/bin/toe -a | grep tmux-direct) ]] && \
		   [[ "$(uname)" != "FreeBSD" ]]; then
		export TERM=tmux-direct
	fi
	export COLORTERM=truecolor
fi

# Edit command line.
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

alias help="run-help"

alias l="ls"
alias la="ls -a"
alias ll="ls -l"
alias h="fc -l"
alias j="jobs"
alias m="${PAGER:-more}"

alias pu="pushd"
alias po="popd"
alias dirs="dirs -v"

alias ec="emacsclient -nw -c --alternate-editor=emacs"
alias ecn="emacsclient -n"
alias sshn="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
alias scpn="scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

alias sls='sl && sl status'

alias edit='msedit'

alias config="$(which git) --git-dir=$HOME/.cfg/ --work-tree=$HOME"

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

# Helper for running something as a background nohup job.
back() {
    nohup "$1" >/dev/null &
}

if [[ -f $HOME/.zshrc.local ]]; then
	. "$HOME/.zshrc.local"
fi

#
# Optional SDKs
#

function cloud {
    # Shell completion for the AWS CLI
    if [ -f /usr/local/bin/aws_completer ]; then
	    complete -C '/usr/local/bin/aws_completer' aws
    fi

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

    # The next line enables shell command completion for gcloud.
    if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
}

# Uncomment to enable startup profiling.  Also needs zmodload zsh/zprof
# uncommented at the top.
#zprof

### SOCKLINK INSTALLATION BEGIN
if [[ -o interactive ]]; then
	if [ -z "$TMUX" ]; then
		"$HOME/cfg.bin/socklink.sh" set-tty-link -c shell-init
	else
		export SSH_AUTH_SOCK="$("$HOME/cfg.bin/socklink.sh" show-server-link)"
	fi
fi
### SOCKLINK INSTALLATION END
