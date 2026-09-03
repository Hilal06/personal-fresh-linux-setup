#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Pastikan script lainnya executable
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# 1. Jalankan env.sh untuk setup dependensi & gum
source "$SCRIPT_DIR/scripts/env.sh"

# Clear terminal untuk tampilan TUI yang bersih
clear

# 2. Tampilkan Header dengan gum style
gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 60 --margin "1 2" --padding "2 4" \
	"FEDORA KDE 44 SETUP" "Personal System Setup & Automation"

info "Selamat datang di Fedora Setup. Silakan pilih tugas yang ingin dijalankan:"

# 3. Top-Level Menu
CHOICES=$(gum choose --no-limit \
    "Setup Shell (Zsh & Dotfiles)" \
    "Install System Essentials & Media Codecs" \
    "Install Aplikasi RPM (DNF / Official Repos)" \
    "Install Aplikasi Flatpak (Flathub)")

if [ -z "$CHOICES" ]; then
    warn "Tidak ada tugas yang dipilih. Keluar..."
    exit 0
fi

# Eksekusi dengan progres spinner palsu (agar sesuai estetika permintaan), atau jalankan skrip
echo "$CHOICES" | while read -r choice; do
    case "$choice" in
        "Setup Shell (Zsh & Dotfiles)")
            gum spin --spinner dot --title "Memulai Setup Shell..." -- sleep 1
            "$SCRIPT_DIR/scripts/zsh.sh"
            ;;
        "Install System Essentials & Media Codecs")
            gum spin --spinner dot --title "Memulai Instalasi System Essentials & Media Codecs..." -- sleep 1
            "$SCRIPT_DIR/scripts/system_essentials.sh"
            ;;
        "Install Aplikasi RPM (DNF / Official Repos)")
            gum spin --spinner dot --title "Memulai Instalasi Aplikasi RPM..." -- sleep 1
            "$SCRIPT_DIR/scripts/rpm_apps.sh"
            ;;
        "Install Aplikasi Flatpak (Flathub)")
            gum spin --spinner dot --title "Memulai Instalasi Aplikasi Flatpak..." -- sleep 1
            "$SCRIPT_DIR/scripts/flatpak_apps.sh"
            ;;
    esac
done

echo ""
success "================================================="
success "  Semua tugas yang dipilih telah selesai!"
success "================================================="
