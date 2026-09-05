#!/usr/bin/env bash
# ==============================================================================
# Fresh Linux Setup Suite - Main Interactive CLI Dashboard
# ==============================================================================

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Pastikan script di dalam direktori scripts executable
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# 1. Load helper functions & pastikan gum terpasang
source "$SCRIPT_DIR/scripts/env.sh"

# Minta kredensial sudo di awal secara interaktif agar tidak membekukan gum spin di latar belakang
sudo -v

# 2. Bersihkan terminal dan inisialisasi repositori awal
clear
echo ""
gum spin --spinner dot --title "Menyiapkan repositori & environment sistem..." -- bash -c "source '$SCRIPT_DIR/scripts/env.sh' && setup_environment_repos"

# 3. Deteksi Informasi Sistem untuk Dashboard Header
DISTRO_NAME="Linux"
if [ -f /etc/os-release ]; then
    DISTRO_NAME="$(. /etc/os-release && echo "${PRETTY_NAME:-$NAME}")"
fi
CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-Terminal}}"
KERNEL_VER="$(uname -r)"
HOST_NAME="$(hostname 2>/dev/null || uname -n)"
SYS_USER="${USER:-$(whoami)}"

# 4. Main Interactive Navigation Loop
while true; do
    clear
    echo ""

    # Banner Header Modern TUI
    gum style \
        --foreground 212 --border-foreground 212 --border rounded \
        --align center --width 68 --margin "0 1 1 1" --padding "1 2" --bold \
        "$(gum style --foreground 39 --bold '█░█ █ █░░ ▄▀█ █░░ █▀█ █▄▄')" \
        "$(gum style --foreground 39 --bold '█▀█ █ █▄▄ █▀█ █▄▄ █▄█ █▄█')" \
        "" \
        "Fresh Linux Setup Suite" \
        "Personal System Setup & Automation Dashboard" \
        "" \
        "$(gum style --foreground 245 --faint "OS: $DISTRO_NAME ($CURRENT_DESKTOP) • Kernel: $KERNEL_VER")" \
        "$(gum style --foreground 245 --faint "User: $SYS_USER@$HOST_NAME • Distro Target: ${DISTRO_TYPE^^}")"

    echo ""
    gum style --foreground 245 " [↑/↓] Navigasi Pilihan • [Enter] Buka Modul • [Esc] Keluar"

    CHOICE=$(gum choose \
        --cursor="❯ " \
        --cursor.foreground="212" \
        --header="Pilih modul yang ingin Anda konfigurasi:" \
        "💻  Setup Shell & Terminal (Zsh, Starship, Dotfiles)" \
        "⚡  Install System Essentials & Media Codecs" \
        "📦  Install Aplikasi Sistem Native (DNF / APT)" \
        "🚀  Install Aplikasi Flatpak (Flathub)" \
        "🎮  Setup & Konfigurasi ASUS ROG / TUF Utilities" \
        "🔑  Setup Identitas Git & SSH Key Developer" \
        "🩺  System Maintenance & Health Check (Rollback Dotfiles)" \
        "────────────────────────────────────────────────────────────" \
        "🚪  Keluar / Selesai" || true)

    # Tangani pembatalan, Esc, atau pemilihan Keluar
    if [ -z "$CHOICE" ] || [[ "$CHOICE" == *"Keluar / Selesai"* ]] || [[ "$CHOICE" == *"────"* ]]; then
        clear
        echo ""
        gum style \
            --foreground 82 --border-foreground 82 --border rounded \
            --align center --width 64 --padding "1 2" --bold \
            "🎉 TERIMA KASIH TELAH MENGGUNAKAN FRESH LINUX SETUP!" \
            "Semua perubahan tersimpan aman. Selamat berkarya!"
        echo ""
        exit 0
    fi

    # Eksekusi modul yang dipilih
    case "$CHOICE" in
        "💻  Setup Shell & Terminal"*)
            "$SCRIPT_DIR/scripts/setup_terminal.sh" || true
            ;;
        "⚡  Install System Essentials"*)
            "$SCRIPT_DIR/scripts/system_essentials.sh" || true
            ;;
        "📦  Install Aplikasi Sistem Native"*)
            "$SCRIPT_DIR/scripts/rpm_apps.sh" || true
            ;;
        "🚀  Install Aplikasi Flatpak"*)
            "$SCRIPT_DIR/scripts/flatpak_apps.sh" || true
            ;;
        "🎮  Setup & Konfigurasi ASUS ROG"*)
            "$SCRIPT_DIR/scripts/asus_setup.sh" || true
            ;;
        "🔑  Setup Identitas Git & SSH Key"*)
            "$SCRIPT_DIR/scripts/git_ssh_setup.sh" || true
            ;;
        "🩺  System Maintenance & Health Check"*)
            "$SCRIPT_DIR/scripts/maintenance.sh" || true
            ;;
    esac

    # Prompt kembali ke menu utama
    echo ""
    gum style --foreground 245 " Tekan [Enter] untuk kembali ke Menu Utama..."
    read -r -s -d $'\n' < /dev/tty 2>/dev/null || read -r -s -n 1 2>/dev/null || true
done
