#!/bin/sh

mkdir -p /palworld

chown -R steam:steam /palworld

if [ "${UPDATE_ON_BOOT}" = true ]; then

    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m"
    if [ "$(uname –a | grep arm)" != "" ]; then # if this an ARM box, use FEXBash
        FEXBash="FEXBash"
    else
        FEXBash=""
    fi
    
    ${FEXBash} /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit

fi

./start.sh