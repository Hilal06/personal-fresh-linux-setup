<div align="center">

# ⚡ Personal Fresh Linux Setup
### Modern, Modular & Aesthetic Post-Installation Automation Suite

[![Fedora 44](https://img.shields.io/badge/Fedora-44%20KDE%20Plasma-blue?style=for-the-badge&logo=fedora&logoColor=white)](https://fedoraproject.org/)
[![Zsh & Starship](https://img.shields.io/badge/Shell-Zsh%20%2B%20Starship-orange?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://starship.rs/)
[![ASUS ROG & TUF](https://img.shields.io/badge/Hardware-ASUS%20ROG%20%2F%20TUF-red?style=for-the-badge&logo=asus&logoColor=white)](https://asus-linux.org/)
[![Charm Gum TUI](https://img.shields.io/badge/Interface-Charm%20Gum%20TUI-pink?style=for-the-badge&logo=terminal&logoColor=white)](https://github.com/charmbracelet/gum)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Automasi bootstrap sistem Linux modular berorientasi developer dengan TUI interaktif, akselerasi hardware penuh, optimasi ZRAM & DNF, integrasi hardware ASUS ROG/TUF, dan lingkungan terminal modern.</b>
</p>

---

</div>

## 🌌 Fitur Unggulan (Highlights)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                             FEDORA KDE 44 SETUP                             │
│                      Personal System Setup & Automation                     │
└─────────────────────────────────────────────────────────────────────────────┘
  [x] Setup Shell & Terminal (Zsh, Starship, FiraCode & Konsole Font)
  [x] Install System Essentials (Codecs, VA-API, Btrfs Assistant & Sysctl Tuning)
  [x] Install Aplikasi RPM (VSCode, Docker, Antigravity CLI/IDE, EasyEffects)
  [x] Install Aplikasi Flatpak (ONLYOFFICE, Spotube, Discord, Pika Backup)
  [x] Setup & Konfigurasi ASUS ROG / TUF Utilities (Battery 80%, GPU Switch)
  [x] System Maintenance & Health Check (Hardware status & clean rollback)
```

- 🎨 **Interaktif Terminal UI**: Menu multi-select modern bertenaga [Charmbracelet Gum](https://github.com/charmbracelet/gum).
- ⚡ **Optimasi Kecepatan DNF**: Otomatis menyuntikkan `max_parallel_downloads=10`, `fastestmirror=True`, dan `defaultyes=True`.
- ⌨️ **Terminal Modern & Font Otomatis**:
  - Zsh dengan `zsh-autosuggestions`, `zsh-syntax-highlighting`, autocompletions, dan prompt [Starship](https://starship.rs/).
  - Deteksi dan instalasi otomatis **FiraCode Nerd Font** resmi dari GitHub.
  - Skrip otomatis mengonfigurasi profil **KDE Konsole** agar langsung mengenali font dan ikon ligatur.
- 💻 **Integrasi Penuh ASUS ROG & TUF Gaming**:
  - Konfigurasi `asusctl`, `rog-control-center`, dan `supergfxctl`.
  - Pembatasan pengisian baterai **80% Battery Health Care**.
  - Pintasan GPU Switching (`Hybrid`, `Integrated`, `AsusMuxDgpu`) dan profil kipas (`Quiet`, `Balanced`, `Performance`).
- 🎛️ **Kernel & Sysctl Desktop Tuning**:
  - Optimasi memori ZRAM (`vm.swappiness=180` & `vm.vfs_cache_pressure=50`).
  - Peningkatan file watcher inotify (`524288`) untuk kestabilan Node.js, Docker, dan VSCode/IDE.
- 🛡️ **Btrfs Assistant & Snapper Snapshot**:
  - Pembuatan snapshot root (`/`) otomatis dan timer maintenance berkala.
- 🔄 **Safe Dotfiles Backup & Instant Rollback**:
  - Backup terpusat ke `~/.dotfiles_backup/` dengan utilitas pemulihan sekali klik.
- 🚀 **Developer Ready**:
  - Wizard interaktif Git identity (nama/email) dan generator SSH Key `ed25519` siap pasang ke GitHub.
  - Pilihan mandiri: Google Antigravity (CLI `agy` & IDE), VSCode, Docker, Podman Desktop, Bruno, DBeaver, dll.

---

## 📁 Struktur Direktori Proyek

```text
personal-fresh-linux-setup/
├── fedora-setup/
│   ├── setup.sh                 # 🚀 Entry point utama (TUI Launcher)
│   ├── README.md                # Dokumentasi spesifik Fedora
│   ├── scripts/
│   │   ├── env.sh               # Repositori (RPM Fusion, Flathub) & DNF optimizer
│   │   ├── setup_terminal.sh    # Shell, CLI tools, FiraCode & font Konsole
│   │   ├── system_essentials.sh # Codecs, Hardware Acceleration, Btrfs & Sysctl
│   │   ├── asus_setup.sh        # Kontrol baterai, kipas & GPU laptop ASUS
│   │   ├── maintenance.sh       # Health check sistem, diagnostik & rollback dotfiles
│   │   ├── rpm_apps.sh          # Menu seleksi aplikasi RPM (Antigravity, VSCode, Docker)
│   │   └── flatpak_apps.sh      # Menu seleksi aplikasi Flatpak (ONLYOFFICE, Spotube)
│   ├── configs/
│   │   ├── .zshrc               # Konfigurasi Zsh + Pintasan kontrol ASUS/GPU
│   │   └── starship.toml        # Tema dan prompt Starship
│   └── docs/
│       └── software-development-list.txt # Daftar inventaris software sistem
├── scripts/
│   └── git-sync.sh              # 🤖 Otomasi Commit, Changelog & Push ke GitHub
├── .agents/
│   ├── hooks.json               # 🛡️ Lifecycle hooks: Syntax guard & secret leak blocker
│   └── skills/                  # Kumpulan SOP & skill otomasi testing AI
├── CHANGELOG.md                 # 📜 Catatan riwayat pembaruan otomatis
└── .gitignore                   # Proteksi keamanan token & file environment
```

---

## ⚡ Instalasi Cepat (One-Liner)

Jalankan perintah berikut di terminal Anda:

```bash
git clone https://github.com/Hilal06/personal-fresh-linux-setup.git && cd personal-fresh-linux-setup/fedora-setup && chmod +x setup.sh && ./setup.sh
```

---

## 🤖 Otomasi Git Sync & Changelog

Proyek ini dilengkapi alat otomasi sinkronisasi [scripts/git-sync.sh](scripts/git-sync.sh) yang otomatis mencatat riwayat perubahan file ke [CHANGELOG.md](CHANGELOG.md):

```bash
# Jalankan dengan prompt interaktif:
./scripts/git-sync.sh

# Atau langsung berikan pesan commit:
./scripts/git-sync.sh "feat(terminal): update starship prompt color palette"
```

*Skrip otomatis melakukan validasi kebocoran secret, mencatat diff file yang berubah beserta timestamp ke `CHANGELOG.md`, lalu melakukan `git commit` dan `git push origin main`.*

---

## 📜 Lisensi & Kontribusi
Dilisensikan di bawah [MIT License](LICENSE). Bebas dipakai dan disesuaikan untuk konfigurasi workstation Anda!
