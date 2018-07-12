#! /usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

cp .vimrc ~/.vimrc
mkdir -p ~/.vim
mkdir -p ~/.vim/ftdetect
mkdir -p ~/.vim/syntax
mkdir -p ~/.vim/autoload
cp .vim/ftdetect/bjou.vim ~/.vim/ftdetect
cp .vim/syntax/bjou.vim ~/.vim/syntax
cp .vim/autoload/plug.vim ~/.vim/autoload
cp vvish.vim ~

./v2nv.sh

cp Default.vifm ~/.config/vifm/colors

cp config.fish ~/.config/fish

cp kitty.conf.dark ~/.config/kitty
cp kitty.conf.light ~/.config/kitty
cp kittyconf.sh ~
