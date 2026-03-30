#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/utility/vars_functions.sh"

ANSIBLE_TARGET_GROUP=$(select-ansible-group)
if [ $? -ne 0 ]; then
    exit 0
fi

asb-playbook -v -l "${ANSIBLE_TARGET_GROUP}" playbooks/ping.yml
