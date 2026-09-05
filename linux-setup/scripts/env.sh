#!/usr/bin/env bash
set -e

# ==============================================================================
# Environment Setup & Helpers
# ==============================================================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Language / i18n helper (Default: id)
export SETUP_LANG="${SETUP_LANG:-id}"

_msg() {
    if [ "$SETUP_LANG" = "en" ]; then
        echo "$2"
    else
        echo "$1"
    fi
}

# Helper untuk merender breadcrumbs navigasi modern TUI
render_breadcrumb() {
    local PATH_STR="$1"
    local MAIN_LABEL
    MAIN_LABEL="$(_msg "Menu Utama" "Main Menu")"
    echo ""
    gum style --foreground 240 "🧭 $MAIN_LABEL > $PATH_STR"
}

# Fallback untuk environment root / container minimal tanpa command sudo
if ! command -v sudo &>/dev/null && [ "${EUID:-$(id -u)}" -eq 0 ]; then
    sudo() { "$@"; }
fi

# Deteksi Package Manager & Distribusi
if command -v pacman &>/dev/null; then
    error "Distribusi Arch Linux (pacman) tidak didukung. Skrip ini hanya mendukung Fedora Workstation dan Ubuntu (KDE / GNOME)."
fi

if command -v dnf &>/dev/null; then
    DISTRO_TYPE="fedora"
elif command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
    DISTRO_TYPE="ubuntu"
else
    error "Distribusi sistem tidak didukung. Skrip ini hanya mendukung Fedora Workstation dan Ubuntu (KDE / GNOME)."
fi

# Memastikan gum terinstall (dibutuhkan untuk TUI)
ensure_gum_installed() {
    if ! command -v gum &> /dev/null; then
        info "gum belum terpasang. Menginstall gum..."
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            sudo dnf install -y gum >/dev/null 2>&1 || sudo dnf install -y gum
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            sudo apt-get update -qq >/dev/null 2>&1 || true
            sudo apt-get install -y -qq curl gpg >/dev/null 2>&1 || true
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg 2>/dev/null || true
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
            sudo apt-get update -qq >/dev/null 2>&1 || true
            sudo apt-get install -y -qq gum >/dev/null 2>&1 || {
                local GUM_TEMP
                GUM_TEMP="$(mktemp -d)"
                curl -fsSL https://github.com/charmbracelet/gum/releases/latest/download/gum_linux_amd64.tar.gz -o "$GUM_TEMP/gum.tar.gz" 2>/dev/null || true
                if [ -s "$GUM_TEMP/gum.tar.gz" ]; then
                    tar -xzf "$GUM_TEMP/gum.tar.gz" -C "$GUM_TEMP"
                    sudo cp "$GUM_TEMP"/gum_*_linux_amd64/gum /usr/local/bin/ 2>/dev/null || sudo cp "$GUM_TEMP/gum" /usr/local/bin/ 2>/dev/null || true
                fi
                rm -rf "$GUM_TEMP"
            }
        fi

        if command -v gum &>/dev/null; then
            success "gum berhasil diinstall."
        else
            error "Gagal memasang 'gum'. Silakan pasang gum secara manual."
        fi
    fi
}

# Fungsi optimasi performa DNF (/etc/dnf/dnf.conf)
optimize_dnf_performance() {
    local DNF_CONF="/etc/dnf/dnf.conf"
    if [ -f "$DNF_CONF" ]; then
        local MODIFIED=false
        if ! grep -q "^max_parallel_downloads" "$DNF_CONF"; then
            echo "max_parallel_downloads=10" | sudo tee -a "$DNF_CONF" >/dev/null
            MODIFIED=true
        fi
        if ! grep -q "^fastestmirror" "$DNF_CONF"; then
            echo "fastestmirror=True" | sudo tee -a "$DNF_CONF" >/dev/null
            MODIFIED=true
        fi
        if ! grep -q "^defaultyes" "$DNF_CONF"; then
            echo "defaultyes=True" | sudo tee -a "$DNF_CONF" >/dev/null
            MODIFIED=true
        fi
        if [ "$MODIFIED" = true ]; then
            info "Optimasi konfigurasi DNF (/etc/dnf/dnf.conf) berhasil diterapkan."
        fi
    fi
}

# Fungsi inisialisasi repositori (RPM Fusion & Flathub) secara cepat & idempoten
setup_environment_repos() {
    if [ "$DISTRO_TYPE" = "fedora" ]; then
        optimize_dnf_performance

        # 1. Periksa apakah RPM Fusion sudah terpasang
        if ! rpm -q rpmfusion-free-release &>/dev/null || ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
            info "Menginstall RPM Fusion Free & Non-Free..."
            local FEDORA_VER
            FEDORA_VER="$(rpm -E %fedora 2>/dev/null || echo '41')"
            sudo dnf install -y \
                "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
                "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" >/dev/null 2>&1 || true
        fi

        # 2. Periksa RPM Fusion Tainted
        if ! rpm -q rpmfusion-free-release-tainted &>/dev/null || ! rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
            info "Menginstall RPM Fusion Tainted..."
            sudo dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted >/dev/null 2>&1 || true
        fi
    elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
        info "Memeriksa repositori universe & multiverse pada Ubuntu..."
        sudo apt-get update -qq >/dev/null 2>&1 || true
        if command -v add-apt-repository &>/dev/null; then
            sudo add-apt-repository -y universe >/dev/null 2>&1 || true
            sudo add-apt-repository -y multiverse >/dev/null 2>&1 || true
        else
            sudo apt-get install -y -qq software-properties-common >/dev/null 2>&1 || true
            sudo add-apt-repository -y universe >/dev/null 2>&1 || true
            sudo add-apt-repository -y multiverse >/dev/null 2>&1 || true
        fi
    fi

    # 3. Flathub remote
    if command -v flatpak &>/dev/null; then
        if ! flatpak remotes 2>/dev/null | grep -q "flathub"; then
            info "Menambahkan remote Flathub..."
            sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
        fi
    fi
}

ensure_gum_installed

# Jalankan setup_environment_repos langsung hanya jika skrip ini dieksekusi secara independen
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_environment_repos
    success "Inisialisasi environment repositori selesai."
fi
