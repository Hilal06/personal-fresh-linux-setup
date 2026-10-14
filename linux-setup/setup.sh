#!/usr/bin/env bash
# ==============================================================================
# Fresh Linux Setup Suite - Main Interactive CLI Dashboard
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Pastikan script di dalam direktori scripts executable
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# 1. Load helper functions & pastikan gum terpasang
source "$SCRIPT_DIR/scripts/env.sh"

CLI_LANG=""
CLI_CHECK=false
CLI_PROFILE=""

show_help() {
    cat << EOF
Fresh Linux Setup Suite
Usage: ./linux-setup/setup.sh [OPTIONS]

Options:
  -h, --help                Tampilkan pesan bantuan ini / Show this help message
  --lang <id|en>            Tentukan bahasa langsung / Set language directly
  --check, --dry-run        Jalankan pre-flight checks tanpa instalasi / Run preflight checks
  --profile <name>          Jalankan profil preset langsung / Run specific preset profile:
                            (minimal, workstation, gaming, asus)
  --list-profiles           Tampilkan daftar profil preset / List available profiles
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --lang)
            CLI_LANG="$2"
            shift 2
            ;;
        --lang=*)
            CLI_LANG="${1#*=}"
            shift
            ;;
        --check|--dry-run)
            CLI_CHECK=true
            shift
            ;;
        --profile)
            CLI_PROFILE="$2"
            shift 2
            ;;
        --profile=*)
            CLI_PROFILE="${1#*=}"
            shift
            ;;
        --list-profiles)
            echo "Available profiles / Profil tersedia:"
            echo "  - minimal     : Minimal Developer (Zsh, Dev Tools, fnm/Node, uv/Python, Docker, Neovim)"
            echo "  - workstation : Full Workstation (Dev Tools, Codecs, VA-API, Snapper, Office, GUI Apps)"
            echo "  - gaming      : Gaming & Creator (Codecs, Steam, Discord, OBS, GameMode, MangoHud)"
            echo "  - asus        : ASUS ROG / TUF Suite (Dev Tools, Codecs, asusctl, supergfxctl)"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

if [ -n "$CLI_LANG" ]; then
    export SETUP_LANG="$CLI_LANG"
    mkdir -p "${LOG_DIR:-$HOME/.cache/fresh-linux-setup}" 2>/dev/null || true
    echo "$SETUP_LANG" > "${LOG_DIR:-$HOME/.cache/fresh-linux-setup}/.setup_lang" 2>/dev/null || true
    chmod 600 "${LOG_DIR:-$HOME/.cache/fresh-linux-setup}/.setup_lang" 2>/dev/null || true
fi

# Pre-flight Check Mode
if [ "$CLI_CHECK" = true ]; then
    run_preflight_checks
    exit 0
fi

# Direct Profile Execution Mode
if [ -n "$CLI_PROFILE" ]; then
    sudo -v
    bash -c "source '$SCRIPT_DIR/scripts/env.sh' && setup_environment_repos"
    bash "$SCRIPT_DIR/scripts/profiles.sh" --preset "$CLI_PROFILE"
    exit 0
fi

# Minta kredensial sudo di awal secara interaktif agar tidak membekukan gum spin di latar belakang
sudo -v

# 2. Layar Pemilihan Bahasa (Muncul jika belum ditentukan via CLI)
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
    mkdir -p "${LOG_DIR:-$HOME/.cache/fresh-linux-setup}" 2>/dev/null || true
    echo "$SETUP_LANG" > "${LOG_DIR:-$HOME/.cache/fresh-linux-setup}/.setup_lang" 2>/dev/null || true
    chmod 600 "${LOG_DIR:-$HOME/.cache/fresh-linux-setup}/.setup_lang" 2>/dev/null || true
}

if [ -z "$CLI_LANG" ]; then
    select_language
fi

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
        "🎯  $(_msg "Instalasi Berbasis Profil / Presets (Quick Setup)" "Profile-Based Setup / Presets (Quick Setup)")" \
        "💻  $(_msg "Setup Shell & Terminal (Zsh, Starship, Dotfiles)" "Setup Shell & Terminal (Zsh, Starship, Dotfiles)")" \
        "🛠️  $(_msg "Install Developer Runtimes (fnm/Node, uv/Python, Rust, Go)" "Install Developer Runtimes (fnm/Node, uv/Python, Rust, Go)")" \
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
        *"Profil"*|*"Preset"*)
            "$SCRIPT_DIR/scripts/profiles.sh" || true
            ;;
        *"Setup Shell & Terminal"*)
            "$SCRIPT_DIR/scripts/setup_terminal.sh" || true
            ;;
        *"Developer Runtimes"*)
            "$SCRIPT_DIR/scripts/dev_runtimes.sh" || true
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
