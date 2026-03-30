#!/bin/bash

PACKAGES=(
    "openssh-server"
    "rsync"
    "containerd.io"
    "docker-ce"
    "docker-ce-cli"
    "docker-compose-plugin"
)

sudo apt-get update

DOWNLOAD_LIST=$(apt-get install --simulate "${PACKAGES[@]}" | grep "^Inst" | awk '{print $2}')
echo $DOWNLOAD_LIST

# download .deb files
apt-get download $DOWNLOAD_LIST