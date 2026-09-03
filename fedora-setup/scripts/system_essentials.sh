#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

info "Pilih modul System Essentials & Media Codecs yang ingin diinstall:"

CHOICES=$(gum choose --no-limit \
    "Multimedia Codecs Lengkap (FFmpeg, GStreamer, libdvdcss, Audio/Video Extras)" \
    "Hardware Video Acceleration / Drivers (VA-API, Mesa Freeworld, Intel/AMD)" \
    "System Utilities & Compression (p7zip, unrar, tar, rsync, lshw, pciutils)" \
    "KDE Plasma Enhancements (KDE Connect, Flatpak KCM integration)")

if [ -z "$CHOICES" ]; then
    info "Tidak ada opsi System Essentials yang dipilih."
    exit 0
fi

echo "$CHOICES" | while read -r choice; do
    case "$choice" in
        "Multimedia Codecs Lengkap"*)
            info "Menginstall Multimedia Codecs Lengkap..."
            # Menukar ffmpeg-free dengan versi lengkap ffmpeg dari RPM Fusion
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
            # Swap Mesa drivers ke freeworld untuk akselerasi hardware codec tertutup (H.264/H.265/VC-1)
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
    esac
done

echo ""
success "Pemasangan System Essentials & Media Codecs selesai."
