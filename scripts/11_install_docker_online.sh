#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/utility/vars_functions.sh"

# install docker
echo "Installing Docker..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo groupadd docker || true
sudo usermod -aG docker $USER

# install ansible container image
execute_with_docker_group "bash -c \"
  source '${SCRIPT_DIR}/utility/vars_functions.sh'
  load-docker-images '$ANSIBLE_IMAGE_PATH'
\""

echo "Docker installed and ansible image loaded. Please logout and login to make sure '$USER' has docker permissions."
