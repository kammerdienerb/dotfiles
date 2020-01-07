#!/usr/bin/env bash

echo "Compiling kammerdienerb_init and installing."
gcc -shared -fPIC kammerdienerb_init.c -lyed -o ~/.yed/init.so
