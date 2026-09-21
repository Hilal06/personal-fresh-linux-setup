<div align="center">

# ⚡ Personal Fresh Linux Setup
### Modern, Modular & Aesthetic Post-Installation Automation Suite

[![Fedora Workstation](https://img.shields.io/badge/Fedora-Workstation%20%2F%20KDE-blue?style=for-the-badge&logo=fedora&logoColor=white)](https://fedoraproject.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-KDE%20%2F%20GNOME-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-Unsupported%20%2F%20Blocked-lightgrey?style=for-the-badge&logo=archlinux&logoColor=grey)](https://archlinux.org/)
[![Shell](https://img.shields.io/badge/Shell-Zsh%20%2B%20Starship-orange?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://starship.rs/)
[![CI / CD](https://img.shields.io/badge/CI%2FCD-Multi--Distro%20Tested-green?style=for-the-badge&logo=githubactions&logoColor=white)](.github/workflows/ci.yml)
[![Interface](https://img.shields.io/badge/TUI-Charm%20Gum-pink?style=for-the-badge&logo=terminal&logoColor=white)](https://github.com/charmbracelet/gum)
[![Language: ID | EN](https://img.shields.io/badge/Language-ID%20%7C%20EN-blueviolet?style=for-the-badge)](README.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Otomasi bootstrap sistem Linux modular berorientasi developer untuk Fedora Workstation dan Ubuntu (KDE / GNOME) dengan antarmuka TUI interaktif, dukungan dwi-bahasa (English & Indonesian), akselerasi hardware, integrasi hardware ASUS ROG/TUF, dotfiles rollback instan, dan lingkungan terminal modern.</b>
</p>

---

</div>

## 🌌 Antarmuka Terminal & Menu Interaktif (TUI)

Berikut adalah dokumentasi tangkapan layar (screenshot) beresolusi tinggi (setengah layar / split view 960x1080) untuk setiap fitur antarmuka TUI interaktif:

<p align="center">
  <img src="screenshoots/01_language_selection.png" alt="Layar Pemilihan Bahasa" width="48%">
  <img src="screenshoots/02_main_dashboard.png" alt="Dashboard Utama" width="48%">
</p>

<p align="center">
  <img src="screenshoots/03_profiles_presets.png" alt="Presets Cepat & Profil Developer" width="48%">
  <img src="screenshoots/04_setup_terminal.png" alt="Setup Shell & Terminal" width="48%">
</p>

<p align="center">
  <img src="screenshoots/05_dev_runtimes.png" alt="Developer Runtimes" width="48%">
  <img src="screenshoots/06_system_essentials.png" alt="System Essentials & Codecs" width="48%">
</p>

<p align="center">
  <img src="screenshoots/07_rpm_apps.png" alt="Aplikasi Sistem Native" width="48%">
  <img src="screenshoots/08_flatpak_apps.png" alt="Aplikasi Flatpak" width="48%">
</p>

<p align="center">
  <img src="screenshoots/09_asus_setup.png" alt="ASUS ROG / TUF Utilities" width="48%">
  <img src="screenshoots/10_git_ssh_setup.png" alt="Git Identity & SSH Key" width="48%">
</p>

<p align="center">
  <img src="screenshoots/11_system_maintenance.png" alt="System Maintenance" width="48%">
  <img src="screenshoots/12_asus_settings_subscreen.png" alt="ASUS Hardware Settings" width="48%">
</p>

<p align="center">
  <img src="screenshoots/13_health_check_summary.png" alt="System Health Diagnostic" width="60%">
</p>

### 🎯 Detail Fitur & Profil

- **Quick Presets (`profiles.sh`)**:
  - 💻 **Minimal Developer**: Zsh, Starship, FiraCode Font, Dev Tools (gcc/make/cmake), `fnm` (Node LTS), `uv` (Python), Docker Engine & Compose, Neovim, Fastfetch, Git & SSH.
  - 🎨 **Full Workstation**: Minimal Dev + Codecs, VA-API, Snapper, Tuned/Thermald, VS Code, BTop, BleachBit, EasyEffects, Flatseal, dan Flatpaks (VLC, Spotube, ONLYOFFICE, Pika Backup).
  - 🎮 **Gaming & Creator**: Multimedia Codecs, Mesa Freeworld, Feral GameMode, MangoHud overlay, Steam, Discord, OBS Studio, VLC.
  - ⚡ **ASUS ROG / TUF Suite**: Minimal Dev + System Essentials + asusctl, supergfxctl, dan Battery Charge Limit 80%.
- **Modern Runtimes (`dev_runtimes.sh`)**:
  - `fnm` (Fast Node Manager) + Node.js LTS + pnpm
  - `uv` (Ultra-fast Astral Python Manager) + Python
  - `rustup` & `cargo`
  - `golang` official compiler & toolchain
  - Java OpenJDK LTS & PHP/Composer
- **Auto Btrfs & Timeshift Snapshot**: Membuat snapshot restore point otomatis sebelum eksekusi paket besar.
- **Centralized Logging**: Seluruh output proses dicatat ke `~/.cache/fresh-linux-setup/setup.log` dilengkapi kartu ringkasan status di akhir sesi.

### 📹 Perekaman Demo Terminal (Charm VHS)

Rekam demo navigasi terminal interaktif beresolusi tinggi secara otomatis menggunakan [Charm VHS](https://github.com/charmbracelet/vhs):

```bash
# Jalankan helper perekam VHS:
./scripts/record_demo.sh
```

---

## 📊 Tabel Dukungan Sistem Operasi (Support Matrix)

Skrip dirancang dan dioptimalkan secara spesifik hanya untuk ekosistem **Fedora Workstation** dan **Ubuntu (KDE / GNOME)**. Distribusi berbasis Arch Linux (`pacman`) diblokir secara otomatis demi mencegah ketidakcocokan dependensi.

| Distribusi | Desktop Environment | Status Dukungan | Package Manager | Versi Teruji | Catatan Utama |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Fedora Workstation** | GNOME 47 / 48 | <span style="color:#22c55e">●</span> **Penuh (Tier 1)** | `dnf` | Fedora 40, 41, Rawhide | Optimasi DNF, RPM Fusion Free/NonFree/Tainted, VA-API, Sysctl Tuning |
| **Fedora KDE Spin** | KDE Plasma 6 | <span style="color:#22c55e">●</span> **Penuh (Tier 1)** | `dnf` | Fedora 40, 41, Rawhide | Auto-konfigurasi font Konsole (`kwriteconfig6`), KCM Flatpak, Discover backend |
| **Ubuntu Desktop** | GNOME 46 / 47 | <span style="color:#22c55e">●</span> **Penuh (Tier 1)** | `apt` | 24.04 LTS, 22.04 LTS | Auto-konfigurasi font GNOME Terminal (`gsettings`), PPA Fastfetch, eza repo |
| **Kubuntu / Ubuntu KDE**| KDE Plasma 5.27 / 6 | <span style="color:#22c55e">●</span> **Penuh (Tier 1)** | `apt` | 24.04 LTS, 22.04 LTS | Auto-konfigurasi font Konsole (`kwriteconfig5/6`), KDE Connect integration |
| **Arch Linux / Manjaro** | Any DE | <span style="color:#ef4444">■</span> **Tidak Didukung** | `pacman` | N/A | Eksekusi diblokir otomatis dengan pesan error peringatan ramah |
| **Debian / Distro Lain** | Any DE | <span style="color:#eab308">▲</span> **Eksperimental** | `apt` | Sid / Testing | Sebagian modul APT dapat berjalan namun tidak dijamin penuh |

---

## ⚙️ Kebutuhan Sistem Minimum (System Requirements)

| Komponen | Spesifikasi Minimum | Rekomendasi Developer | Alasan & Kebutuhan |
| :--- | :--- | :--- | :--- |
| **Arsitektur** | `x86_64` (amd64) | `x86_64` (amd64) | Dukungan biner resmi Starship, VSCode, Docker, dan Flatpak |
| **Prosesor (CPU)** | Dual-Core 2.0 GHz | Quad-Core 3.0 GHz+ (Intel Core / AMD Ryzen) | Kompilasi package, font rendering, dan container Docker |
| **Memori (RAM)** | 4 GB | 8 GB – 16 GB+ | Multitasking IDE, Docker containers, dan efisiensi ZRAM |
| **Penyimpanan (Disk)** | 10 GB ruang kosong | 30 GB+ SSD (NVMe lebih disukai) | Menyimpan aplikasi Flatpak, container images, dan snapshot Btrfs |
| **Hak Akses** | Akun pengguna biasa | Akun dengan izin `sudo` tanpa password | Menjalankan instalasi paket sistem dan konfigurasi sysctl |
| **Koneksi Internet** | Broadband stabil (≥ 5 Mbps) | Fiber / High-speed (≥ 25 Mbps) | Mengunduh package RPM/APT, font Nerd Fonts, dan Flatpak runtime |
| **Terminal Emulator** | Terminal ANSI standar | Konsole (KDE) atau GNOME Terminal | Tampilan Charm Gum TUI, Unicode glyphs, dan warna 24-bit TrueColor |

---

## ⚡ Instalasi Cepat (One-Liner Web Installer)

Jalankan perintah berikut di terminal Anda untuk menjalankan utilitas secara instan **tanpa perlu clone manual**:

```bash
curl -fsSL https://raw.githubusercontent.com/Hilal06/personal-fresh-linux-setup/main/install.sh | bash
```

> [!NOTE]
> Installer web ini akan memverifikasi kesesuaian distribusi, mengunduh repositori ke direktori aman, menyiapkan dependensi awal (`curl`, `tar`, `git`), dan langsung meluncurkan menu TUI interaktif. Di akhir sesi, Anda akan diberikan opsi untuk membersihkan direktori temporary installer secara otomatis.

### Menjalankan Secara Manual (Local Clone)
Jika Anda lebih suka mengkloning repositori sendiri:

```bash
git clone https://github.com/Hilal06/personal-fresh-linux-setup.git
cd personal-fresh-linux-setup
./linux-setup/setup.sh
```

---

## 🚀 Fitur Unggulan (Core Features)

### 🌐 1. Dukungan Dwi-Bahasa Penuh (Bilingual English & Indonesian Support)
- **Interactive Language Selector Screen**: Layar pemilihan bahasa elegan bertenaga Charm Gum yang menyambut pengguna sebelum masuk ke menu utama (`🇮🇩 Bahasa Indonesia` & `🇬🇧 English`).
- **Real-Time Language Switcher**: Opsi `🌐 Ganti Bahasa / Change Language` di dashboard utama memungkinkan penggantian bahasa seketika kapan saja tanpa perlu me-restart skrip.
- **Zero External Dependencies**: Sistem lokalisasi internal via helper function `_msg "Teks ID" "English text"` yang terintegrasi langsung di `env.sh`, tanpa membutuhkan gettext atau paket eksternal.
- **Pre-configurable Environment Variable**: Otomasi atau pengguna non-interaktif dapat langsung menetapkan bahasa pilihan dengan `export SETUP_LANG=en` atau `export SETUP_LANG=id`.
- **Konsistensi Seluruh Modul**: Seluruh sub-menu, breadcrumb, subtitle, panduan keybinding, dialog konfirmasi, ringkasan diagnostik, hingga konfirmasi cleanup di `install.sh` diterjemahkan secara rapi dan profesional.

### 🎨 2. Terminal Modern & Shell Workspace
- **Zsh & Starship Prompt**: Konfigurasi Zsh modern dengan integrasi tema [Starship](https://starship.rs/).
- **Plugin Produktivitas**: `zsh-autosuggestions`, `zsh-syntax-highlighting`, dan `zsh-completions` terpasang otomatis.
- **CLI Modern Tools**: Menggantikan perintah klasik dengan versi modern berkecepatan tinggi:
  - `eza` (pengganti `ls` dengan glyph dan git status)
  - `bat` (pengganti `cat` dengan syntax highlighting dan line numbers)
  - `fd-find` (pengganti `find` berkecepatan tinggi)
  - `fzf` (fuzzy finder interaktif untuk file dan history navigasi)
  - `zoxide` (pengganti cerdas `cd` yang mengingat riwayat direktori)
- **Instalasi FiraCode Nerd Font Otomatis**: Deteksi font sistem dan unduhan langsung versi rilis resmi GitHub.
- **Auto-Config Font Terminal**: Otomatis menyetel font profil **KDE Konsole** (`kwriteconfig6/5`) dan **GNOME Terminal** (`gsettings`) ke `FiraCode Nerd Font 11` tanpa perlu klik manual.

### 🧭 3. Dashboard Loop & Navigasi Interaktif Modern
- **Persistent Navigation Loop**: `setup.sh` beroperasi dalam loop menu dinamis (`while true`) sehingga Anda bebas menjelajahi berbagai modul tanpa perlu memanggil ulang script dari awal.
- **Dynamic System Status Badge**: Menampilkan ringkasan sistem real-time (Distro, Desktop Environment KDE/GNOME, Kernel, User, dan Hostname).
- **Tombol Eksplisit `[⬅️ Kembali ke Menu Utama]`**: Diletakkan di baris pertama seluruh sub-menu agar pembatalan atau navigasi balik terasa intuitif.
- **Safe Esc & Cancel Handling**: Proteksi error handling (`|| true`) di seluruh antarmuka Gum, memastikan penekanan tombol `Esc` atau `Enter` kosong kembali ke menu utama dengan aman tanpa memicu crash `set -e` (exit code 130).
- **Breadcrumb Navigation Indicator**: Menampilkan jejak posisi menu aktif (misal: `🧭 Menu Utama > Aplikasi Flatpak (Flathub)`).
- **Modern Pointer & Styling**: Menggunakan cursor modern `❯ ` dengan pewarnaan modular untuk meningkatkan estetika visual.

### 🛠️ 4. Otomasi Identitas Git & SSH Key Developer
- **Git Identity Wizard**: Konfigurasi global nama (`user.name`), email (`user.email`), dan inisialisasi default branch `main`.
- **Generator Kunci SSH `ed25519`**: Membuat private & public key dengan enkripsi modern dan hak akses aman (`chmod 700` & `chmod 600`).
- **Integrasi Clipboard Otomatis**: Mendeteksi display server aktif dan langsung menyalin Public SSH Key ke clipboard:
  - Wayland: via `wl-copy`
  - X11: via `xclip`
- Tampilan Public Key berbingkai rapi dengan tautan langsung ke halaman pengaturan GitHub SSH Keys.

### 🔄 5. Safe Dotfiles Backup & Timestamped Rollback
- **Pencadangan Otomatis**: Setiap kali dotfiles (`~/.zshrc` dan `~/.config/starship.toml`) diperbarui, versi sebelumnya dicadangkan ke `~/.dotfiles_backup/` dengan format timestamp (`.backup.YYYYMMDDHHMMSS`).
- **Rollback Interaktif**: Menu pemulihan pada `maintenance.sh` memindai seluruh snapshot backup yang tersedia dan memungkinkan Anda memilih versi spesifik untuk di-restore via Charm Gum.
- **Safety Pre-Restore Snapshot**: Sebelum menimpa berkas konfigurasi aktif saat proses rollback, sistem membuat safety snapshot cadangan (`.pre_restore.YYYYMMDDHHMMSS`).

### 💻 6. Integrasi Hardware Laptop ASUS ROG / TUF Gaming
- Otomatis memasang `asusctl`, `rog-control-center`, dan `supergfxctl` (pada Fedora) atau memberikan panduan PPA komunitas resmi (pada Ubuntu).
- **80% Battery Care**: Mengaktifkan batas pengisian daya untuk memperpanjang usia baterai lithium-ion.
- **GPU Switching & Fan Profiles**: Menambahkan alias terminal praktis:
  - `asus-bat`: Cek info dan kesehatan baterai
  - `asus-quiet`, `asus-bal`, `asus-perf`: Ganti profil kipas dan daya
  - `gpu-hybrid`, `gpu-igpu`, `gpu-dgpu`: Ganti mode grafis laptop

### 🎛️ 7. Optimasi Sistem & Desktop Tuning
- **Optimasi Kecepatan DNF**: Otomatis menyuntikkan `max_parallel_downloads=10`, `fastestmirror=True`, dan `defaultyes=True` pada `/etc/dnf/dnf.conf`.
- **Tuning Kernel Sysctl**:
  - `vm.swappiness = 180` & `vm.vfs_cache_pressure = 50`: Memaksimalkan efisiensi kompresi memori ZRAM.
  - `fs.inotify.max_user_watches = 524288`: Mencegah crash file watcher pada Node.js, VSCode, Docker, dan Android Studio.
- **Btrfs Assistant & Snapper**: Konfigurasi otomatis snapshot sistem root (`/`) dengan timer pembersihan berkala.

### 📦 8. Ekosistem Aplikasi Native & Sandboxed
- **Aplikasi Native (DNF / APT)**:
  - Google Antigravity (CLI `agy` & IDE Desktop)
  - Visual Studio Code (Microsoft Official Repositories)
  - Docker Engine & Docker Compose (Docker Community Repositories)
  - Neovim, Fastfetch, Btop, BleachBit, EasyEffects, Flatseal
- **Aplikasi Sandboxed (Flathub / Flatpak)**:
  - ONLYOFFICE Desktop Editors, Spotube (Spotify Client), Discord, Thunderbird Mail, VLC, Pika Backup, DBeaver, Bruno API Client, Logseq, LocalSend, Podman Desktop, Arduino IDE.

### 🧪 9. Otomasi Pengujian, ShellCheck & CI/CD Pipeline
- Pipeline GitHub Actions bertenaga container [`.github/workflows/ci.yml`](.github/workflows/ci.yml) yang berjalan pada setiap push & pull request:
  - **Static Analysis**: ShellCheck memeriksa kepatuhan standar POSIX/Bash (100% lolos tanpa peringatan).
  - **Syntax Verification**: Pengujian `bash -n` pada semua berkas skrip shell.
  - **Multi-Distro Matrix**: Pengujian nyata di dalam container `fedora:latest` dan `ubuntu:24.04`.
  - **Arch Rejection Assertion**: Memastikan sistem Arch/pacman ditolak secara elegan tanpa merusak konfigurasi.

---

## 📁 Struktur Direktori Proyek

```text
personal-fresh-linux-setup/
├── linux-setup/
│   ├── setup.sh                 # 🚀 Entry point utama (Interactive TUI Launcher)
│   ├── README.md                # Dokumentasi spesifik modul setup
│   ├── scripts/
│   │   ├── env.sh               # Deteksi OS, centralized logging, & snapshot helper
│   │   ├── profiles.sh          # Quick Profiles & Presets installer
│   │   ├── setup_terminal.sh    # Setup Zsh, Starship, plugins, CLI tools, FiraCode & GNU Stow/Symlink
│   │   ├── dev_runtimes.sh      # Modern Runtimes (fnm, uv, rustup, go, java, php)
│   │   ├── git_ssh_setup.sh     # Setup Git user identity, ed25519 SSH key & clipboard
│   │   ├── system_essentials.sh # Multimedia codecs, hardware acceleration, Btrfs & tuning
│   │   ├── asus_setup.sh        # Setup ASUS ROG/TUF battery, fan profiles & GPU switcher
│   │   ├── maintenance.sh       # Diagnostik sistem, pembersihan cache, rollback & snapshot
│   │   ├── rpm_apps.sh          # Menu TUI instalasi aplikasi native sistem (DNF / APT)
│   │   ├── flatpak_apps.sh      # Menu TUI instalasi aplikasi sandboxed (Flathub)
│   │   └── zsh.sh               # Wrapper kompatibilitas ke setup_terminal.sh
│   ├── configs/
│   │   ├── .zshrc               # Dotfiles Zsh konfigurasi lengkap + custom aliases
│   │   ├── starship.toml        # Tema dan prompt estetis Starship
│   │   └── bigtext.txt          # ASCII Art Banner Header
│   └── docs/
│       └── software-development-list.txt # Inventaris software pendukung
├── assets/
│   └── vhs/
│       └── demo.tape            # Tape rekaman visual terminal Charm VHS
├── scripts/
│   ├── git-sync.sh              # 🤖 Otomasi Commit, Changelog & Push ke GitHub
│   └── record_demo.sh           # 📹 Generator rekaman demo terminal GIF via VHS
├── .github/
│   └── workflows/
│       └── ci.yml               # 🧪 GitHub Actions: ShellCheck, Docker Matrix & Tests
├── .agents/
│   ├── hooks.json               # 🛡️ Lifecycle hooks: Syntax guard & secret leak blocker
│   └── skills/                  # SOP otomasi testing container & maintenance skrip
├── CHANGELOG.md                 # 📜 Catatan riwayat pembaruan otomatis
├── install.sh                   # ⚡ One-liner web installer (curl | bash)
└── .gitignore                   # Proteksi keamanan token & file secret
```

---

## 📜 Riwayat Pembaruan Terkini (Latest Changelog Highlights)

Berikut adalah rangkuman pembaruan versi terbaru. Untuk riwayat selengkapnya, silakan baca berkas [CHANGELOG.md](CHANGELOG.md).

> ### ⚡ `v2026.09.08` - Presets, Developer Runtimes, Auto-Snapshot & VHS Showcase
> - **Quick Setup Profiles / Presets (`profiles.sh`)**: 4 profil instalasi cepat satu-klik (*Minimal Developer*, *Full Workstation*, *Gaming & Creator*, *ASUS ROG Suite*).
> - **Modern Developer Runtimes (`dev_runtimes.sh`)**: Manajemen runtime modern (`fnm` + Node LTS, `uv` + Python, `rustup` + Cargo, Go compiler, OpenJDK LTS, PHP/Composer).
> - **Auto Btrfs & Timeshift Snapshot**: Pembuatan snapshot pemulihan sistem otomatis sebelum eksekusi modul besar.
> - **Centralized Logging & Diagnostics (`setup.log`)**: Logging otomatis di `~/.cache/fresh-linux-setup/setup.log` beserta ringkasan kartu status.
> - **Fleksibilitas Dotfiles**: Dukungan salin fisik, direct symbolic link, dan integrasi GNU Stow.
> - **Charm VHS Recording Suite**: Setup rekaman demo GIF resolusi tinggi di `assets/vhs/demo.tape` & `scripts/record_demo.sh`.

> ### 🌐 `v2026.09.05` - Full Bilingual English & Indonesian TUI Support
> - **Language Selector Screen**: Layar pemilihan bahasa interaktif sebelum masuk ke tampilan utama dashboard (`select_language()`).
> - **In-Menu Language Switcher**: Opsi `🌐 Ganti Bahasa / Change Language` langsung di dashboard utama untuk pergantian bahasa instan.
> - **Complete Module Localization**: Seluruh modul (`system_essentials`, `rpm_apps`, `flatpak_apps`, `setup_terminal`, `git_ssh_setup`, `asus_setup`, `maintenance`, `install.sh`) kini sepenuhnya bilingual (Bahasa Indonesia & English).
> - **Lightweight `_msg()` Translation Engine**: Helper terpadu di `env.sh` dengan persistensi variabel `SETUP_LANG` antar-sesi proses.
> - **Interactive Navigation & Sub-Menu Back Flow**: Dashboard loop interaktif, tombol `[Kembali ke Menu Utama]`, penanganan tombol `Esc` aman (`|| true`), dan breadcrumb navigation.
> - **Linting ShellCheck 100% Clean**: Seluruh 12 skrip shell lolos static analysis ShellCheck tanpa error maupun warning.

---

## 🤖 Otomasi Git Sync & Changelog

Proyek ini dilengkapi alat otomasi sinkronisasi [scripts/git-sync.sh](scripts/git-sync.sh) yang secara otomatis mencatat riwayat perubahan file ke [CHANGELOG.md](CHANGELOG.md):

```bash
# Jalankan dengan antarmuka interaktif:
./scripts/git-sync.sh

# Atau langsung berikan pesan commit:
./scripts/git-sync.sh "feat(terminal): update starship prompt color palette"
```

*Skrip secara otomatis memeriksa potensi kebocoran token atau secret keys, mencatat diff file yang berubah beserta timestamp ke `CHANGELOG.md`, lalu melakukan `git commit` dan `git push origin main`.*

---

## 📜 Lisensi & Kontribusi

Dilisensikan di bawah [MIT License](LICENSE). Bebas digunakan, dimodifikasi, dan disesuaikan untuk kebutuhan personal workstation Anda!
