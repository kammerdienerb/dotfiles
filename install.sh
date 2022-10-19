#! /usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~${USER})

echo ".zshrc"
cp .zshrc $HM/.zshrc
cp -r .zsh $HM
echo ".Xresources"
cp .Xresources $HM/.Xresources
echo ".vimrc"
cp .vimrc $HM/.vimrc
echo ".vim/"
cp -r .vim $HM
echo ".tmux.conf"
cp .tmux.conf $HM
echo ".ssh/config"
mkdir -p $HM/.ssh
cp .ssh/config $HM/.ssh
echo ".config/kitty"
cp -r .config/kitty $HM/.config
echo ".config/alacritty"
cp -r .config/alacritty $HM/.config


YED_DIR=${DIR}/yed
CONFIG_YED_DIR=$(yed --print-config-dir)

CC=gcc
C_FLAGS="-O3"

if [ "$(uname)" = "Darwin" ]; then # M1
    if uname -a 2>&1 | grep "ARM" >/dev/null; then
        C_FLAGS="-arch arm64 ${C_FLAGS}"
        CC=clang
    fi
fi

C_FLAGS+=" $(yed --print-cflags --print-ldflags) -Wall -Werror"


pids=()

for f in $(find ${YED_DIR} -name "*.c" -not -path "${YED_DIR}/ypm/*"); do
    echo ${f/${YED_DIR}\//}
    PLUG_DIR=$(dirname ${f})
    PLUG_FULL_PATH=${PLUG_DIR}/$(basename $f ".c").so

    ${CC} ${f} ${C_FLAGS} -o ${PLUG_FULL_PATH} &
    pids+=($!)
done

for p in ${pids[@]}; do
    wait $p || exit 1
done

if [ -d ${CONFIG_YED_DIR} ] && ! [ -L ${CONFIG_YED_DIR} ]; then
    echo "${CONFIG_YED_DIR} exists, but is not a symlink.. aborting."
    exit 1
fi

if ! [ -L ${CONFIG_YED_DIR} ]; then
    ln -s ${YED_DIR} ${CONFIG_YED_DIR}
fi

echo "Done."
