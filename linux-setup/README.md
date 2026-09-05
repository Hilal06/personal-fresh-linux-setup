# Linux Setup - Personal Setup & Automation Suite

Skrip otomasi modular untuk melakukan post-installation setup dan konfigurasi sistem operasi **Fedora Workstation** dan **Ubuntu (KDE / GNOME)**. Dibuat untuk mempercepat proses bootstrap sistem dengan instalasi package RPM/APT, Flatpak, dan konfigurasi terminal Zsh modern.

## 🚀 Fitur Utama
- **Interaktif TUI**: Menggunakan [Charmbracelet Gum](https://github.com/charmbracelet/gum) untuk tampilan menu interaktif yang estetik.
- **Modular & Fleksibel**: Skrip dipecah menjadi beberapa bagian (Environment, System Essentials & Codecs, Zsh, RPM Apps, Flatpak Apps).
- **Environment & Repositori**: Menambahkan RPM Fusion (Free, Non-Free, & Tainted) serta Flathub secara otomatis.
- **Multimedia & Codecs Lengkap**: Menginstal FFmpeg lengkap, GStreamer plugins, dan libdvdcss dari RPM Fusion.
- **Hardware Acceleration**: Mengonfigurasi driver akselerasi video hardware (VA-API / VDPAU Mesa Freeworld, Intel, AMD).
- **System Utilities & KDE Enhancements**: Peralatan kompresi (p7zip, unrar, tar, rsync), KDE Connect, dan integrasi Flatpak KCM.
- **Zsh & Dotfiles**: Mengonfigurasi Zsh dengan alias bermanfaat (`dnfup`, `ff`, `dco`) dan mengamankan dotfiles lama menggunakan sistem backup.
- **FiraCode Nerd Font**: Deteksi dan instalasi otomatis font FiraCode Nerd Font untuk mendukung glyph / simbol modern di Starship dan CLI tools.
- **ASUS ROG / TUF Gaming Setup**: Integrasi paket `asusctl`, `rog-control-center`, `supergfxctl`, manajemen batas pengisian baterai (Battery Care 80%), MUX GPU switcher, dan profil daya fan.
- **Btrfs Assistant & Snapper**: Manajemen snapshot Btrfs otomatis, restorasi sistem via GUI, subvolume overview, dan pemeliharaan filesystem.
- **Kernel & Sysctl Desktop Tuning**: Tuning efisiensi ZRAM (`swappiness=180`), `vfs_cache_pressure=50`, dan peningkatan kapasitas inotify handles (`524288`) untuk kestabilan Node.js/Docker/IDE.
- **Git Identity & SSH Key Generator**: Wizard konfigurasi nama/email global Git dan pembuatan SSH Key `ed25519` otomatis untuk GitHub/GitLab.
- **ASUS ROG/TUF & GPU Zsh Aliases**: Pintasan cepat di terminal untuk cek baterai (`asus-bat`), profil kipas (`asus-quiet`, `asus-bal`, `asus-perf`), dan switching GPU (`gpu-hybrid`, `gpu-igpu`, `gpu-dgpu`).
- **Optimasi Kecepatan DNF**: Otomatis mengatur `max_parallel_downloads=10`, `fastestmirror=True`, dan `defaultyes=True` pada `/etc/dnf/dnf.conf`.
- **Auto-Config Font Terminal**: Otomatis menyetel profil KDE Konsole dan GNOME Terminal ke `FiraCode Nerd Font`.
- **Safe Dotfiles Backup & Timestamped Rollback**: Backup terpusat ke direktori `~/.dotfiles_backup/` dengan opsi rollback riwayat backup berdasarkan timestamp secara interaktif.
- **System Maintenance & Health Check**: Skrip diagnostik untuk mengecek baterai, status GPU, memory/zram, service status, membersihkan cache paket lama, dan health check filesystem Btrfs.
- **Aplikasi Esensial & Produktivitas**: Pilihan cepat untuk menginstal Google Antigravity (CLI `agy` & IDE Desktop), ONLYOFFICE, Spotube, VLC, Pika Backup, Docker, VSCode, Neovim, Google Chrome, Discord, DBeaver, Bruno, dll.

## 📁 Struktur Direktori
```text
linux-setup/
├── setup.sh                 # Skrip eksekusi utama (Main Entry Point)
├── README.md                # Dokumentasi proyek
├── scripts/
│   ├── env.sh               # Konfigurasi repository (RPM Fusion, Flathub) & package manager check
│   ├── setup_terminal.sh    # Setup Zsh, Starship, plugins, CLI tools, FiraCode & font terminal
│   ├── git_ssh_setup.sh     # Setup Git user identity, ed25519 SSH key & clipboard integration
│   ├── zsh.sh               # Wrapper kompatibilitas ke setup_terminal.sh
│   ├── system_essentials.sh # Multimedia codecs, hardware acceleration, Btrfs & desktop tools
│   ├── asus_setup.sh        # Setup & konfigurasi ASUS ROG / TUF gaming tools
│   ├── maintenance.sh       # Diagnostik kesehatan sistem, pembersihan cache, & rollback dotfiles
│   ├── rpm_apps.sh          # Menu TUI instalasi aplikasi native (DNF / APT)
│   └── flatpak_apps.sh      # Menu TUI instalasi aplikasi via Flatpak
├── configs/
│   ├── .zshrc               # Dotfiles konfigurasi Zsh
│   ├── starship.toml        # Konfigurasi tema & prompt Starship
│   └── bigtext.txt          # ASCII Art Banner Header
└── docs/
    └── software-development-list.txt # Daftar referensi software & tools
```

## 🛠 Prasyarat Sistem
- **OS**: Fedora Workstation / KDE atau Ubuntu (KDE / GNOME). *Arch Linux tidak didukung.*
- **Koneksi Internet**: Diperlukan untuk mengunduh package
- **Hak Akses Sudo**: Pengguna saat ini harus memiliki hak eksekusi `sudo`

## ⚡ Instalasi Cepat (One-Liner Tanpa Manual Clone)

Jalankan perintah berikut di terminal Anda untuk mengeksekusi utilitas secara instan:

```bash
curl -fsSL https://raw.githubusercontent.com/Hilal06/personal-fresh-linux-setup/main/install.sh | bash
```

## 📝 Cara Menambahkan Aplikasi Baru
Skrip ini dirancang secara modular. Untuk menambahkan aplikasi:
1. **Aplikasi RPM**: Edit `scripts/rpm_apps.sh` dan tambahkan opsi di `gum choose`. Lalu, tambahkan `case` kondisi instalasi paketnya.
2. **Aplikasi Flatpak**: Edit `scripts/flatpak_apps.sh` dan tambahkan opsi beserta Application ID flathub pada blok `case`.

## 📜 Lisensi
Lisensi bebas pakai. Silakan modifikasi skrip ini sesuai kebutuhan produktivitas Anda!
