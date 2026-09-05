#!/usr/bin/env bash
# ==============================================================================
# Setup & Konfigurasi ASUS ROG / TUF Gaming Laptop
# Tools: asusctl, rog-control-center, supergfxctl
# Konfigurasi: Battery charge limit, Power profile, GPU Mode switcher
# ==============================================================================

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env.sh"

echo ""
gum style \
    --foreground 196 --border-foreground 196 --border rounded \
    --align center --width 64 --padding "1 2" --bold \
    "ROG & TUF GAMING UTILITY" "ASUS Power, GPU MUX Switch & Battery Care"

info "Memulai setup dan konfigurasi utilitas ASUS ROG / TUF..."

# 1. Deteksi Perangkat ASUS
detect_asus_hardware() {
    local PRODUCT_NAME VENDOR
    PRODUCT_NAME="$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo 'Unknown')"
    VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo 'Unknown')"

    info "Perangkat terdeteksi: $VENDOR ($PRODUCT_NAME)"

    if [[ "$VENDOR" != *"ASUS"* ]] && [[ "$PRODUCT_NAME" != *"ASUS"* ]] && [[ "$PRODUCT_NAME" != *"ROG"* ]] && [[ "$PRODUCT_NAME" != *"TUF"* ]]; then
        warn "Peringatan: Sistem ini mungkin bukan laptop ASUS ROG / TUF."
        if ! gum confirm "Apakah Anda tetap ingin melanjutkan setup utilitas ASUS?"; then
            info "Membatalkan setup ASUS."
            exit 0
        fi
    fi
}

# 2. Instalasi Tool ASUS (asusctl, rog-control-center, supergfxctl)
install_asus_packages() {
    info "Memeriksa paket asusctl, rog-control-center, dan supergfxctl..."

    if command -v dnf &>/dev/null; then
        # Enable COPR repository lukenukem/asus-linux jika belum ada
        if ! dnf repolist | grep -qi "lukenukem.*asus-linux"; then
            info "Menambahkan COPR repository: lukenukem/asus-linux..."
            sudo dnf copr enable -y lukenukem/asus-linux || warn "Gagal menambahkan COPR repository lukenukem/asus-linux"
        fi

        local PKGS_TO_INSTALL=()
        if ! command -v asusctl &>/dev/null; then
            PKGS_TO_INSTALL+=("asusctl")
        fi
        if ! command -v rog-control-center &>/dev/null; then
            PKGS_TO_INSTALL+=("asusctl-rog-gui")
        fi
        if ! command -v supergfxctl &>/dev/null; then
            PKGS_TO_INSTALL+=("supergfxctl")
        fi

        if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
            info "Menginstall paket: ${PKGS_TO_INSTALL[*]}..."
            sudo dnf install -y "${PKGS_TO_INSTALL[@]}"
            success "Paket utilitas ASUS berhasil diinstall."
        else
            success "Semua paket utilitas ASUS (asusctl, rog-control-center, supergfxctl) sudah terpasang."
        fi
    elif command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
        if ! command -v asusctl &>/dev/null || ! command -v supergfxctl &>/dev/null; then
            warn "Paket asusctl dan supergfxctl tidak tersedia di repository default Ubuntu."
            warn "Untuk Ubuntu, silakan gunakan PPA resmi komunitas atau build dari source: https://asus-linux.org"
        else
            success "asusctl & supergfxctl sudah terpasang di sistem Ubuntu."
        fi
    else
        warn "Package manager tidak didukung untuk instalasi otomatis asusctl."
    fi
}

# 3. Mengaktifkan Background Services (asusd, supergfxd, asus-shutdown)
enable_asus_services() {
    info "Memeriksa dan mengaktifkan background services ASUS..."

    local SERVICES=("asusd.service" "supergfxd.service" "asus-shutdown.service")
    for s in "${SERVICES[@]}"; do
        if systemctl list-unit-files "$s" &>/dev/null; then
            if ! systemctl is-active --quiet "$s"; then
                info "Mengaktifkan service: $s..."
                sudo systemctl enable --now "$s" || warn "Gagal mengaktifkan $s"
            else
                success "Service $s sudah aktif dan berjalan."
            fi
        fi
    done
}

# 4. Konfigurasi Interaktif Fitur ASUS
configure_asus_settings() {
    info "Pilih opsi konfigurasi ASUS yang ingin Anda atur (Spasi untuk memilih, Enter untuk konfirmasi):"

    local CONFIG_CHOICES
    CONFIG_CHOICES=$(gum choose --no-limit \
        "Set Batas Pengisian Baterai (Battery Health / Care Limit)" \
        "Set Default Power Profile (Quiet / Balanced / Performance)" \
        "Set Graphics / GPU Mode Switcher (supergfxctl)" \
        "Set Kecerahan Keyboard Backlight")

    if [ -z "$CONFIG_CHOICES" ]; then
        info "Tidak ada konfigurasi yang dipilih."
        return 0
    fi

    mapfile -t SELECTED_CONFIGS <<< "$CONFIG_CHOICES"

    for opt in "${SELECTED_CONFIGS[@]}"; do
        [ -z "$opt" ] && continue
        case "$opt" in
            "Set Batas Pengisian Baterai"*)
                echo ""
                local CURRENT_LIMIT
                CURRENT_LIMIT="$(asusctl battery info 2>/dev/null | grep -o '[0-9]\+%' || cat /sys/class/power_supply/BAT*/charge_control_end_threshold 2>/dev/null || echo 'Tidak diketahui')"
                info "Batas pengisian baterai saat ini: $CURRENT_LIMIT"

                local TARGET_LIMIT
                TARGET_LIMIT=$(gum choose "80 (Direkomendasikan untuk baterai awet)" "60 (Maksimal masa pakai saat dicolok terus)" "100 (Kapasitas penuh 100%)")
                local NUM_LIMIT
                NUM_LIMIT=$(echo "$TARGET_LIMIT" | awk '{print $1}')

                if [ -n "$NUM_LIMIT" ]; then
                    info "Menerapkan batas baterai ke $NUM_LIMIT%..."
                    asusctl battery limit "$NUM_LIMIT" 2>/dev/null || {
                        for b in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
                            [ -f "$b" ] && echo "$NUM_LIMIT" | sudo tee "$b" >/dev/null || true
                        done
                    }
                    success "Batas pengisian baterai berhasil diatur ke $NUM_LIMIT%."
                fi
                ;;

            "Set Default Power Profile"*)
                echo ""
                local CURRENT_PROFILE
                CURRENT_PROFILE="$(asusctl profile get 2>/dev/null || echo 'Tidak diketahui')"
                info "Profil daya saat ini: $CURRENT_PROFILE"

                local TARGET_PROFILE
                TARGET_PROFILE=$(gum choose "Balanced" "Quiet" "Performance")
                if [ -n "$TARGET_PROFILE" ]; then
                    info "Mengubah profil daya ke $TARGET_PROFILE..."
                    asusctl profile set "$TARGET_PROFILE" || warn "Gagal mengatur profil daya."
                    success "Profil daya aktif diatur ke $TARGET_PROFILE."
                fi
                ;;

            "Set Graphics / GPU Mode Switcher"*)
                echo ""
                if command -v supergfxctl &>/dev/null; then
                    local CURRENT_GPU
                    CURRENT_GPU="$(supergfxctl -g 2>/dev/null || echo 'Unknown')"
                    local SUPPORTED_GPUS
                    SUPPORTED_GPUS="$(supergfxctl -s 2>/dev/null || echo '')"
                    info "Mode GPU saat ini: $CURRENT_GPU"
                    info "Mode GPU yang didukung sistem: $SUPPORTED_GPUS"

                    local TARGET_GPU
                    TARGET_GPU=$(gum choose "Hybrid (Otomatis: iGPU untuk hemat daya + dGPU saat dibutuhkan)" "Integrated (Hanya iGPU - matikan dGPU untuk baterai awet)" "AsusMuxDgpu (Direct Dedicated GPU / MUX Switch)")

                    local GPU_MODE
                    case "$TARGET_GPU" in
                        "Hybrid"*) GPU_MODE="Hybrid" ;;
                        "Integrated"*) GPU_MODE="Integrated" ;;
                        "AsusMuxDgpu"*) GPU_MODE="AsusMuxDgpu" ;;
                    esac

                    if [ -n "$GPU_MODE" ]; then
                        info "Mengatur GPU mode ke $GPU_MODE..."
                        supergfxctl -m "$GPU_MODE" || warn "Gagal mengganti mode GPU. Kemungkinan perlu logout / restart."
                        success "Mode GPU berhasil diubah ke $GPU_MODE."
                        warn "Catatan: Perubahan mode GPU biasanya membutuhkan logout atau restart sesi desktop untuk berlaku penuh."
                    fi
                else
                    warn "supergfxctl tidak ditemukan."
                fi
                ;;

            "Set Kecerahan Keyboard Backlight"*)
                echo ""
                local TARGET_BRIGHTNESS
                TARGET_BRIGHTNESS=$(gum choose "med" "high" "low" "off")
                if [ -n "$TARGET_BRIGHTNESS" ]; then
                    info "Mengatur kecerahan backlight keyboard ke '$TARGET_BRIGHTNESS'..."
                    asusctl leds set "$TARGET_BRIGHTNESS" || warn "Gagal mengatur backlight keyboard."
                    success "Backlight keyboard diatur ke $TARGET_BRIGHTNESS."
                fi
                ;;
        esac
    done
}

# Eksekusi
detect_asus_hardware
install_asus_packages
enable_asus_services

if gum confirm "Apakah Anda ingin mengatur konfigurasi profil & baterai ASUS sekarang?"; then
    configure_asus_settings
else
    info "Melewati konfigurasi interaktif ASUS."
fi

echo ""
success "============================================================"
success " Setup & Konfigurasi ASUS ROG / TUF Selesai!"
success " GUI ROG Control Center dapat dibuka dengan: rog-control-center"
success "============================================================"
