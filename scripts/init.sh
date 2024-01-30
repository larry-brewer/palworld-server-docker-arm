#!/bin/bash
#set -e
set -xo pipefail

is_arm="false"
if [[ "$(uname -a | grep aarch64)" != "" ]]; then
    is_arm="true"
fi

if [[ ! "${PUID}" -eq 0 ]] && [[ ! "${PGID}" -eq 0 ]]; then
    printf "\e[0;32m*****EXECUTING USERMOD*****\e[0m\n"
    if [[ "$is_arm" == "true" ]]; then
        USERNAME="steam" # or fex....
    else
        USERNAME="steam"
    fi

    # TODO sort out fex already being uid 1000...
    if [[ "$is_arm" == "false" ]]; then
        # TODO why does this take a few minutes to run every time we launch a new container!?
        usermod -o -u "${PUID}" $USERNAME
        groupmod -o -g "${PGID}" $USERNAME
    fi
else
    printf "\033[31mRunning as root is not supported, please fix your PUID and PGID!\n"
    exit 1
fi

mkdir -p /palworld
chown -R $USERNAME:$USERNAME /palworld

if [ "${UPDATE_ON_BOOT}" = true ]; then
printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m\n"
    if [ "$is_arm" == "true" ]; then # if this an ARM kernel "aarch64", use FEXBash
        FEXBash="FEXBash"
        ls -latr /home/steam/Steam/
        steamcmd="/home/steam/Steam/steamcmd.sh"
    else
        FEXBash=""
        steamcmd="/home/steam/steamcmd/steamcmd.sh"
    fi

    chmod +x $steamcmd
    
    su $USERNAME -c "${FEXBash} -c \"${steamcmd} +force_install_dir /palworld +login anonymous +app_update 2394010 validate +quit\""
fi


mkdir -p /palworld/backups
chown -R steam:steam /palworld /home/steam/

term_handler() {
    if [ "${RCON_ENABLED}" = true ]; then
        rcon-cli save
        rcon-cli "shutdown 1"
    else # Does not save
        kill -SIGTERM "$(pidof PalServer-Linux-Test)"
    fi
    tail --pid=$killpid -f 2>/dev/null
}

trap 'term_handler' SIGTERM

su steam -c ./start.sh &
# Process ID of su
killpid="$!"
wait $killpid
