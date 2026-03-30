#!/bin/bash
SSH_KEY_FILE="id-rsa-dcompose-app-install"
SSH_KEY_PATH="$HOME/.ssh/${SSH_KEY_FILE}"
SSH_KEY_COMMENT="$(whoami)@$(hostname)-dcompose-app-install"
OS_PACKAGE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../os_packages/ubuntu" >/dev/null 2>&1 && pwd)"
ANSIBLE_SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../ansible" >/dev/null 2>&1 && pwd)"
ANSIBLE_MOUNT_PATH="/ansible_src"
ANSIBLE_IMAGE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../container_images/ansible" >/dev/null 2>&1 && pwd)"
ANSIBLE_IMAGE="alpine/ansible:2.18.6"
APP_IMAGE_PATH="$(mkdir -p "$(dirname "${BASH_SOURCE[0]:-$0}")/../../container_images/app" && cd "$_" && pwd)"
APP_SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../app" >/dev/null 2>&1 && pwd)"
APP_MOUNT_PATH="/app_src"
echo $APP_IMAGE_PATH

# Determine Docker flags based on TTY availability
if [ -t 0 ]; then
    DOCKER_FLAGS="-it"
else
    DOCKER_FLAGS="-i"
fi

DOCKER_RUN_BASE="docker run ${DOCKER_FLAGS} --rm --add-host=host.docker.internal:host-gateway -e REMOTE_USER=$(whoami) -e SSH_KEY_FILE=${SSH_KEY_FILE} -v ${HOME}/.ssh:/root/.ssh -v ${ANSIBLE_SOURCE_PATH}:${ANSIBLE_MOUNT_PATH}:ro -v ${APP_SOURCE_PATH}:${APP_MOUNT_PATH}:ro -w ${ANSIBLE_MOUNT_PATH} ${ANSIBLE_IMAGE}"

asb-asb() { ${DOCKER_RUN_BASE} "$@"; }
asb() { ${DOCKER_RUN_BASE} ansible "$@"; }
asb-config() { ${DOCKER_RUN_BASE} ansible-config "$@"; }
asb-community() { ${DOCKER_RUN_BASE} ansible-community "$@"; }
asb-console() { ${DOCKER_RUN_BASE} ansible-console "$@"; }
asb-doc() { ${DOCKER_RUN_BASE} ansible-doc "$@"; }
asb-galaxy() { ${DOCKER_RUN_BASE} ansible-galaxy "$@"; }
asb-inventory() { ${DOCKER_RUN_BASE} ansible-inventory "$@"; }
asb-playbook() { ${DOCKER_RUN_BASE} ansible-playbook "$@"; }
asb-pull() { ${DOCKER_RUN_BASE} ansible-pull "$@"; }
asb-test() { ${DOCKER_RUN_BASE} ansible-test "$@"; }
asb-vault() { ${DOCKER_RUN_BASE} ansible-vault "$@"; }

prepare-ssh-key() {
    # Generate ssh key ONLY if it doesn't exist
    if [ ! -f "$SSH_KEY_PATH" ]; then
        echo "Key not found. Generating new SSH key..."
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -C "$SSH_KEY_COMMENT" -N ""
    else
        echo "SSH key already exists. Skipping generation."
    fi

    # Ensure files exist for comparison
    touch "$HOME/.ssh/authorized_keys"
    NEW_PUB_KEY=$(cat "${SSH_KEY_PATH}.pub")

    # Only modify authorized_keys if the specific key content is missing
    # -F: interpret pattern as a fixed string (safer for keys)
    if ! grep -qF "$NEW_PUB_KEY" "$HOME/.ssh/authorized_keys"; then
        echo "Key not found in authorized_keys. Updating..."
        echo "$NEW_PUB_KEY" >> "$HOME/.ssh/authorized_keys"
        chmod 600 "$HOME/.ssh/authorized_keys"
    else
        echo "The correct public key is already present. No changes made."
    fi
}

is-package-installed() {
    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"; then
        return 0
    else
        return 1
    fi
}

execute_with_docker_group() {
    local cmd="$1"

    # Check if we can run docker commands directly
    if docker ps >/dev/null 2>&1; then
        eval "$cmd"
    else
        # Fallback to sg if docker access is not available in current shell
        sg docker -c "$cmd"
    fi
}

select-ansible-group() {
    local inventory_path="${ANSIBLE_SOURCE_PATH}/inventory/edge.yml"
    local groups_str
    local selected_group

    # 1. Extract group names using Python
    groups_str=$(python3 -c "
import yaml, sys
try:
    with open('$inventory_path', 'r') as f:
        data = yaml.safe_load(f)
        groups = data.get('all', {}).get('children', {}).keys()
        print(' '.join(groups))
except Exception:
    sys.exit(1)
")

    if [ $? -ne 0 ] || [ -z "$groups_str" ]; then
        echo "Error: Could not parse groups from $inventory_path." >&2
        return 1
    fi

    # 2. Prompt user
    echo "------------------------------------------" >&2
    echo " Select the ANSIBLE_TARGET_GROUP:" >&2
    echo "------------------------------------------" >&2
    
    local old_ps3="$PS3" # Save current PS3 to restore it later
    PS3="Selection #? "
    
    select opt in $groups_str "Quit"; do
        case $opt in
            "Quit")
                echo "Exiting..." >&2
                return 1
                ;;
            *)
                if [[ -n "$opt" ]]; then
                    selected_group="$opt"
                    break
                else
                    echo "Invalid selection." >&2
                fi
                ;;
        esac
    done

    PS3="$old_ps3" # Restore original PS3
    echo "$selected_group" # Output the choice so it can be captured
}

load-docker-images() {
    local target_dir="$1"

    # Check if directory exists
    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' not found."
        return 1
    fi

    echo "Scanning '$target_dir' for Docker images..."
    echo "------------------------------------------"

    # Loop through .tar files
    # Using find to handle filenames with spaces correctly
    find "$target_dir" -maxdepth 1 -name "*.tar" -type f | while read -r tar_file; do
        echo "Processing: $(basename "$tar_file")"
        
        # Execute the load
        if docker load -i "$tar_file"; then
            echo "Successfully loaded: $tar_file"
        else
            echo "Failed to load: $tar_file"
        fi
        echo "------------------------------------------"
    done

    echo "Batch load complete."
}

check_step_result() {
    local return_code=$1
    local step_name=$2

    if [ "$return_code" -eq 0 ]; then
        echo "=========================================="
        echo "##### SUCCESS: ${step_name} completed #####"
        echo "=========================================="
    else
        echo "=========================================="
        echo "##### ERROR: ${step_name} failed #####"
        echo "=========================================="
        exit "$return_code"
    fi
}
