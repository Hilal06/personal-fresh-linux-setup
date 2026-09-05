# 📜 Changelog

Dokumentasi riwayat pembaruan dan otomasi commit proyek `personal-fresh-linux-setup`.

---

### 🚀 [2026-09-05 13:43:00] - refactor: rename directory fedora-setup to linux-setup and update all references

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Highlights**:
  - **Directory Rename**: Renamed core suite folder `fedora-setup/` to `linux-setup/` for distro-agnostic clarity.
  - **Refactor Callers & Paths**: Updated entry point references in `install.sh`, `README.md`, `linux-setup/README.md`, and `AGENTS.md`.
  - **CI/CD & Testing Matrix**: Updated `.github/workflows/ci.yml` and `.agents/skills/docker-sandbox-test/SKILL.md`.
  - **Guard Hooks**: Updated `.agents/hooks.json` syntax validation hook.
  - **Verification**: Fully verified with ShellCheck, `bash -n`, Fedora & Ubuntu Docker container tests, and Arch rejection test.
- **Files Changed**:
  - R fedora-setup/ -> linux-setup/
  - M .agents/hooks.json
  - M .agents/skills/docker-sandbox-test/SKILL.md
  - M .github/workflows/ci.yml
  - M AGENTS.md
  - M README.md
  - M install.sh
  - M linux-setup/README.md

### 🚀 [2026-09-05 13:10:00] - feat(multi-distro): add Ubuntu support, purge Arch, add interactive dotfiles rollback & CI/CD pipeline

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Highlights**:
  - **Multi-Distro Support**: Added native support for **Ubuntu (KDE & GNOME)** alongside **Fedora Workstation** (`apt` and `dnf`).
  - **Purge Arch Linux / Pacman**: Strictly removed all `pacman` references and added graceful rejection guards in `env.sh` and `install.sh`.
  - **Interactive Dotfiles Rollback**: Upgraded `maintenance.sh` with timestamped snapshot rollback for `.zshrc` and `starship.toml` with pre-restore safety backups.
  - **Modular Git & SSH Setup**: Extracted standalone `git_ssh_setup.sh` featuring interactive user configuration, ed25519 generation, and Wayland/X11 clipboard integration (`wl-copy`/`xclip`).
  - **Terminal Font Auto-Config**: Added GNOME Terminal profile font setter (`gsettings`) alongside KDE Konsole (`kwriteconfig`).
  - **Typo Fixes**: Corrected all instances of "Utillity" to "Utility" in banners, one-liner web installer, and documentation.
  - **Automated CI/CD**: Added GitHub Actions workflow (`.github/workflows/ci.yml`) featuring ShellCheck static analysis, `bash -n` validation, Docker test matrix (`fedora:latest` & `ubuntu:24.04`), and Arch rejection assertions.
- **Files Changed**:
  - M .agents/skills/docker-sandbox-test/SKILL.md
  - M .agents/skills/linux-setup-helper/SKILL.md
  - M AGENTS.md
  - M README.md
  - M fedora-setup/README.md
  - M fedora-setup/setup.sh
  - M fedora-setup/scripts/env.sh
  - M fedora-setup/scripts/setup_terminal.sh
  - M fedora-setup/scripts/maintenance.sh
  - M fedora-setup/scripts/rpm_apps.sh
  - M fedora-setup/scripts/system_essentials.sh
  - M fedora-setup/scripts/asus_setup.sh
  - M install.sh
  - A fedora-setup/scripts/git_ssh_setup.sh
  - A .github/workflows/ci.yml
  - D .github/workflows/shellcheck.yml

### 🚀 [2026-09-04 14:48:11] - feat: add post-install cleanup prompt and replace HTOP with BTOP only

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Files Changed**:
  -  M fedora-setup/docs/software-development-list.txt
  -  M fedora-setup/scripts/rpm_apps.sh
  -  M install.sh

### 🚀 [2026-09-04 14:24:36] - feat: add one-liner web installer (install.sh) for instant curl execution

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Files Changed**:
  -  M README.md
  -  M fedora-setup/README.md
  - ?? install.sh

### 🚀 [2026-09-04 14:22:01] - docs: update README.md with centered bigtext banner frame and bigtext.txt config

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Files Changed**:
  -  M README.md
  -  M fedora-setup/README.md

### 🚀 [2026-09-04 14:16:08] - style(tui): enclose bigtext inside centered Fresh Fedora KDE Utillity frame

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Files Changed**:
  -  M fedora-setup/setup.sh

### 🚀 [2026-09-04 14:12:27] - style(tui): add bigtext header, update title to Fresh Fedora KDE Utillity, and beautify banners

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Files Changed**:
  -  M fedora-setup/scripts/asus_setup.sh
  -  M fedora-setup/scripts/flatpak_apps.sh
  -  M fedora-setup/scripts/rpm_apps.sh
  -  M fedora-setup/scripts/setup_terminal.sh
  -  M fedora-setup/scripts/system_essentials.sh
  -  M fedora-setup/setup.sh
  - ?? bigtext
  - ?? fedora-setup/configs/bigtext.txt

### 🚀 [2026-09-04 13:56:45] - docs: add aesthetic dev-ish README.md, changelog automation, and gsync alias

- **Author**: Rifaul <rifaulhilal06@gmail.com>
- **Branch**: main
- **Files Changed**:
  -  M fedora-setup/configs/.zshrc
  - ?? README.md
  - ?? scripts/
