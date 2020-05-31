#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir -p ~/.yed

echo "Compiling kammerdienerb_init and installing."
gcc -shared -fPIC -g -O3 ${DIR}/kammerdienerb_init.c -lyed -o ~/.yed/init.so
echo "Compiling slide plugin and installing."
gcc -shared -fPIC -g -O3 ${DIR}/slide.c -lyed -o ~/.yed/slide.so
echo "Moving yedrc."
cp ${DIR}/yedrc ~/.yed/yedrc
