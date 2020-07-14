#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    echo "You need to be root for this."
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir -p /root/.yed
echo "Compiling root_init.c and installing."
gcc -shared -fPIC -g -O3 ${DIR}/root_init.c -lyed -o /root/.yed/init.so
echo "Moving root yedrc."
cp ${DIR}/root.yedrc /root/.yed/yedrc
