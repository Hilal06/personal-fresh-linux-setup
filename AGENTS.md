# Project Rules & Agent Guidelines

## Repository Overview
`personal-fresh-linux-setup` is a repository containing automation scripts and configuration profiles to configure and bootstrap fresh Linux installations (primary focus on Fedora Workstation and Ubuntu KDE or GNOME) with modern CLI tools, development environments, and terminal configurations (Zsh, Starship, Zoxide, FZF, Bat, Eza, FD, etc.).

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
Only support **Fedora Workstation** and **Ubuntu (GNOME or KDE Plasma)**. **DO NOT support Arch-based distributions (`pacman`)**.
Always check for available package managers before executing installation commands:
* **DNF / RPM-based**: Fedora Workstation (`command -v dnf`)
* **APT / Debian-based**: Ubuntu (`command -v apt` / `command -v apt-get`)
* **Arch Linux / Pacman**: Strictly unsupported. Do not include pacman installation commands or Arch-specific branches.
* Provide fallback instructions or warnings if a package is not natively available in the default package manager repositories.

### 3. Modularity & Organization
* Keep individual setup domains organized (e.g. terminal setup, development tools, GUI applications).
* Maintain sync with [software-development-list.txt](file:///home/faulfedora/Documents/Script/personal-fresh-linux-setup/linux-setup/docs/software-development-list.txt) when adding or modifying installation modules.

### 4. Automatic Documentation Sync & Secret Safety
* **Software List & README Sync**: Whenever a new package or application is added to `rpm_apps.sh`, `flatpak_apps.sh`, or `system_essentials.sh`, always update `linux-setup/docs/software-development-list.txt` and `linux-setup/README.md`.
* **Zero Secret Leakage**: Never track or commit secret tokens, `.env`, `.backup`, or generated private keys (`.ssh/id_ed25519`). Always ensure `.gitignore` covers them.
