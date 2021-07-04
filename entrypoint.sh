#!/bin/bash
set -e

USER=root
TRANSMISSION_DIR=/var/lib/transmission
CONFIG_DIR=${TRANSMISSION_DIR}

if [[ -z ${RPC_USERNAME} ]]; then
    RPC_USERNAME=transmission
fi
if [[ -z ${RPC_PASSWORD} ]]; then
    RPC_PASSWORD=transmission
fi

if [[ ! -d ${TRANSMISSION_DIR} ]]; then
    mkdir -p ${TRANSMISSION_DIR}
fi

# setup basic config
if [[ ! -f ${CONFIG_DIR}/settings.json ]]; then
    mkdir -p ${CONFIG_DIR}
    <<EOF tee > ${CONFIG_DIR}/settings.json
{
    "alt-speed-down": 50,
    "alt-speed-enabled": false,
    "alt-speed-time-begin": 540,
    "alt-speed-time-day": 127,
    "alt-speed-time-enabled": false,
    "alt-speed-time-end": 1020,
    "alt-speed-up": 50,
    "bind-address-ipv4": "0.0.0.0",
    "bind-address-ipv6": "::",
    "blocklist-enabled": false,
    "cache-size-mb": 4,
    "dht-enabled": true,
    "download-queue-enabled": true,
    "download-queue-size": 5,
    "encryption": 1,
    "idle-seeding-limit": 30,
    "idle-seeding-limit-enabled": false,
    "incomplete-dir-enabled": false,
    "lpd-enabled": false,
    "message-level": 2,
    "peer-id-ttl-hours": 6,
    "peer-limit-global": 200,
    "peer-limit-per-torrent": 50,
    "peer-port": 51413,
    "peer-port-random-high": 65535,
    "peer-port-random-low": 49152,
    "peer-port-random-on-start": false,
    "peer-socket-tos": "default",
    "pex-enabled": true,
    "port-forwarding-enabled": true,
    "preallocation": 1,
    "prefetch-enabled": true,
    "queue-stalled-enabled": true,
    "queue-stalled-minutes": 30,
    "ratio-limit": 2,
    "ratio-limit-enabled": false,
    "rename-partial-files": true,
    "rpc-authentication-required": true,
    "rpc-bind-address": "0.0.0.0",
    "rpc-enabled": true,
    "rpc-host-whitelist": "",
    "rpc-host-whitelist-enabled": false,
    "rpc-password": "${RPC_PASSWORD}",
    "rpc-port": 9091,
    "rpc-url": "/transmission/",
    "rpc-username": "${RPC_USERNAME}",
    "rpc-whitelist": "127.0.0.1,::1",
    "rpc-whitelist-enabled": false,
    "scrape-paused-torrents-enabled": true,
    "script-torrent-done-enabled": false,
    "script-torrent-done-filename": "",
    "seed-queue-enabled": false,
    "seed-queue-size": 10,
    "speed-limit-down": 100,
    "speed-limit-down-enabled": false,
    "speed-limit-up": 100,
    "speed-limit-up-enabled": false,
    "start-added-torrents": true,
    "trash-original-torrent-files": false,
    "umask": 18,
    "upload-slots-per-torrent": 14,
    "utp-enabled": true
}
EOF
fi

# switch user
if [[ ! -z ${DOCKER_UID} ]]; then
    if [[ -z ${DOCKER_GID} ]]; then
        DOCKER_GID=${DOCKER_UID}
    fi
    USER=transmission
    if [[ ! -f /.user-initialized ]]; then
        groupadd -f -g ${DOCKER_GID} transmission
        useradd -u ${DOCKER_UID} -g ${DOCKER_GID} --home-dir ${TRANSMISSION_DIR} transmission
        chown ${DOCKER_UID}:${DOCKER_GID} -R ${TRANSMISSION_DIR}
        touch /.user-initialized
    fi
fi

if [[ ${USER} == "root" ]];then
    exec $@
fi

exec su - ${USER} <<EOF
exec $@
EOF
