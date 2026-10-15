#!/bin/bash
set -u

sleep 1

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

if [ -f "/usr/local/bin/proton" ]; then
    if [ -n "${SRCDS_APPID:-}" ]; then
        mkdir -p "/home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}"
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
        export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}"
        # GE-Proton 11's built-in Steam launch shim needs the application ID
        # explicitly. Without these variables a fresh prefix can wait forever
        # before the target executable is mapped.
        export STEAM_COMPAT_APP_ID="${SRCDS_APPID}"
        export SteamAppId="${SRCDS_APPID}"
        export SteamGameId="${SRCDS_APPID}"
    else
        echo "SRCDS_APPID is required when using Proton"
        exit 1
    fi
fi

cd /home/container || exit 1

STEAM_USER=${STEAM_USER:-anonymous}
if [ "${STEAM_USER}" = "anonymous" ]; then
    STEAM_PASS=""
    STEAM_AUTH=""
fi

if [ -z "${AUTO_UPDATE:-}" ] || [ "${AUTO_UPDATE}" = "1" ]; then
    if [ -n "${SRCDS_APPID:-}" ]; then
        # Match the official ptero-eggs SteamCMD entrypoint behavior.
        # shellcheck disable=SC2046,SC2086
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login "${STEAM_USER}" "${STEAM_PASS:-}" "${STEAM_AUTH:-}" $([[ "${WINDOWS_INSTALL:-}" = "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows') $([[ -z "${HLDS_GAME:-}" ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}") "+app_update ${SRCDS_APPID} $([[ -z "${SRCDS_BETAID:-}" ]] || printf %s "-beta ${SRCDS_BETAID}") $([[ -z "${SRCDS_BETAPASS:-}" ]] || printf %s "-betapassword ${SRCDS_BETAPASS}") ${INSTALL_FLAGS:-} $([[ "${VALIDATE:-}" = "1" ]] && printf %s 'validate')" $([[ "${UPDATE_STEAMWORKS:-}" = "1" ]] && printf %s '+app_update 1007') +quit
    fi
fi

MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

eval "${MODIFIED_STARTUP}"
