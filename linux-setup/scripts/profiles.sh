#!/usr/bin/env bash
# ==============================================================================
# Quick Profile-Based Setup (Presets)
# Presets: Minimal Developer, Full Workstation, Gaming & Creator, ASUS ROG Suite
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# shellcheck source=linux-setup/scripts/env.sh
source "$SCRIPT_DIR/env.sh"

PRESET_ARG=""
while [ $# -gt 0 ]; do
    case "$1" in
        --preset|--profile)
            PRESET_ARG="$2"
            shift 2
            ;;
        --preset=*|--profile=*)
            PRESET_ARG="${1#*=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ -n "$PRESET_ARG" ]; then
    case "$PRESET_ARG" in
        minimal|min|dev)
            CHOSEN_PROFILE="Minimal Developer"
            ;;
        workstation|full)
            CHOSEN_PROFILE="Full Workstation"
            ;;
        gaming|game)
            CHOSEN_PROFILE="Gaming & Creator"
            ;;
        asus|rog|tuf)
            CHOSEN_PROFILE="ASUS ROG"
            ;;
        *)
            error "Preset tidak dikenal: $PRESET_ARG. Opsi: minimal, workstation, gaming, asus"
            ;;
    esac
else
    render_breadcrumb "$(_msg "Instalasi Berbasis Profil (Presets)" "Profile-Based Setup (Presets)")"

    gum style \
        --foreground 208 --border-foreground 208 --border rounded \
        --align center --width 64 --padding "1 2" --bold \
        "QUICK SETUP PROFILES & PRESETS" \
        "$(_msg "Otomasi Setup Cepat Sesuai Kebutuhan Anda" "Automated Setup Tailored to Your Workflow")"

    echo ""
    gum style --foreground 245 "$(_msg " [↑/↓] Pilih Profil • [Enter] Tinjau & Pasang • [Esc] Kembali" " [↑/↓] Select Profile • [Enter] Review & Install • [Esc] Back")"

    CHOSEN_PROFILE=$(gum choose \
        --cursor="❯ " \
        --cursor.foreground="208" \
        "$(_msg "⬅️   [Kembali ke Menu Utama]" "⬅️   [Back to Main Menu]")" \
        "💻  $(_msg "Minimal Developer (Terminal, Git/SSH, fnm/Node, uv/Python, Docker, Neovim)" "Minimal Developer (Terminal, Git/SSH, fnm/Node, uv/Python, Docker, Neovim)")" \
        "🎨  $(_msg "Full Workstation (Minimal Dev + Codecs, VA-API, Snapper, Office, GUI Apps)" "Full Workstation (Minimal Dev + Codecs, VA-API, Snapper, Office, GUI Apps)")" \
        "🎮  $(_msg "Gaming & Creator (Codecs, Steam, Discord, OBS, GameMode, MangoHud)" "Gaming & Creator (Codecs, Steam, Discord, OBS, GameMode, MangoHud)")" \
        "⚡  $(_msg "ASUS ROG / TUF Suite (Dev + Codecs + asusctl, supergfxctl, Battery Limit)" "ASUS ROG / TUF Suite (Dev + Codecs + asusctl, supergfxctl, Battery Limit)")" || true)

    if [ -z "$CHOSEN_PROFILE" ] || [[ "$CHOSEN_PROFILE" == *"Kembali"* ]] || [[ "$CHOSEN_PROFILE" == *"Back"* ]]; then
        info "$(_msg "Kembali ke Menu Utama..." "Returning to Main Menu...")"
        exit 0
    fi
fi

# Variabel pelacak eksekusi
TASKS_OK=0
TASKS_ERR=0

# Helper eksekusi tugas dengan tracking & logging
run_task() {
    local task_name="$1"
    shift
    info "$task_name..."
    if "$@" 2>&1 | tee -a "$LOG_FILE"; then
        success "$task_name $(_msg "selesai." "done.")"
        TASKS_OK=$((TASKS_OK + 1))
    else
        warn "$task_name $(_msg "mengalami kendala. Periksa log." "encountered an issue. Check log.")"
        TASKS_ERR=$((TASKS_ERR + 1))
    fi
}

case "$CHOSEN_PROFILE" in
    *"Minimal Developer"*)
        echo ""
        gum style --border rounded --padding "1 2" --width 64 --foreground 39 \
            "📋 PRESET: MINIMAL DEVELOPER" \
            "• Terminal Modern: Zsh, Starship, Plugins, FiraCode Font" \
            "• Dotfiles: ~/.zshrc & ~/.config/starship.toml" \
            "• Git Identity & Ed25519 SSH Key Setup" \
            "• Dev Tools: gcc, make, cmake, git, curl" \
            "• Runtimes: fnm (Node.js LTS) & uv (Python)" \
            "• Docker Engine & Docker Compose" \
            "• Fastfetch & Neovim"

        echo ""
        if ! gum confirm "$(_msg "Mulai eksekusi profil Minimal Developer sekarang?" "Start executing Minimal Developer profile now?")"; then
            info "$(_msg "Dibatalkan." "Cancelled.")"
            exit 0
        fi

        create_system_snapshot "Pre-Profile-Minimal-Developer"

        # 1. Terminal Tools & Font & Configs
        run_task "CLI Tools & Terminal" bash -c "source '$SCRIPT_DIR/setup_terminal.sh' && install_cli_tools && install_firacode_nerd_font && setup_plugins && deploy_starship_config && deploy_zshrc_config"

        # 2. Dev Build Tools
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            run_task "Build Tools (Fedora)" sudo dnf install -y gcc gcc-c++ make git curl wget cmake
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            run_task "Build Tools (Ubuntu)" sudo apt-get install -y build-essential gcc g++ make git curl wget cmake
        fi

        # 3. Developer Runtimes (fnm + uv)
        run_task "Developer Runtimes (fnm & uv)" bash -c "source '$SCRIPT_DIR/dev_runtimes.sh' && install_fnm_node && install_uv_python"

        # 4. Neovim & Fastfetch
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            run_task "Neovim & Fastfetch" sudo dnf install -y fastfetch neovim
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            run_task "Neovim & Fastfetch" sudo apt-get install -y neovim
        fi

        # 5. Docker Engine
        run_task "Docker Engine & Compose" bash -c "source '$SCRIPT_DIR/env.sh' && {
            if [ '$DISTRO_TYPE' = 'fedora' ]; then
                sudo dnf -y install dnf-plugins-core
                sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            elif [ '$DISTRO_TYPE' = 'ubuntu' ]; then
                sudo apt-get update -qq
                sudo apt-get install -y ca-certificates curl
                sudo install -m 0755 -d /etc/apt/keyrings
                sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                sudo chmod a+r /etc/apt/keyrings/docker.asc
                echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -qq
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            fi
            sudo systemctl enable --now docker || true
            sudo usermod -aG docker '$USER' || true
        }"

        # 6. Git & SSH Setup
        if [ -f "$SCRIPT_DIR/git_ssh_setup.sh" ]; then
            bash "$SCRIPT_DIR/git_ssh_setup.sh" || true
        fi

        show_execution_summary "$TASKS_OK" "$TASKS_ERR" "Minimal Developer Profile"
        ;;

    *"Full Workstation"*)
        echo ""
        gum style --border rounded --padding "1 2" --width 64 --foreground 45 \
            "📋 PRESET: FULL WORKSTATION" \
            "• Termasuk seluruh paket Minimal Developer" \
            "• Multimedia Codecs Lengkap (FFmpeg, GStreamer, libdvdcss)" \
            "• Hardware Video Acceleration (VA-API / Mesa Freeworld)" \
            "• Btrfs Assistant & Snapper System Restore" \
            "• Thermal & Performance Tuning (tuned / thermald)" \
            "• VS Code, BTop, BleachBit, EasyEffects, Flatseal" \
            "• Flatpaks: VLC, Spotube, ONLYOFFICE, Pika Backup"

        echo ""
        if ! gum confirm "$(_msg "Mulai eksekusi profil Full Workstation sekarang?" "Start executing Full Workstation profile now?")"; then
            info "$(_msg "Dibatalkan." "Cancelled.")"
            exit 0
        fi

        create_system_snapshot "Pre-Profile-Full-Workstation"

        # 1. Minimal Dev Foundation
        run_task "Terminal Workspace" bash -c "source '$SCRIPT_DIR/setup_terminal.sh' && install_cli_tools && install_firacode_nerd_font && setup_plugins && deploy_starship_config && deploy_zshrc_config"
        run_task "Developer Runtimes" bash -c "source '$SCRIPT_DIR/dev_runtimes.sh' && install_fnm_node && install_uv_python && install_rust && install_golang"

        # 2. System Essentials: Codecs & Acceleration
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            run_task "Multimedia Codecs (Fedora)" sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
            run_task "Hardware Acceleration (Fedora)" sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld --allowerasing || true
            run_task "Btrfs Assistant & Snapper" sudo dnf install -y btrfs-assistant snapper python3-dnf-plugin-snapper || true
            run_task "Tuned & Thermald" sudo dnf install -y tuned thermald preload || true
            sudo systemctl enable --now tuned thermald preload 2>/dev/null || true
            run_task "VS Code, BTop, BleachBit" sudo dnf install -y btop bleachbit easyeffects flatseal || true
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            run_task "Multimedia Codecs (Ubuntu)" sudo apt-get install -y ubuntu-restricted-extras libavcodec-extra ffmpeg || true
            run_task "Hardware Acceleration (Ubuntu)" sudo apt-get install -y va-driver-all vainfo mesa-va-drivers || true
            run_task "Snapper & Btrfs Utilities" sudo apt-get install -y snapper btrfs-progs || true
            run_task "Tuned & Thermald" sudo apt-get install -y thermald preload || true
            sudo systemctl enable --now thermald preload 2>/dev/null || true
            run_task "BTop, BleachBit" sudo apt-get install -y btop bleachbit || true
        fi

        # 3. Essential Flatpaks
        if command -v flatpak &>/dev/null; then
            run_task "Flatpak Essential Apps" flatpak install -y --noninteractive flathub \
                org.videolan.VLC \
                com.github.KRTirtho.Spotube \
                org.onlyoffice.desktopeditors \
                org.pika_backup.PikaBackup \
                org.localsend.localsend_app || true
        fi

        show_execution_summary "$TASKS_OK" "$TASKS_ERR" "Full Workstation Profile"
        ;;

    *"Gaming & Creator"*)
        echo ""
        gum style --border rounded --padding "1 2" --width 64 --foreground 196 \
            "📋 PRESET: GAMING & CREATOR" \
            "• Multimedia Codecs & Mesa Freeworld Hardware Acceleration" \
            "• Feral GameMode (gamemoded) & MangoHud GPU Overlay" \
            "• Steam & Discord (Flathub)" \
            "• OBS Studio (Live streaming & recording)" \
            "• VLC Media Player & Audio Plugins"

        echo ""
        if ! gum confirm "$(_msg "Mulai eksekusi profil Gaming & Creator sekarang?" "Start executing Gaming & Creator profile now?")"; then
            info "$(_msg "Dibatalkan." "Cancelled.")"
            exit 0
        fi

        create_system_snapshot "Pre-Profile-Gaming-Creator"

        # 1. Codecs & Acceleration
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            run_task "Multimedia Codecs" sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
            run_task "Mesa Freeworld" sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld --allowerasing || true
            run_task "GameMode & MangoHud" sudo dnf install -y gamemode mangohud vkBasalt || true
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            run_task "Multimedia Codecs" sudo apt-get install -y ubuntu-restricted-extras ffmpeg || true
            run_task "Hardware Acceleration" sudo apt-get install -y va-driver-all vainfo || true
            run_task "GameMode & MangoHud" sudo apt-get install -y gamemode mangohud || true
        fi

        # 2. Gaming & Creator Applications via Flatpak
        if command -v flatpak &>/dev/null; then
            run_task "Gaming & Streaming Apps" flatpak install -y --noninteractive flathub \
                com.valvesoftware.Steam \
                com.discordapp.Discord \
                com.obsproject.Studio \
                org.videolan.VLC || true
        fi

        show_execution_summary "$TASKS_OK" "$TASKS_ERR" "Gaming & Creator Profile"
        ;;

    *"ASUS ROG"*)
        echo ""
        gum style --border rounded --padding "1 2" --width 64 --foreground 201 \
            "📋 PRESET: ASUS ROG / TUF SUITE" \
            "• Minimal Developer Foundation" \
            "• System Essentials & Media Codecs" \
            "• asusctl & rog-control-center (Fan Curves, RGB, Profiles)" \
            "• supergfxctl (Hybrid GPU Switcher - Dedicated/Integrated)" \
            "• Battery Charge Limit Threshold Daemon (80% Battery Health)"

        echo ""
        if ! gum confirm "$(_msg "Mulai eksekusi profil ASUS ROG / TUF Suite sekarang?" "Start executing ASUS ROG / TUF Suite profile now?")"; then
            info "$(_msg "Dibatalkan." "Cancelled.")"
            exit 0
        fi

        create_system_snapshot "Pre-Profile-ASUS-ROG"

        # 1. Foundation
        run_task "Terminal & Shell" bash -c "source '$SCRIPT_DIR/setup_terminal.sh' && install_cli_tools && install_firacode_nerd_font && setup_plugins && deploy_starship_config && deploy_zshrc_config"

        # 2. ASUS ROG Stack
        if [ -f "$SCRIPT_DIR/asus_setup.sh" ]; then
            run_task "ASUS Utilities" bash -c "source '$SCRIPT_DIR/asus_setup.sh' && install_asus_packages && enable_asus_services"
        fi

        # 3. System Essentials
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            run_task "System Essentials (Fedora)" sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true
            sudo dnf install -y btop easyeffects tuned thermald || true
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            run_task "System Essentials (Ubuntu)" sudo apt-get install -y ubuntu-restricted-extras thermald btop || true
        fi

        show_execution_summary "$TASKS_OK" "$TASKS_ERR" "ASUS ROG / TUF Suite"
        ;;
esac
