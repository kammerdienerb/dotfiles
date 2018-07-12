#! /usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

cp .vimrc ~/.vimrc
mkdir -p ~/.vim
mkdir -p ~/.vim/ftdetect
mkdir -p ~/.vim/syntax
cp .vim/ftdetect/bjou.vim ~/.vim/ftdetect
cp .vim/syntax/bjou.vim ~/.vim/syntax

./v2nv.sh

cp Default.vifm ~/.config/vifm/colors

cp config.fish ~/.config/fish

cp kitty.conf.dark ~/.config/kitty
cp kitty.conf.light ~/.config/kitty
cp kittyconf.sh ~
