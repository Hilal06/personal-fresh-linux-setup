#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

render_breadcrumb "$(_msg "System Essentials & Media Codecs" "System Essentials & Media Codecs")"

gum style \
    --foreground 141 --border-foreground 141 --border rounded \
    --align center --width 64 --padding "1 2" --bold \
    "SYSTEM ESSENTIALS & CODECS" "$(_msg "Multimedia, Btrfs Snapshots & Optimasi Desktop" "Multimedia, Btrfs Snapshots & Desktop Optimization")"

echo ""
gum style --foreground 245 "$(_msg " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali" " [↑/↓] Navigate • [Space] Toggle Selection • [Enter] Confirm • [Esc] Back")"

CHOICES=$(gum choose --no-limit \
    --cursor="❯ " \
    --cursor.foreground="141" \
    --selected.foreground="82" \
    "$(_msg "⬅️   [Kembali ke Menu Utama]" "⬅️   [Back to Main Menu]")" \
    "$(_msg "Multimedia Codecs Lengkap (FFmpeg, GStreamer, libdvdcss, Audio/Video Extras)" "Complete Multimedia Codecs (FFmpeg, GStreamer, libdvdcss, Audio/Video Extras)")" \
    "$(_msg "Hardware Video Acceleration / Drivers (VA-API, Mesa Freeworld, Intel/AMD)" "Hardware Video Acceleration / Drivers (VA-API, Mesa Freeworld, Intel/AMD)")" \
    "$(_msg "System Utilities & Compression (p7zip, unrar, tar, rsync, lshw, pciutils)" "System Utilities & Compression (p7zip, unrar, tar, rsync, lshw, pciutils)")" \
    "$(_msg "KDE Plasma Enhancements (KDE Connect, Flatpak KCM integration)" "KDE Plasma Enhancements (KDE Connect, Flatpak KCM integration)")" \
    "$(_msg "Btrfs Assistant & Snapper (GUI Snapshot, Maintenance, Subvolume Management)" "Btrfs Assistant & Snapper (GUI Snapshot, Maintenance, Subvolume Management)")" \
    "$(_msg "System Performance & Thermal Tuning (thermald, tuned, preload)" "System Performance & Thermal Tuning (thermald, tuned, preload)")" \
    "$(_msg "Kernel & Sysctl Desktop Tuning (ZRAM Swappiness, File Watcher Handles)" "Kernel & Sysctl Desktop Tuning (ZRAM Swappiness, File Watcher Handles)")" || true)

if [ -z "$CHOICES" ] || [[ "$CHOICES" == *"Kembali"* ]] || [[ "$CHOICES" == *"Back"* ]]; then
    info "$(_msg "Kembali ke Menu Utama..." "Returning to Main Menu...")"
    exit 0
fi

mapfile -t SELECTED_OPTS <<< "$CHOICES"

for choice in "${SELECTED_OPTS[@]}"; do
    [ -z "$choice" ] && continue
    case "$choice" in
        *"Multimedia Codecs"*)
            info "Menginstall Multimedia Codecs Lengkap..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                gum spin --spinner dot --title "Mengganti ffmpeg-free dengan full FFmpeg (RPM Fusion)..." -- \
                    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing || true

                gum spin --spinner dot --title "Menginstall multimedia packages & codecs..." -- \
                    sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin || true
                sudo dnf groupupdate -y sound-and-video || true

                gum spin --spinner dot --title "Menginstall GStreamer plugins & libdvdcss..." -- \
                    sudo dnf install -y \
                        gstreamer1-plugins-bad-freeworld \
                        gstreamer1-plugins-ugly \
                        gstreamer1-plugins-good-extras \
                        gstreamer1-plugin-openh264 \
                        gstreamer1-libav \
                        lame-mp3x \
                        libdvdcss || true
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                gum spin --spinner dot --title "Menginstall multimedia codecs & ffmpeg (Ubuntu)..." -- \
                    sudo apt-get install -y ubuntu-restricted-extras ffmpeg gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-plugins-good gstreamer1.0-libav lame || true
            fi
            success "Multimedia Codecs berhasil diinstall."
            ;;
        "Hardware Video Acceleration / Drivers"*)
            info "Mengonfigurasi Hardware Video Acceleration Drivers..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                gum spin --spinner dot --title "Mengganti Mesa drivers dengan freeworld (RPM Fusion)..." -- \
                    sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld --allowerasing || true
                gum spin --spinner dot --title "Mengganti Mesa VDPAU drivers dengan freeworld..." -- \
                    sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld --allowerasing || true

                gum spin --spinner dot --title "Menginstall Intel/AMD VA-API drivers..." -- \
                    sudo dnf install -y \
                        intel-media-driver \
                        libva-intel-driver \
                        libva-utils \
                        vdpauinfo || true
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                gum spin --spinner dot --title "Menginstall VA-API & VDPAU drivers (Ubuntu)..." -- \
                    sudo apt-get install -y va-driver-all mesa-va-drivers mesa-vdpau-drivers vainfo vdpauinfo intel-media-va-driver || true
            fi
            success "Hardware Video Acceleration Drivers berhasil dikonfigurasi."
            ;;
        "System Utilities & Compression"*)
            info "Menginstall System Utilities & Compression Tools..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                gum spin --spinner dot --title "Menginstall utilitas sistem & kompresi..." -- \
                    sudo dnf install -y \
                        p7zip \
                        p7zip-plugins \
                        unrar \
                        tar \
                        rsync \
                        curl \
                        wget \
                        pciutils \
                        lshw
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                gum spin --spinner dot --title "Menginstall utilitas sistem & kompresi (Ubuntu)..." -- \
                    sudo apt-get install -y \
                        p7zip-full \
                        unrar \
                        tar \
                        rsync \
                        curl \
                        wget \
                        pciutils \
                        lshw
            fi
            success "System Utilities & Compression berhasil diinstall."
            ;;
        "KDE Plasma Enhancements"*)
            info "Menginstall Desktop Enhancements..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                gum spin --spinner dot --title "Menginstall integrasi KDE Connect & Flatpak KCM..." -- \
                    sudo dnf install -y \
                        kde-connect \
                        kcm-flatpak \
                        plasma-discover-flatpak-backend || true
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                gum spin --spinner dot --title "Menginstall integrasi Desktop (Ubuntu)..." -- \
                    sudo apt-get install -y kdeconnect || true
            fi
            success "Desktop Enhancements berhasil diinstall."
            ;;
        "Btrfs Assistant & Snapper"*)
            info "Menginstall Snapper dan Btrfs Tools..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                gum spin --spinner dot --title "Menginstall btrfs-assistant, snapper, btrfsmaintenance..." -- \
                    sudo dnf install -y btrfs-assistant snapper btrfsmaintenance btrfs-progs
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                gum spin --spinner dot --title "Menginstall snapper & btrfs-progs (Ubuntu)..." -- \
                    sudo apt-get install -y snapper btrfs-progs || true
            fi
            
            # Setup konfigurasi snapper default untuk root jika belum ada
            if command -v snapper &>/dev/null && ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
                info "Membuat konfigurasi snapper awal untuk root (/)...."
                sudo snapper -c root create-config / || warn "Snapper root config sudah ada atau gagal dibuat."
            fi

            # Aktifkan service & timer snapper
            sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer 2>/dev/null || true
            success "Snapper & Btrfs Tools berhasil dikonfigurasi."
            ;;
        "System Performance & Thermal Tuning"*)
            info "Menginstall & mengaktifkan thermal and performance daemons..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                gum spin --spinner dot --title "Menginstall thermald, tuned, preload..." -- \
                    sudo dnf install -y thermald tuned tuned-ppd preload
                sudo systemctl enable --now thermald tuned preload 2>/dev/null || true
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                gum spin --spinner dot --title "Menginstall thermald & preload (Ubuntu)..." -- \
                    sudo apt-get install -y thermald preload || true
                sudo systemctl enable --now thermald preload 2>/dev/null || true
            fi
            success "System Performance & Thermal Tuning berhasil dikonfigurasi."
            ;;
        "Kernel & Sysctl Desktop Tuning"*)
            info "Menerapkan konfigurasi kernel sysctl untuk ZRAM & responsivitas desktop..."
            SYSCTL_CONF="/etc/sysctl.d/99-desktop-tuning.conf"
            sudo tee "$SYSCTL_CONF" >/dev/null << 'SYSCTL_EOF'
# Optimasi Desktop, ZRAM, dan File Watcher Handles
# Meningkatkan efisiensi kompresi memori ZRAM
vm.swappiness = 180
vm.vfs_cache_pressure = 50

# Meningkatkan batas inotify handles (krusial untuk Node.js, VSCode, Docker, & IDE)
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024
SYSCTL_EOF
            sudo sysctl --system >/dev/null 2>&1 || true
            success "Konfigurasi kernel sysctl ($SYSCTL_CONF) berhasil diterapkan."
            ;;
    esac
done

echo ""
success "$(_msg "Pemasangan System Essentials & Media Codecs selesai." "System Essentials & Media Codecs installation completed.")"
