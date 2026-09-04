#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

info "Pilih aplikasi berbasis Flatpak (Flathub) yang ingin diinstall (Spasi untuk memilih, Enter untuk konfirmasi):"

CHOICES=$(gum choose --no-limit \
    "Google Chrome" \
    "ONLYOFFICE Desktop Editors" \
    "Thunderbird Mail ESR" \
    "Discord" \
    "Spotube (Spotify Client)" \
    "VLC Media Player" \
    "Pika Backup" \
    "DBeaver Community" \
    "Bruno API Client" \
    "Logseq" \
    "LocalSend" \
    "Podman Desktop" \
    "Arduino IDE")

if [ -z "$CHOICES" ]; then
    info "Tidak ada aplikasi Flatpak yang dipilih."
    exit 0
fi

mapfile -t SELECTED_APPS <<< "$CHOICES"

for choice in "${SELECTED_APPS[@]}"; do
    [ -z "$choice" ] && continue
    case "$choice" in
        "Google Chrome")
            info "Menginstall Google Chrome..."
            sudo flatpak install -y flathub com.google.Chrome
            ;;
        "ONLYOFFICE Desktop Editors")
            info "Menginstall ONLYOFFICE Desktop Editors..."
            sudo flatpak install -y flathub org.onlyoffice.desktopeditors
            ;;
        "Thunderbird Mail ESR")
            info "Menginstall Thunderbird Mail ESR..."
            sudo flatpak install -y flathub org.mozilla.thunderbird_esr
            ;;
        "Discord")
            info "Menginstall Discord..."
            sudo flatpak install -y flathub com.discordapp.Discord
            ;;
        "Spotube (Spotify Client)")
            info "Menginstall Spotube..."
            sudo flatpak install -y flathub com.github.KRTirtho.Spotube
            ;;
        "VLC Media Player")
            info "Menginstall VLC Media Player..."
            sudo flatpak install -y flathub org.videolan.vlc
            ;;
        "Pika Backup")
            info "Menginstall Pika Backup..."
            sudo flatpak install -y flathub org.gnome.World.PikaBackup
            ;;
        "DBeaver Community")
            info "Menginstall DBeaver Community..."
            sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity
            ;;
        "Bruno API Client")
            info "Menginstall Bruno..."
            sudo flatpak install -y flathub usebruno.Bruno
            ;;
        "Logseq")
            info "Menginstall Logseq..."
            sudo flatpak install -y flathub com.logseq.Logseq
            ;;
        "LocalSend")
            info "Menginstall LocalSend..."
            sudo flatpak install -y flathub org.localsend.localsend_app
            ;;
        "Podman Desktop")
            info "Menginstall Podman Desktop..."
            sudo flatpak install -y flathub io.podman_desktop.PodmanDesktop
            ;;
        "Arduino IDE")
            info "Menginstall Arduino IDE..."
            sudo flatpak install -y flathub cc.arduino.IDE2
            ;;
    esac
done

success "Instalasi aplikasi Flatpak selesai."
