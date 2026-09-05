<div align="center">

# ⚡ Personal Fresh Linux Setup
### Modern, Modular & Aesthetic Post-Installation Automation Suite

[![Fedora Workstation](https://img.shields.io/badge/Fedora-Workstation%20%2F%20KDE-blue?style=for-the-badge&logo=fedora&logoColor=white)](https://fedoraproject.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-KDE%20%2F%20GNOME-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-Unsupported%20%2F%20Blocked-lightgrey?style=for-the-badge&logo=archlinux&logoColor=grey)](https://archlinux.org/)
[![Shell](https://img.shields.io/badge/Shell-Zsh%20%2B%20Starship-orange?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://starship.rs/)
[![CI / CD](https://img.shields.io/badge/CI%2FCD-Multi--Distro%20Tested-green?style=for-the-badge&logo=githubactions&logoColor=white)](.github/workflows/ci.yml)
[![Interface](https://img.shields.io/badge/TUI-Charm%20Gum-pink?style=for-the-badge&logo=terminal&logoColor=white)](https://github.com/charmbracelet/gum)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<p align="center">
  <b>Otomasi bootstrap sistem Linux modular berorientasi developer untuk Fedora Workstation dan Ubuntu (KDE / GNOME) dengan antarmuka TUI interaktif, akselerasi hardware, integrasi hardware ASUS ROG/TUF, dotfiles rollback instan, dan lingkungan terminal modern.</b>
</p>

---

</div>

## 🌌 Antarmuka Terminal & Menu Interaktif (TUI)

```text
╭──────────────────────────────────────────────────────────────────╮
│                   █░█ █ █░░ ▄▀█ █░░ █▀█ █▄▄                      │
│                   █▀█ █ █▄▄ █▀█ █▄▄ █▄█ █▄█                      │
│                                                                  │
│                     Fresh Linux Setup Suite                      │
│           Personal System Setup & Automation Dashboard           │
│                                                                  │
│       OS: Fedora Linux 44 (KDE Plasma) • Kernel: 6.13...         │
│             User: faulfedora@asus • Distro Target: FEDORA        │
╰──────────────────────────────────────────────────────────────────╯
 [↑/↓] Navigasi Pilihan • [Enter] Buka Modul • [Esc] Keluar

 ❯ 💻  Setup Shell & Terminal (Zsh, Starship, Dotfiles)
   ⚡  Install System Essentials & Media Codecs
   📦  Install Aplikasi Sistem Native (DNF / APT)
   🚀  Install Aplikasi Flatpak (Flathub)
   🎮  Setup & Konfigurasi ASUS ROG / TUF Utilities
   🔑  Setup Identitas Git & SSH Key Developer
   🩺  System Maintenance & Health Check (Rollback Dotfiles)
   ────────────────────────────────────────────────────────────
   🚪  Keluar / Selesai
```

### 🧭 Alur Sub-Menu & Tombol Kembali (Breadcrumb Navigation)

Setiap sub-menu dilengkapi breadcrumb pelacak hierarki dan opsi eksplisit `[⬅️ Kembali ke Menu Utama]` di baris teratas:

```text
🧭 Menu Utama > System Essentials & Media Codecs
╭────────────────────────────────────────────────────────────────╮
│                  SYSTEM ESSENTIALS & CODECS                    │
│       Multimedia, Btrfs Snapshots & Desktop Optimization       │
╰────────────────────────────────────────────────────────────────╯
 [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali

 ❯ • ⬅️   [Kembali ke Menu Utama]
   • Multimedia Codecs Lengkap (FFmpeg, GStreamer, libdvdcss, Audio/Video Extras)
   • Hardware Video Acceleration / Drivers (VA-API, Mesa Freeworld, Intel/AMD)
   • System Utilities & Compression (p7zip, unrar, tar, rsync, lshw, pciutils)
   • KDE Plasma Enhancements (KDE Connect, Flatpak KCM integration)
   • Btrfs Assistant & Snapper (GUI Snapshot, Maintenance, Subvolume Management)
   • System Performance & Thermal Tuning (thermald, tuned, preload)
   • Kernel & Sysctl Desktop Tuning (ZRAM Swappiness, File Watcher Handles)
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

### 🎨 1. Terminal Modern & Shell Workspace
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

### 🧭 2. Dashboard Loop & Navigasi Interaktif Modern
- **Persistent Navigation Loop**: `setup.sh` beroperasi dalam loop menu dinamis (`while true`) sehingga Anda bebas menjelajahi berbagai modul tanpa perlu memanggil ulang script dari awal.
- **Dynamic System Status Badge**: Menampilkan ringkasan sistem real-time (Distro, Desktop Environment KDE/GNOME, Kernel, User, dan Hostname).
- **Tombol Eksplisit `[⬅️ Kembali ke Menu Utama]`**: Diletakkan di baris pertama seluruh sub-menu agar pembatalan atau navigasi balik terasa intuitif.
- **Safe Esc & Cancel Handling**: Proteksi error handling (`|| true`) di seluruh antarmuka Gum, memastikan penekanan tombol `Esc` atau `Enter` kosong kembali ke menu utama dengan aman tanpa memicu crash `set -e` (exit code 130).
- **Breadcrumb Navigation Indicator**: Menampilkan jejak posisi menu aktif (misal: `🧭 Menu Utama > Aplikasi Flatpak (Flathub)`).
- **Modern Pointer & Styling**: Menggunakan cursor modern `❯ ` dengan pewarnaan modular untuk meningkatkan estetika visual.

### 🛠️ 3. Otomasi Identitas Git & SSH Key Developer
- **Git Identity Wizard**: Konfigurasi global nama (`user.name`), email (`user.email`), dan inisialisasi default branch `main`.
- **Generator Kunci SSH `ed25519`**: Membuat private & public key dengan enkripsi modern dan hak akses aman (`chmod 700` & `chmod 600`).
- **Integrasi Clipboard Otomatis**: Mendeteksi display server aktif dan langsung menyalin Public SSH Key ke clipboard:
  - Wayland: via `wl-copy`
  - X11: via `xclip`
- Tampilan Public Key berbingkai rapi dengan tautan langsung ke halaman pengaturan GitHub SSH Keys.

### 🔄 4. Safe Dotfiles Backup & Timestamped Rollback
- **Pencadangan Otomatis**: Setiap kali dotfiles (`~/.zshrc` dan `~/.config/starship.toml`) diperbarui, versi sebelumnya dicadangkan ke `~/.dotfiles_backup/` dengan format timestamp (`.backup.YYYYMMDDHHMMSS`).
- **Rollback Interaktif**: Menu pemulihan pada `maintenance.sh` memindai seluruh snapshot backup yang tersedia dan memungkinkan Anda memilih versi spesifik untuk di-restore via Charm Gum.
- **Safety Pre-Restore Snapshot**: Sebelum menimpa berkas konfigurasi aktif saat proses rollback, sistem membuat safety snapshot cadangan (`.pre_restore.YYYYMMDDHHMMSS`).

### 💻 5. Integrasi Hardware Laptop ASUS ROG / TUF Gaming
- Otomatis memasang `asusctl`, `rog-control-center`, dan `supergfxctl` (pada Fedora) atau memberikan panduan PPA komunitas resmi (pada Ubuntu).
- **80% Battery Care**: Mengaktifkan batas pengisian daya untuk memperpanjang usia baterai lithium-ion.
- **GPU Switching & Fan Profiles**: Menambahkan alias terminal praktis:
  - `asus-bat`: Cek info dan kesehatan baterai
  - `asus-quiet`, `asus-bal`, `asus-perf`: Ganti profil kipas dan daya
  - `gpu-hybrid`, `gpu-igpu`, `gpu-dgpu`: Ganti mode grafis laptop

### 🎛️ 6. Optimasi Sistem & Desktop Tuning
- **Optimasi Kecepatan DNF**: Otomatis menyuntikkan `max_parallel_downloads=10`, `fastestmirror=True`, dan `defaultyes=True` pada `/etc/dnf/dnf.conf`.
- **Tuning Kernel Sysctl**:
  - `vm.swappiness = 180` & `vm.vfs_cache_pressure = 50`: Memaksimalkan efisiensi kompresi memori ZRAM.
  - `fs.inotify.max_user_watches = 524288`: Mencegah crash file watcher pada Node.js, VSCode, Docker, dan Android Studio.
- **Btrfs Assistant & Snapper**: Konfigurasi otomatis snapshot sistem root (`/`) dengan timer pembersihan berkala.

### 📦 7. Ekosistem Aplikasi Native & Sandboxed
- **Aplikasi Native (DNF / APT)**:
  - Google Antigravity (CLI `agy` & IDE Desktop)
  - Visual Studio Code (Microsoft Official Repositories)
  - Docker Engine & Docker Compose (Docker Community Repositories)
  - Neovim, Fastfetch, Btop, BleachBit, EasyEffects, Flatseal
- **Aplikasi Sandboxed (Flathub / Flatpak)**:
  - ONLYOFFICE Desktop Editors, Spotube (Spotify Client), Discord, Thunderbird Mail, VLC, Pika Backup, DBeaver, Bruno API Client, Logseq, LocalSend, Podman Desktop, Arduino IDE.

### 🧪 8. Otomasi Pengujian, ShellCheck & CI/CD Pipeline
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
│   │   ├── env.sh               # Deteksi OS, repository environment & gum installer
│   │   ├── setup_terminal.sh    # Setup Zsh, Starship, plugins, CLI tools, FiraCode & font
│   │   ├── git_ssh_setup.sh     # Setup Git user identity, ed25519 SSH key & clipboard
│   │   ├── system_essentials.sh # Multimedia codecs, hardware acceleration, Btrfs & tuning
│   │   ├── asus_setup.sh        # Setup ASUS ROG/TUF battery, fan profiles & GPU switcher
│   │   ├── maintenance.sh       # Diagnostik sistem, pembersihan cache, & rollback dotfiles
│   │   ├── rpm_apps.sh          # Menu TUI instalasi aplikasi native sistem (DNF / APT)
│   │   ├── flatpak_apps.sh      # Menu TUI instalasi aplikasi sandboxed (Flathub)
│   │   └── zsh.sh               # Wrapper kompatibilitas ke setup_terminal.sh
│   ├── configs/
│   │   ├── .zshrc               # Dotfiles Zsh konfigurasi lengkap + custom aliases
│   │   ├── starship.toml        # Tema dan prompt estetis Starship
│   │   └── bigtext.txt          # ASCII Art Banner Header
│   └── docs/
│       └── software-development-list.txt # Inventaris software pendukung
├── scripts/
│   └── git-sync.sh              # 🤖 Otomasi Commit, Changelog & Push ke GitHub
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

> ### 🚀 `v2026.09.05` - Modern Interactive CLI Navigation & Sub-Menu Back Flow
> - **Interactive Dashboard Loop**: `setup.sh` kini beroperasi dalam loop menu dinamis tanpa langsung keluar, dilengkapi badge status sistem dinamis (OS, Desktop Environment, Kernel, Host & User).
> - **Tombol [Kembali ke Menu Utama]**: Menambahkan opsi kembali eksplisit di baris pertama seluruh modul sub-menu (`system_essentials.sh`, `rpm_apps.sh`, `flatpak_apps.sh`, `setup_terminal.sh`, `asus_setup.sh`, `git_ssh_setup.sh`, `maintenance.sh`).
> - **Safe Esc & Cancel Handling**: Proteksi graceful cancel (`|| true`) di semua dialog `gum choose` sehingga penekanan tombol `Esc` tidak lagi mentrigger abort shell `set -e`.
> - **Breadcrumb Navigasi & Modern Pointer**: Indikator lokasi menu hierarkis (`🧭 Menu Utama > Modul`), cursor modern `❯ `, serta bar panduan keybinding interaktif.
> - **Linting ShellCheck 100% Clean**: Seluruh skrip shell lolos static analysis ShellCheck tanpa error maupun warning.

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
