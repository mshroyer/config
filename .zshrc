HISTFILE=~/.zsh_histfile
HISTSIZE=10000
SAVEHIST=10000

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
# https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

# Left and right prompt style
setopt prompt_subst
PROMPT="[%m:%28<...<\${PWD/#\$HOME/~}%<<]%# "
precmd () { RPROMPT="%(?..%?)%" }

# Use meta-backspace to delete individual path components, not entire path...
WORDCHARS=${WORDCHARS//\/}

# Color ls output.
local platform=$(uname)
if [[ $platform = Linux ]] || [[ $platform = Darwin ]]; then
    alias ls='ls --color=auto'
elif [[ $platform = FreeBSD ]]; then
    alias ls='ls -G'
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
		   [[ ! -z $(/usr/bin/toe -a | grep tmux-direct) ]]; then
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

alias config="$(which git) --git-dir=$HOME/.cfg/ --work-tree=$HOME"

# Helper for running something as a background nohup job.
back() {
    nohup "$1" >/dev/null &
}

if [[ -f $HOME/.zshrc.local ]]; then
	. "$HOME/.zshrc.local"
fi

# Setup SSH authentication socket indirection for tmux.
#
# Currently, launching new zsh interactive shells on WSL2 AlmaLinux 9 appears
# to create two interactive shells in quick succession, the first of which
# doesn't have the TMUX environment set.  But we don't need this feature on
# WSL anyway, so let's just skip it for now.
if [[ -o interactive ]] && [ -z "$WSLENV" ]; then
	if [ -z "$TMUX" ]; then
		"$HOME/cfg.bin/tsock.sh" set-tty-link
	else
		export SSH_AUTH_SOCK="$($HOME/cfg.bin/tsock.sh show-server-link)"
	fi
fi

# The client-active hook doesn't always give us the correct new client_tty
# value, so we can also run the set-server-link hook as a shell preexec.  This
# should be pretty efficient and doesn't noticeably affect shell
# responsiveness.
periodic() {
	"$HOME/cfg.bin/tsock.sh" set-server-link - periodic
}
PERIOD=300

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
