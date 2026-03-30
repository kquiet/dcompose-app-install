#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/utility/vars_functions.sh"

# install basic packages
echo "Installing basic packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y openssh-server rsync
sudo systemctl enable --now ssh

# prepare ssh keys
prepare-ssh-key
