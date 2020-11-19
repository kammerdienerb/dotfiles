#! /usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $DIR

eval HM=$(echo ~$(logname))

echo ".vimrc"
cp .vimrc $HM/.vimrc
echo ".vim/"
cp -r .vim $HM
echo ".tmux.conf"
cp .tmux.conf $HM

mkdir -p ~/.yed

YED_INSTALLATION_PREFIX="/usr"
# YED_INSTALLATION_PREFIX="${HM}/.local"

C_FLAGS="-shared -fPIC -g -O0 -I${YED_INSTALLATION_PREFIX}/include -L${YED_INSTALLATION_PREFIX}/lib -lyed"

YED_DIR=${DIR}/.yed
HOME_YED_DIR=${HM}/.yed
for f in $(find ${DIR}/.yed -name "*.c"); do
    echo "Compiling ${f/${YED_DIR}/.yed} and installing."
    PLUG_DIR=$(dirname ${f/${YED_DIR}/${HOME_YED_DIR}})
    PLUG_FULL_PATH=${PLUG_DIR}/$(basename $f ".c").so

    mkdir -p ${PLUG_DIR}
    gcc ${f} ${C_FLAGS} -o ${PLUG_FULL_PATH} &
done

wait || exit 1

echo "Moving yedrc."
cp ${YED_DIR}/yedrc ${HOME_YED_DIR}
