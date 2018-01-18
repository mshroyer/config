HISTFILE=~/.zsh_histfile
HISTSIZE=10000
SAVEHIST=10000

setopt appendhistory sharehistory

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

# Helper for running something as a background nohup job.
back() {
    nohup "$1" >/dev/null &
}

if [ -f "$HOME/.zshrc.local" ]; then
    . "$HOME/.zshrc.local"
fi
