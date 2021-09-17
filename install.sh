#! /usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~${USER})

echo ".zshrc"
cp .zshrc $HM/.zshrc
cp -r .zsh $HM
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


YED_DIR=${DIR}/.yed
HOME_YED_DIR=${HM}/.yed

CC=gcc
C_FLAGS="-O3"

if [ "$(uname)" = "Darwin" ]; then # M1
    if uname -a 2>&1 | grep "ARM" >/dev/null; then
        C_FLAGS="-arch arm64 ${C_FLAGS}"
        CC=clang
    fi
fi

C_FLAGS+=" $(yed --print-cflags) $(yed --print-ldflags)"


YED_DIR=${DIR}/.yed
HOME_YED_DIR=${HM}/.yed

pids=()

for f in $(find ${DIR}/.yed -name "*.c"); do
    echo "${f/${YED_DIR}/.yed}"
    PLUG_DIR=$(dirname ${f})
    PLUG_FULL_PATH=${PLUG_DIR}/$(basename $f ".c").so

    ${CC} ${f} ${C_FLAGS} -o ${PLUG_FULL_PATH} &
    pids+=($!)
done

for p in ${pids[@]}; do
    wait $p || exit 1
done

if [ -d ${HOME_YED_DIR} ] && ! [ -L ${HOME_YED_DIR} ]; then
    echo "${HOME_YED_DIR} exists, but is not a symlink.. aborting."
    exit 1
fi

if ! [ -L ${HOME_YED_DIR} ]; then
    ln -s ${YED_DIR} ${HOME_YED_DIR}
fi

echo "Done."
