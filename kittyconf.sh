#! /usr/bin/env bash

if [ ! -f ~/.config/kitty/kitty.conf.$1 ]; then
    echo "kitty.conf.$1 not found"
    exit
fi

rm -f ~/.config/kitty/kitty.conf
ln -s $(realpath ~/.config/kitty/kitty.conf.$1) $(realpath ~/.config/kitty/kitty.conf)
if pgrep -x "kitty" > /dev/null; then
    kitty @ set-colors --all --configured ~/.config/kitty/kitty.conf
fi
