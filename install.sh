#! /usr/bin/env bash

set -x

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~$(logname))

cp .vimrc $HM/.vimrc
cp -r .vim $HM

./v2nv.sh

cp .tmux.conf $HM
