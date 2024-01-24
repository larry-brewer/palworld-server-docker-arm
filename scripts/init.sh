#!/bin/bash
#set -e
set -xo pipefail

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    printf "\e[0;32m*****EXECUTING USERMOD*****\e[0m\n"
    usermod -o -u "${PUID}" steam
    groupmod -o -g "${PGID}" steam
else
    printf "\033[31mRunning as root is not supported, please fix your PUID and PGID!\n"
    exit 1
fi

mkdir -p /palworld
chown -R steam:steam /palworld

if [ "${UPDATE_ON_BOOT}" = true ]; then
printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m\n"
    if [ "$(uname -a | grep aarch64)" != "" ]; then # if this an ARM kernel "aarch64", use FEXBash
        FEXBash="FEXBash"
        ls -latr /usr/bin/Steam/
        steamcmd="/usr/bin/Steam/steamcmd.sh"
    else
        FEXBash=""
        steamcmd="/home/steam/steamcmd/steamcmd.sh"
    fi

    chmod +x $steamcmd
    
    ${FEXBash} su steam -c "${steamcmd} +force_install_dir '/palworld' +login anonymous +app_update 2394010 validate +quit"
fi

read -p "Init completed???? debug now!" dummy

./start.sh
