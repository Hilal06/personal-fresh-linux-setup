# Project Rules & Agent Guidelines

## Repository Overview
`personal-fresh-linux-setup` is a repository containing automation scripts and configuration profiles to configure and bootstrap fresh Linux installations (primary focus on Fedora, Debian/Ubuntu, and Arch Linux) with modern CLI tools, development environments, and terminal configurations (Zsh, Starship, Zoxide, FZF, Bat, Eza, FD, etc.).

---

## General Principles & Standards

### 1. Bash & Shell Scripting Standards
* **Interpreter**: Always use `#!/usr/bin/env bash`.
* **Safety & Error Handling**: Include `set -e` or handle errors explicitly.
* **Idempotency**: All setup scripts must be safe to execute multiple times without breaking existing configurations or duplicating content.
* **Config Backups**: When generating or replacing user configuration files in `~/.config/` or `$HOME`, always create timestamped backup files (e.g. `filename.backup.$(date +%Y%m%d%H%M%S)`).
* **Logging & Feedback**: Use structured, colorized terminal output functions:
  * `info()`: Informational messages (`[INFO]`)
  * `success()`: Successful actions (`[SUCCESS]`)
  * `warn()`: Non-critical warnings (`[WARN]`)
  * `error()`: Critical failures (`[ERROR]` + exit)

### 2. Multi-Distro Support & Detection
Always check for available package managers before executing installation commands:
* **DNF / RPM-based**: Fedora / RHEL (`command -v dnf`)
* **APT / Debian-based**: Ubuntu / Debian (`command -v apt`)
* **Pacman / Arch-based**: Arch Linux / EndeavourOS (`command -v pacman`)
* Provide fallback instructions or warnings if a package is not natively available in the default package manager repositories.

### 3. Modularity & Organization
* Keep individual setup domains organized (e.g. terminal setup, development tools, GUI applications).
* Maintain sync with [software-development-list.txt](file:///home/faulfedora/Documents/Script/personal-fresh-linux-setup/software-development-list.txt) when adding or modifying installation modules.
