#! /usr/bin/env bash

if [ ! -f ~/.config/kitty/kitty.conf.$1 ]; then
    echo "kitty.conf.$1 not found"
    exit
fi

rm -f ~/.config/kitty/kitty.conf
ln -s $(realpath ~/.config/kitty/kitty.conf.$1) $(realpath ~/.config/kitty/kitty.conf)
if ps aux | grep "[^\d]kitty" | grep -v "grep" > /dev/null; then
    kitty @ set-colors --all --configured ~/.config/kitty/kitty.conf
fi
