#! /usr/bin/env bash

set -x

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~$(logname))

cp .vimrc $HM/.vimrc
mkdir -p $HM/.vim
mkdir -p $HM/.vim/ftdetect
mkdir -p $HM/.vim/syntax
mkdir -p $HM/.vim/autoload
cp .vim/ftdetect/bjou.vim $HM/.vim/ftdetect
cp bjou.vim .vim/syntax
cp .vim/syntax/bjou.vim $HM/.vim/syntax
cp .vim/autoload/plug.vim $HM/.vim/autoload
cp vvish.vim $HM

./v2nv.sh

cp Default.vifm $HM/.config/vifm/colors

cp kitty.conf.dark $HM/.config/kitty
cp kitty.conf.light $HM/.config/kitty
cp kittyconf.sh $HM

cp .tmux.conf $HM
