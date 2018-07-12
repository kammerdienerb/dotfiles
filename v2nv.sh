#! /usr/bin/env bash

NVIM=$(command -v nvim 2> /dev/null)

set -e

if [[ "$NVIM" != "" ]]; then
    NVIM_PATH=$($NVIM --version | awk '/fall-back for \$VIM/{ print $4; }')
    NVIM_PATH=$(echo $NVIM_PATH | sed -E 's/\"//g')

    printf "source ~/.vimrc\nset guicursor=" > $NVIM_PATH/sysinit.vim
    mkdir -p $NVIM_PATH/runtime/ftdetect
    cp ~/.vim/ftdetect/bjou.vim $NVIM_PATH/runtime/ftdetect
    cp ~/.vim/syntax/bjou.vim $NVIM_PATH/runtime/syntax
fi
