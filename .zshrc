# Lines configured by zsh-newuser-install
if [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
fi
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
PROMPT='%-40<…<%~%<< %# '
# PROMPT='%~ %# '

source ~/.zsh/zsh-syntax-highlighting.zsh
export EDITOR=yed
export VISUAL=yed
alias sudo='sudo -E'

# HSTR configuration - add this to ~/.zshrc
alias hh=hstr                    # hh to be alias for hstr
setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors
bindkey -s "\C-r" "\C-a hstr -- \C-j"     # bind hstr to Ctrl-r (for Vi mode check doc)
