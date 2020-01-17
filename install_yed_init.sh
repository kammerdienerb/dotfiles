#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Compiling kammerdienerb_init and installing."
gcc -shared -fPIC ${DIR}/kammerdienerb_init.c -lyed -o ~/.yed/init.so
