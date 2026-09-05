---
name: docker-sandbox-test
description: >-
  Use this skill to safely test and validate Linux setup scripts inside clean, isolated
  Docker containers (e.g. Fedora, Ubuntu) without touching the host operating system.
---

# Docker Sandbox Test Skill

## Overview
This skill provides automated workflows for testing installation scripts in isolated environments using Docker.

## Workflow

1. **Dry-Run Syntax Verification**:
   Before launching any container test, always verify that all scripts pass syntax inspection:
   ```bash
   bash -n linux-setup/setup.sh
   for s in linux-setup/scripts/*.sh; do bash -n "$s"; done
   ```

2. **Spinning Up a Clean Test Container**:
   Launch a transient container mounting the project directory:
   ```bash
   docker run --rm -it \
     -v "$(pwd):/workspace:ro" \
     -w /workspace/linux-setup \
     fedora:latest \
     bash -c "echo '[SANDBOX TEST]' && bash -n setup.sh"
   ```

3. **Verifying Non-Interactive Execution**:
   To test package availability and commands inside container:
   - Check if required DNF packages exist in clean repositories:
     ```bash
     docker run --rm fedora:latest dnf info zsh starship fzf bat eza
     ```

4. **Testing Idempotency**:
   - Ensure scripts can run multiple times without corrupting state or producing duplicated configuration lines.
