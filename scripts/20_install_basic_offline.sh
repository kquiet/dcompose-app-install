#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/utility/vars_functions.sh"

echo "packages path: ${OS_PACKAGE_PATH}"

# install basic packages
echo "Installing basic packages..."
sudo dpkg --force-confdef --force-confold -i "${OS_PACKAGE_PATH}/basic/"*.deb

# prepare ssh keys
prepare-ssh-key
