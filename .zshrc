HISTFILE=~/.zsh_histfile
HISTSIZE=10000
SAVEHIST=10000

export PATH="$PATH:$HOME/cfg.bin"

setopt appendhistory sharehistory
setopt HIST_IGNORE_SPACE

# Use Emacs-style key bindings
bindkey -e

# Completion
zstyle :compinstall filename "$HOME/.zshrc"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh_cache
autoload -Uz compinit
compinit

# Left and right prompt style
setopt prompt_subst
PROMPT="[%m:%28<...<\${PWD/#\$HOME/~}%<<]%# "
precmd () { RPROMPT="%(?..%?)%" }

# Use meta-backspace to delete individual path components, not entire path...
WORDCHARS=${WORDCHARS//\/}

# Color ls output.
local platform=$(uname)
if [[ $platform = Linux ]]; then
    alias ls='ls --color=always'
elif [[ $platform = Darwin ]]; then
    alias ls='ls -G'
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

# Run an hg command and then print ssl and status.
hgs() {
	local cmd=true
	if [ $# -ne 0 ]; then
		hg $@
		sleep 1
	else
		true
	fi
	if [ $? -eq 0 ]; then
		hg ssl && hg status
	fi
}

alias pu="pushd"
alias po="popd"
alias dirs="dirs -v"

alias ec="emacsclient -nw -c --alternate-editor=emacs"
alias ecn="emacsclient -n"
alias sshn="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
alias scpn="scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

alias config="$(which git) --git-dir=$HOME/.cfg/ --work-tree=$HOME"

alias t="tzwatch -f '%a\ %F\ %T\ %4Z\ %z'"

# Helper for running something as a background nohup job.
back() {
    nohup "$1" >/dev/null &
}

if [[ -f $HOME/.zshrc.local ]]; then
    . "$HOME/.zshrc.local"
fi
