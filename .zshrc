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

alias config="$(which git) --git-dir=$HOME/.cfg/ --work-tree=$HOME"

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
		$HOME/cfg.bin/socklink.sh set-tty-link
	else
		export SSH_AUTH_SOCK="$($HOME/cfg.bin/socklink.sh show-server-link)"
	fi
fi
### SOCKLINK INSTALLATION END
