#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
source "${SCRIPT_DIR}/utility/vars_functions.sh"

"${SCRIPT_DIR}/20_install_basic_offline.sh"
check_step_result $? "Install Basic packages"

"${SCRIPT_DIR}/21_install_docker_offline.sh"
check_step_result $? "Install Docker packages"

execute_with_docker_group "${SCRIPT_DIR}/22_install_app_images_offline.sh"
check_step_result $? "Install App Images"

execute_with_docker_group "bash -c \"
  source '${SCRIPT_DIR}/utility/vars_functions.sh'
  echo 'Installing Docker Compose Application...'
  asb-playbook -v -l docker playbooks/install_docker_compose_app.yml -e app_src_path=${APP_MOUNT_PATH}
\""
check_step_result $? "Install Docker Compose Application"

echo "=================================================="
echo "##### INSTALLATION COMPLETED SUCCESSFULLY #####"
echo "=================================================="
