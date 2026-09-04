#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Pastikan script di dalam direktori scripts executable
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# 1. Load helper functions & pastikan gum terpasang
source "$SCRIPT_DIR/scripts/env.sh"

# Minta kredensial sudo di awal secara interaktif agar tidak membekukan gum spin di latar belakang
sudo -v

# 2. Bersihkan terminal dan tampilkan Header TUI langsung di awal
clear

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 60 --margin "1 2" --padding "1 4" \
	"FEDORA KDE 44 SETUP" "Personal System Setup & Automation"

# 3. Setup repository environment menggunakan spinner TUI (cepat & non-blocking)
gum spin --spinner dot --title "Menyiapkan konfigurasi DNF, RPM Fusion & Flathub..." -- bash -c "source '$SCRIPT_DIR/scripts/env.sh' && setup_environment_repos"

echo ""
info "Pilih tugas yang ingin Anda jalankan (Gunakan [Spasi] untuk memilih, [Enter] untuk konfirmasi):"

# 4. Top-Level Menu Interaktif TUI
CHOICES=$(gum choose --no-limit \
    "Setup Shell & Terminal (Zsh, Starship, Dotfiles)" \
    "Install System Essentials & Media Codecs" \
    "Install Aplikasi RPM (DNF / Official Repos)" \
    "Install Aplikasi Flatpak (Flathub)" \
    "Setup & Konfigurasi ASUS ROG / TUF Utilities" \
    "System Maintenance & Health Check")

if [ -z "$CHOICES" ]; then
    warn "Tidak ada tugas yang dipilih. Keluar..."
    exit 0
fi

# 5. Konversi pilihan ke array agar stdin (TTY) tidak terdistorsi untuk sub-menu interaktif
mapfile -t SELECTED_TASKS <<< "$CHOICES"

for task in "${SELECTED_TASKS[@]}"; do
    [ -z "$task" ] && continue
    case "$task" in
        "Setup Shell & Terminal (Zsh, Starship, Dotfiles)")
            echo ""
            gum style --foreground 99 --bold ">>> Menjalankan Setup Shell & Terminal..."
            "$SCRIPT_DIR/scripts/setup_terminal.sh"
            ;;
        "Install System Essentials & Media Codecs")
            echo ""
            gum style --foreground 99 --bold ">>> Menjalankan Instalasi System Essentials & Media Codecs..."
            "$SCRIPT_DIR/scripts/system_essentials.sh"
            ;;
        "Install Aplikasi RPM (DNF / Official Repos)")
            echo ""
            gum style --foreground 99 --bold ">>> Menjalankan Instalasi Aplikasi RPM..."
            "$SCRIPT_DIR/scripts/rpm_apps.sh"
            ;;
        "Install Aplikasi Flatpak (Flathub)")
            echo ""
            gum style --foreground 99 --bold ">>> Menjalankan Instalasi Aplikasi Flatpak..."
            "$SCRIPT_DIR/scripts/flatpak_apps.sh"
            ;;
        "Setup & Konfigurasi ASUS ROG / TUF Utilities")
            echo ""
            gum style --foreground 99 --bold ">>> Menjalankan Setup & Konfigurasi ASUS ROG / TUF Utilities..."
            "$SCRIPT_DIR/scripts/asus_setup.sh"
            ;;
        "System Maintenance & Health Check")
            echo ""
            gum style --foreground 99 --bold ">>> Menjalankan System Maintenance & Health Check..."
            "$SCRIPT_DIR/scripts/maintenance.sh"
            ;;
    esac
done

echo ""
gum style \
	--foreground 82 --border-foreground 82 --border rounded \
	--align center --width 60 --padding "1 2" \
	"SETUP SELESAI!" "Semua tugas yang dipilih berhasil dikonfigurasi."
