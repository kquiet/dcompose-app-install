# Project Overview
This project automates the provisioning of Ubuntu 22.04 machines and the deployment of Docker Compose applications.

# Installation Modes
The installation process varies based on internet availability and whether the installation is performed locally on the target machine or remotely from a control machine.

There are four installation/upgrade modes:

| Prefix | Mode | Description |
| :---: | :--- | :--- |
| **1** | Local Install (Online) | Run directly on the target machine with internet access. Execute: `scripts/19_install_local_online.sh` |
| **2** | Local Install (Offline) | Run directly on the target machine without internet access. Execute: `scripts/29_install_local_offline.sh` |
| **3** | Remote Install (Online) | Run from a control machine targeting a remote host with internet access. *(Pending implementation)* |
| **4** | Remote Install (Offline) | Run from a control machine targeting a remote host without internet access. *(Pending implementation)* |

# Installation Workflow
1. Execute the primary Linux script corresponding to the desired installation mode (e.g., `scripts/19_install_local_online.sh`).
2. Each execution script performs the following steps:
    - Installs basic packages and configures SSH keys for Ansible operations.
    - Installs the Docker Engine and loads the Ansible container image.
    - Loads application container images. (Offline mode only)
    - Deploys Docker Compose applications (including `docker-compose.yml` and related configuration resources).
        - **Note for Upgrades**: The installation scripts are idempotent. To perform an upgrade (e.g. updating the application's images or configurations), replace the `app/` and `container_images/app/` directories with the new versions provided by the development team, and simply re-run the original installation script. The script will automatically detect the running application, safely shut it down (preserving persistent volumes), apply the new configurations, and restart the application.

# File Structure
1. **`ansible/`**: Contains all Ansible configurations, including playbooks, roles, and inventory files used to provision the environment (Ubuntu 22.04).
2. **`app/`**: Stores Docker Compose application resources. The development team should populate this directory with `docker-compose.yml`, `.env` files, and related configuration directories for their services. By default, it contains a dummy application for validation purposes until it is overwritten.
3. **`container_images/`**: Contains container image `.tar` files required for offline installations.
    - `ansible/`: Stores the Ansible control execution environment image.
    - `app/`: Stores application container images (currently git-ignored).
    - Note: All `.tar` files are managed via Git LFS.
4. **`os_packages/`**: Contains OS package `.deb` files for offline installation on target machines.
    - Subfolders: `basic` and `docker`.
    - Note: All `.deb` files are managed via Git LFS.
5. **`scripts/`**: Contains all shell scripts (`.sh`) for installation. Scripts prefixed with `99_` are utility scripts used for preparing OS packages/container images or for troubleshooting.
6. **`Dockerfile_ansible_ext`**: The Dockerfile used to build the Ansible control execution environment image.
7. **`Vagrantfile`**: A Vagrant configuration file for quickly provisioning multiple VM environments to test the installation process.

# Usage
1. Git clone this repo.
2. Place docker compose applications files under `app/`; remember to overwrite the dummy `docker-compose.yml`.
3. (Offline mode only) Place container images under `container_images/app/`. `scripts/99_save_docker_compose_images` could be used to obtain container images of a running docker compose application.
4. Execute the primary Linux script corresponding to the desired installation mode. (e.g., `scripts/19_install_local_online.sh` for mode 1; `scripts/29_install_local_offline.sh` for mode 2).

# Development Environment

## Vagrant Setup
To set up the development environment using Vagrant, follow these steps:

```bash
# Install QEMU/KVM components
sudo apt install qemu-kvm

# Install libvirt and VM management tools
sudo apt install virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils
sudo usermod -aG libvirt $USER

# Install Vagrant
sudo apt install vagrant

# Install build dependencies for the `vagrant-libvirt` plugin
sudo apt install -y ruby-dev libvirt-dev libxml2-dev libxslt1-dev

# Install Vagrant plugins
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-scp
```

# Verification and Testing

## Local Development (Vagrant)
To manually validate the installation scripts in a local environment, follow these steps using Vagrant:

1.  **Spin up VMs:**
    ```bash
    vagrant up
    ```
    This creates two VMs: `vm01` and `vm02`.

2.  **Test Mode 1 (Online):**
    ```bash
    vagrant ssh vm01
    /tmp/dcompose-app-install/scripts/19_install_local_online.sh
    ```

3.  **Test Mode 2 (Offline):**
    ```bash
    vagrant ssh vm02
    echo "127.0.0.1 archive.ubuntu.com security.ubuntu.com ports.ubuntu.com" | sudo tee -a /etc/hosts
    echo "127.0.0.1 production.cloudflare.docker.com auth.docker.io registry-1.docker.io index.docker.io dseasb33srnrn.cloudfront.net asia-east1-docker.pkg.dev" | sudo tee -a /etc/hosts
    sudo unshare -n -- bash -c "ip link set lo up && su $(whoami) -c '/tmp/dcompose-app-install/scripts/29_install_local_offline.sh'"
    ```

4.  **Verification Steps:**
    After the script finishes, verify the installation in the VM:
    -   **Check Ansible Image:** `sg docker -c "docker images"` should list `alpine/ansible:2.18.6`.

## Automated Testing (CI)
This repository includes a GitHub Actions workflow (`.github/workflows/test_install.yml`) to automatically validate Mode 1 and Mode 2 installation scripts.

-   **Triggers:**
    -   Pushes to branches: `main` or `dev`.
    -   Pull Requests targeting the `main` branch.

-   **Workflow Steps:**
    1.  **Checkout Code:** Fetches the repository, including LFS files (essential for binary packages).
    2.  **Setup Environment:** Uses a composite action to prepare the runner (e.g., removing pre-installed Docker, creating directory structures).
    3.  **Run Installation:** Executes `19_install_local_online.sh` (for Mode 1) or `29_install_local_offline.sh` (for Mode 2). For Mode 2, the script runs within a restricted network namespace (`unshare -n`) and with Docker registries blocked in `/etc/hosts` to simulate a true offline environment.
    4.  **Verify Installation:** Uses a reusable composite action to:
        -   Confirm the Ansible Docker image is loaded.
