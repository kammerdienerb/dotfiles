#! /usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

# eval HM=$(echo ~$(logname))
eval HM=$(echo ~${USER})

echo ".zshrc"
cp .zshrc $HM/.zshrc
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

mkdir -p ~/.yed

YED_INSTALLATION_PREFIX="/usr"
# YED_INSTALLATION_PREFIX="${HM}/.local"

# DBG_OR_OPT="-g -O0"
DBG_OR_OPT="-O3"
C_FLAGS="-shared -fPIC -Wall -Werror ${DBG_OR_OPT} -I${YED_INSTALLATION_PREFIX}/include -L${YED_INSTALLATION_PREFIX}/lib -lyed"

YED_DIR=${DIR}/.yed
HOME_YED_DIR=${HM}/.yed

pids=()

for f in $(find ${DIR}/.yed -name "*.c"); do
    echo "Compiling ${f/${YED_DIR}/.yed} and installing."
    PLUG_DIR=$(dirname ${f/${YED_DIR}/${HOME_YED_DIR}})
    PLUG_FULL_PATH=${PLUG_DIR}/$(basename $f ".c").so

    mkdir -p ${PLUG_DIR}
    gcc ${f} ${C_FLAGS} -o ${PLUG_FULL_PATH} &
    pids+=($!)
done

for p in ${pids[@]}; do
    wait $p || exit 1
done

echo "Moving yedrc."
cp ${YED_DIR}/yedrc ${HOME_YED_DIR}
echo "Done."
