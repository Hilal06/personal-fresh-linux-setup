---
name: linux-setup-helper
description: >-
  Use this skill when modifying, adding, or testing Linux setup scripts,
  package installation routines, or dotfiles in personal-fresh-linux-setup.
---

# Linux Setup Helper Skill

## Overview
This skill provides procedures for maintaining and extending the automation scripts within `personal-fresh-linux-setup`.

## Workflow Guidelines

1. **Adding New Packages/Tools**:
   - Check [software-development-list.txt](file:///home/faulfedora/Documents/Script/personal-fresh-linux-setup/software-development-list.txt) to see if the tool is listed or needs to be added.
   - Implement package manager installation logic covering Fedora (`dnf`) and Ubuntu (`apt`). Arch (`pacman`) is strictly unsupported.
   - If a package requires external repos or binary downloads (like Starship or eza on older distros), provide reliable curl/script/binary fallback.

2. **Validating Scripts**:
   - Verify bash syntax using `bash -n <script_name>.sh`.
   - Ensure color output helpers (`info`, `success`, `warn`, `error`) are properly invoked.
   - Ensure configuration files are created with safe backup handling.
