#!/usr/bin/env bash

PROJECT_NAME=tg_cli
CONFIG_VOLUME_PREFIX=/srv/${PROJECT_NAME}/
CONTAINER_NAME_PREFIX=${PROJECT_NAME}_

if [[ $# -ne 2 ]] ; then
    echo "Usage:"
    echo "    tg-cli.sh docker_machine_name account_name"
    echo "    tg-cli.sh mynode john_71234567890"
    echo
    echo "Account credentials wiil be stored under:"
    echo "    ${CONFIG_VOLUME_PREFIX}%account_name%"
    echo
    echo "Docker container will be named as:"
    echo "    ${CONTAINER_NAME_PREFIX}%account_name%"
    echo
    exit 0
fi

MACHINE=$1
ACCOUNT_NAME=$2
CONFIG_VOLUME=$CONFIG_VOLUME_PREFIX$ACCOUNT_NAME
CONTAINER_NAME=$CONTAINER_NAME_PREFIX$ACCOUNT_NAME

echo "Connecting to ${MACHINE}..."
eval $(docker-machine env ${MACHINE})
if [[ $? -ne 0 ]] ; then
    echo "Connection error."
    eval $(docker-machine env -u)
    exit 1
fi
echo "Connected"
echo

echo "Login stage"
echo "1. Enter login credentials (phone, code, password) if needed."
echo "2. Send test message this account: it should appear in console."
echo "3. Type ^C to close login stage and run daemon stage."
echo
# Login stage (interactive)
docker run \
    -v $CONFIG_VOLUME:/root/.telegram-cli \
    --name=$CONTAINER_NAME \
    --rm -it \
    pataquets/telegram-cli

if [[ $? -ne 0 ]] ; then
    eval $(docker-machine env -u)
    exit 1
fi

echo
echo "Daemon stage"
echo "Container name: $CONTAINER_NAME"
echo
# Daemon stage (detached)
docker run \
    -v $CONFIG_VOLUME:/root/.telegram-cli \
    --name=$CONTAINER_NAME \
    -it -d \
    --restart unless-stopped \
    pataquets/telegram-cli

echo
echo "Disconnecting from ${MACHINE}..."
eval $(docker-machine env -u)
echo "Done!"
