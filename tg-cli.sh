#!/usr/bin/env bash

# Docker container name and data volume path will be set 
# based on PROJECT_NAME and ACCOUNT_NAME
PROJECT_NAME=tg_cli

# Data volume will be stored in /srv/${PROJECT_NAME}/${ACCOUNT_NAME}
# Eg: /srv/tg_cli/John_79876543210
CONFIG_VOLUME_PREFIX=/srv/${PROJECT_NAME}/

# Container will be named to ${PROJECT_NAME}_${ACCOUNT_NAME}
# Eg: tg_cli_John_79876543210
CONTAINER_NAME_PREFIX=${PROJECT_NAME}_


# Usage screen
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


# Setting variables
MACHINE=$1
ACCOUNT_NAME=$2
CONFIG_VOLUME=$CONFIG_VOLUME_PREFIX$ACCOUNT_NAME
CONTAINER_NAME=$CONTAINER_NAME_PREFIX$ACCOUNT_NAME


# Configuring Docker Macine
echo "Connecting to ${MACHINE}..."
eval $(docker-machine env ${MACHINE})
if [[ $? -ne 0 ]] ; then
    echo "Connection error."
    eval $(docker-machine env -u)
    exit 1
fi
echo "Connected"
echo


# Login stage (interactive)
# Type ^C after successful login to proceed whith the daemon stage 
echo "Login stage"
echo "1. Enter login credentials (phone, code, password) if needed."
echo "2. Send test message this account: it should appear in console."
echo "3. Type ^C to close login stage and run daemon stage."
echo
docker run \
    -v $CONFIG_VOLUME:/root/.telegram-cli \
    --name=$CONTAINER_NAME \
    --rm -it \
    pataquets/telegram-cli

if [[ $? -ne 0 ]] ; then
    eval $(docker-machine env -u)
    exit 1
fi


# Daemon stage (detached)
echo
echo "Daemon stage"
echo "Container name: $CONTAINER_NAME"
echo
docker run \
    -v $CONFIG_VOLUME:/root/.telegram-cli \
    --name=$CONTAINER_NAME \
    -it -d \
    --log-driver json-file --log-opt max-size=10m \
    --restart unless-stopped \
    pataquets/telegram-cli


# Resetting Docker Machine
echo
echo "Disconnecting from ${MACHINE}..."
eval $(docker-machine env -u)
echo "Done!"
