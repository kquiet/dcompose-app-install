# Agent Instructions (AGENTS.md)

This file provides context, guidelines, and instructions for AI agents working on this repository. Follow these rules to ensure consistency, quality, and alignment with the project's goals.

## 1. Project Overview
This repository automates the provisioning of Ubuntu machines and the deployment of Docker Compose applications.
- **Core Technology**: Ansible (running in a Docker container), Shell Scripting.
- **Target OS**: Ubuntu 22.04 and above.
- **Goal**: Support 4 distinct installation modes covering Local/Remote and Online/Offline scenarios.

## 2. Workflow Rules
- **Branching**: ALWAYS create a new branch for every task. Use the format `agent/[short-description]`. **Never reuse a branch name from a previous session.** Use a timestamp or random suffix if needed (e.g., `agent/fix-net-171400`).
  - Example: `agent/fix-ci-workflow`, `agent/add-new-feature`.
  - Do not use generic names or random strings.
- **Git Sync**: Before writing code, ensure you are working off the latest revision of target branch.

## 3. Terminology & Naming Conventions
Adhere strictly to the following terminology in code, comments, and documentation.

| Concept | Term to Use | Forbidden Terms |
| :--- | :--- | :--- |
| **Connectivity** | **Online** / **Offline** | with internet / without internet |
| **Execution Context** | **Local** (on target) / **Remote** (from control node) | - |

### Script Naming Convention
Shell scripts in `scripts/` must follow the pattern: `[Prefix]_[Action]_[Context]_[Connectivity].sh`
- **Examples**: `19_install_local_online.sh`, `29_install_local_offline.sh`
- **Prefixes**:
    - `1*`: Local / Online
    - `2*`: Local / Offline
    - `3*`: Remote / Online
    - `4*`: Remote / Offline
    - `99`: Utilities

## 4. Directory Structure Guidelines
- **`ansible/`**: Only Ansible-related files (playbooks, roles, inventory). Do not put shell scripts here.
- **`scripts/`**: Entry point shell scripts.
- **`os_packages/`**: Stores `.deb` files (Git LFS).
- **`container_images/`**: Stores `.tar` Docker images (Git LFS).

## 5. Coding Standards

### Shell Scripts (`.sh`)
- **Shebang**: Always use `#!/bin/bash`.
- **Error Handling**: Start scripts with `set -e` to fail on errors.
- **Paths**: Use relative paths based on the script location.
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"
  ```
- **Sudo**: Avoid hardcoding `sudo` inside scripts if possible; assume the script is run with necessary privileges or uses `sg docker` for group membership adjustments.

### Ansible
- **Inventory**: The `local` group targets `localhost`. The `remote` group targets `host.docker.internal` (the Ansible control node is a container, so running Ansible from inside the container to provision the host). The `vagrant` group targets on vagrant-managed virtual machines for local development or testing.
- **Playbooks**: Ensure idempotency. Rerunning a playbook should not break the system.

## 6. Boundaries (What NOT to do)
- **Do not** add files to folder `/container_images` or `/os_packages` without asking.
- **Do not** update shared shell scripts in folder `/scripts/utility/` without asking.
- **Do not** change the `Vagrantfile` unless specifically instructed.

## 7. Documentation (README.md)
- **Language**: English.
- **Style**: Professional, clear, and concise. Avoid casual phrasing.
- **Formatting**: Use Markdown tables for structured data.
- **Sync**: Always check and update `README.md` to reflect code changes, especially when modifying installation workflows, verification logic, or adding new features. Ensure documentation remains accurate and up-to-date with the codebase.

## 8. Testing & Verification
Before marking a task as complete:
1.  **Static Analysis**: Verify syntax (e.g., `bash -n script.sh`, `ansible-playbook --syntax-check ...`).
2.  **File Verification**: Ensure all new files are in the correct directories.
3.  **LFS Check**: If adding binary files, confirm they are tracked by Git LFS.

## 9. Interaction Guidelines
- **Readability**: When refactoring, prioritize readability over clever one-liners.
- **Focus**: If you find a bug or potential improvement unrelated to the current task, just list it in the PR description; don't fix it yet.
- **Clarification**: If a requirement is ambiguous (especially regarding "Remote" vs "Local" execution), ask the user for clarification before proceeding.
- **Context Awareness**: The user may not be a native English speaker. When updating documentation, prioritize clarity and standard technical English.
