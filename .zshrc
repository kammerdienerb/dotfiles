# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob notify
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kammerdienerb/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ls='ls -G'
PROMPT='%~ %# '

source ~/.zsh/zsh-syntax-highlighting.zsh
export EDITOR=yed
export VISUAL=yed
alias sudo='sudo -E'
