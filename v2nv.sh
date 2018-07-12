#! /usr/bin/env bash

NVIM=$(command -v nvim 2> /dev/null)

set -e

eval HM=$(echo ~$(logname))

if [[ "$NVIM" != "" ]]; then
    NVIM_PATH=$($NVIM --version | awk '/fall-back for \$VIM/{ print $4; }')
    NVIM_PATH=$(echo $NVIM_PATH | sed -E 's/\"//g')

    printf "source $HM/.vimrc\nset guicursor=" > $NVIM_PATH/sysinit.vim
    mkdir -p $NVIM_PATH/runtime/ftdetect
    mkdir -p $NVIM_PATH/runtime/syntax
    mkdir -p $NVIM_PATH/runtime/autoload
    cp $HM/.vim/ftdetect/bjou.vim $NVIM_PATH/runtime/ftdetect
    cp $HM/.vim/syntax/bjou.vim $NVIM_PATH/runtime/syntax
    cp $HM/.vim/autoload/plug.vim $NVIM_PATH/runtime/autoload
fi
