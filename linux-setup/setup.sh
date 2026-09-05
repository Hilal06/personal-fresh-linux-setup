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

# 2. Layar Pemilihan Bahasa (Muncul sebelum tampilan utama TUI)
select_language() {
    clear
    echo ""
    gum style \
        --foreground 212 --border-foreground 212 --border rounded \
        --align center --width 68 --margin "0 1 1 1" --padding "1 2" --bold \
        "$(gum style --foreground 39 --bold '█░█ █ █░░ ▄▀█ █░░ █▀█ █▄▄')" \
        "$(gum style --foreground 39 --bold '█▀█ █ █▄▄ █▀█ █▄▄ █▄█ █▄█')" \
        "" \
        "Fresh Linux Setup Suite" \
        "Language Selection • Pemilihan Bahasa"

    echo ""
    gum style --foreground 245 " [↑/↓] Select / Pilih • [Enter] Confirm / Konfirmasi"

    local LANG_CHOICE
    LANG_CHOICE=$(gum choose \
        --cursor="❯ " \
        --cursor.foreground="212" \
        --header="Choose your preferred language / Pilih bahasa yang digunakan:" \
        "🇮🇩  Bahasa Indonesia (Default)" \
        "🇬🇧  English (International)" || true)

    case "$LANG_CHOICE" in
        "🇬🇧  English"*)
            export SETUP_LANG="en"
            ;;
        *)
            export SETUP_LANG="id"
            ;;
    esac
    echo "$SETUP_LANG" > /tmp/.setup_lang 2>/dev/null || true
}

# Tampilkan pemilihan bahasa sebelum masuk dashboard utama
select_language

# 3. Bersihkan terminal dan inisialisasi repositori awal
clear
echo ""
gum spin --spinner dot --title "$(_msg "Menyiapkan repositori & environment sistem..." "Setting up system repositories & environment...")" -- bash -c "source '$SCRIPT_DIR/scripts/env.sh' && setup_environment_repos"

# 4. Deteksi Informasi Sistem untuk Dashboard Header
DISTRO_NAME="Linux"
if [ -f /etc/os-release ]; then
    DISTRO_NAME="$(. /etc/os-release && echo "${PRETTY_NAME:-$NAME}")"
fi
CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-Terminal}}"
KERNEL_VER="$(uname -r)"
HOST_NAME="$(hostname 2>/dev/null || uname -n)"
SYS_USER="${USER:-$(whoami)}"

# 5. Main Interactive Navigation Loop
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
        "$(_msg "Personal System Setup & Automation Dashboard" "Personal System Setup & Automation Dashboard")" \
        "" \
        "$(gum style --foreground 245 --faint "OS: $DISTRO_NAME ($CURRENT_DESKTOP) • Kernel: $KERNEL_VER")" \
        "$(gum style --foreground 245 --faint "User: $SYS_USER@$HOST_NAME • $(_msg "Distro Target" "Target Distro"): ${DISTRO_TYPE^^}")"

    echo ""
    gum style --foreground 245 "$(_msg " [↑/↓] Navigasi Pilihan • [Enter] Buka Modul • [Esc] Keluar" " [↑/↓] Navigate Options • [Enter] Open Module • [Esc] Exit")"

    CHOICE=$(gum choose \
        --cursor="❯ " \
        --cursor.foreground="212" \
        --header="$(_msg "Pilih modul yang ingin Anda konfigurasi:" "Select module to configure:")" \
        "💻  $(_msg "Setup Shell & Terminal (Zsh, Starship, Dotfiles)" "Setup Shell & Terminal (Zsh, Starship, Dotfiles)")" \
        "⚡  $(_msg "Install System Essentials & Media Codecs" "Install System Essentials & Media Codecs")" \
        "📦  $(_msg "Install Aplikasi Sistem Native (DNF / APT)" "Install Native System Apps (DNF / APT)")" \
        "🚀  $(_msg "Install Aplikasi Flatpak (Flathub)" "Install Flatpak Applications (Flathub)")" \
        "🎮  $(_msg "Setup & Konfigurasi ASUS ROG / TUF Utilities" "Setup & Configure ASUS ROG / TUF Utilities")" \
        "🔑  $(_msg "Setup Identitas Git & SSH Key Developer" "Setup Git Identity & Developer SSH Key")" \
        "🩺  $(_msg "System Maintenance & Health Check (Rollback Dotfiles)" "System Maintenance & Health Check (Rollback Dotfiles)")" \
        "🌐  $(_msg "Ganti Bahasa / Change Language (ID ⇄ EN)" "Change Language / Ganti Bahasa (EN ⇄ ID)")" \
        "────────────────────────────────────────────────────────────" \
        "🚪  $(_msg "Keluar / Selesai" "Exit / Done")" || true)

    # Tangani pembatalan, Esc, atau pemilihan Keluar
    if [ -z "$CHOICE" ] || [[ "$CHOICE" == *"Keluar"* ]] || [[ "$CHOICE" == *"Exit"* ]] || [[ "$CHOICE" == *"Done"* ]] || [[ "$CHOICE" == *"────"* ]]; then
        clear
        echo ""
        gum style \
            --foreground 82 --border-foreground 82 --border rounded \
            --align center --width 68 --padding "1 2" --bold \
            "$(_msg "🎉 TERIMA KASIH TELAH MENGGUNAKAN FRESH LINUX SETUP!" "🎉 THANK YOU FOR USING FRESH LINUX SETUP!")" \
            "$(_msg "Semua perubahan tersimpan aman. Selamat berkarya!" "All changes safely applied. Happy hacking!")"
        echo ""
        exit 0
    fi

    # Eksekusi modul yang dipilih
    case "$CHOICE" in
        *"Setup Shell & Terminal"*)
            "$SCRIPT_DIR/scripts/setup_terminal.sh" || true
            ;;
        *"System Essentials"*)
            "$SCRIPT_DIR/scripts/system_essentials.sh" || true
            ;;
        *"Aplikasi Sistem Native"*|*"Native System Apps"*)
            "$SCRIPT_DIR/scripts/rpm_apps.sh" || true
            ;;
        *"Aplikasi Flatpak"*|*"Flatpak Applications"*)
            "$SCRIPT_DIR/scripts/flatpak_apps.sh" || true
            ;;
        *"ASUS ROG"*)
            "$SCRIPT_DIR/scripts/asus_setup.sh" || true
            ;;
        *"Git & SSH"*)
            "$SCRIPT_DIR/scripts/git_ssh_setup.sh" || true
            ;;
        *"System Maintenance"*|*"Health Check"*)
            "$SCRIPT_DIR/scripts/maintenance.sh" || true
            ;;
        *"Change Language"*|*"Ganti Bahasa"*)
            select_language
            continue
            ;;
    esac

    # Prompt kembali ke menu utama
    echo ""
    gum style --foreground 245 "$(_msg " Tekan [Enter] untuk kembali ke Menu Utama..." " Press [Enter] to return to Main Menu...")"
    read -r -s -d $'\n' < /dev/tty 2>/dev/null || read -r -s -n 1 2>/dev/null || true
done
