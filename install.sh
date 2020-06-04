#! /usr/bin/env bash

set -x

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~$(logname))

cp .vimrc $HM/.vimrc
cp -r .vim $HM

cp .tmux.conf $HM

./install_yed_init.sh
