#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

echo ""
gum style \
    --foreground 141 --border-foreground 141 --border rounded \
    --align center --width 64 --padding "1 2" --bold \
    "SYSTEM ESSENTIALS & CODECS" "Multimedia, Btrfs Snapshots & Desktop Optimization"

info "Pilih modul System Essentials & Media Codecs yang ingin diinstall (Spasi untuk memilih, Enter untuk konfirmasi):"

CHOICES=$(gum choose --no-limit \
    "Multimedia Codecs Lengkap (FFmpeg, GStreamer, libdvdcss, Audio/Video Extras)" \
    "Hardware Video Acceleration / Drivers (VA-API, Mesa Freeworld, Intel/AMD)" \
    "System Utilities & Compression (p7zip, unrar, tar, rsync, lshw, pciutils)" \
    "KDE Plasma Enhancements (KDE Connect, Flatpak KCM integration)" \
    "Btrfs Assistant & Snapper (GUI Snapshot, Maintenance, Subvolume Management)" \
    "System Performance & Thermal Tuning (thermald, tuned, preload)" \
    "Kernel & Sysctl Desktop Tuning (ZRAM Swappiness, File Watcher Handles)")

if [ -z "$CHOICES" ]; then
    info "Tidak ada opsi System Essentials yang dipilih."
    exit 0
fi

mapfile -t SELECTED_OPTS <<< "$CHOICES"

for choice in "${SELECTED_OPTS[@]}"; do
    [ -z "$choice" ] && continue
    case "$choice" in
        "Multimedia Codecs Lengkap"*)
            info "Menginstall Multimedia Codecs Lengkap..."
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
            success "Multimedia Codecs berhasil diinstall."
            ;;
        "Hardware Video Acceleration / Drivers"*)
            info "Mengonfigurasi Hardware Video Acceleration Drivers..."
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
            success "Hardware Video Acceleration Drivers berhasil dikonfigurasi."
            ;;
        "System Utilities & Compression"*)
            info "Menginstall System Utilities & Compression Tools..."
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
            success "System Utilities & Compression berhasil diinstall."
            ;;
        "KDE Plasma Enhancements"*)
            info "Menginstall KDE Plasma Enhancements..."
            gum spin --spinner dot --title "Menginstall integrasi KDE Connect & Flatpak KCM..." -- \
                sudo dnf install -y \
                    kde-connect \
                    kcm-flatpak \
                    plasma-discover-flatpak-backend || true
            success "KDE Plasma Enhancements berhasil diinstall."
            ;;
        "Btrfs Assistant & Snapper"*)
            info "Menginstall Btrfs Assistant, Snapper, dan Btrfs Maintenance..."
            gum spin --spinner dot --title "Menginstall btrfs-assistant, snapper, btrfsmaintenance..." -- \
                sudo dnf install -y btrfs-assistant snapper btrfsmaintenance btrfs-progs
            
            # Setup konfigurasi snapper default untuk root jika belum ada
            if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
                info "Membuat konfigurasi snapper awal untuk root (/)...."
                sudo snapper -c root create-config / || warn "Snapper root config sudah ada atau gagal dibuat."
            fi

            # Aktifkan service & timer snapper
            sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer 2>/dev/null || true
            success "Btrfs Assistant & Snapper berhasil dikonfigurasi."
            ;;
        "System Performance & Thermal Tuning"*)
            info "Menginstall & mengaktifkan thermal and performance daemons..."
            gum spin --spinner dot --title "Menginstall thermald, tuned, preload..." -- \
                sudo dnf install -y thermald tuned tuned-ppd preload
            
            info "Mengaktifkan service thermald, tuned, dan preload..."
            sudo systemctl enable --now thermald tuned preload 2>/dev/null || true
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
success "Pemasangan System Essentials & Media Codecs selesai."
