#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/utility/vars_functions.sh"

# install docker
echo "Installing Docker..."
sudo dpkg --force-confdef --force-confold -i "${OS_PACKAGE_PATH}/docker/"*.deb
sudo groupadd docker || true
sudo usermod -aG docker $USER

# install ansible container image
execute_with_docker_group "bash -c \"
  source '${SCRIPT_DIR}/utility/vars_functions.sh'
  load-docker-images '$ANSIBLE_IMAGE_PATH'
\""

echo "Docker installed and ansible image loaded. Please logout and login to make sure '$USER' has docker permissions."
