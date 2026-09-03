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

# Memeriksa package manager dnf
if ! command -v dnf &>/dev/null; then
    error "DNF package manager tidak ditemukan. Skrip ini ditujukan untuk Fedora."
fi

# Memastikan gum terinstall (dibutuhkan untuk TUI)
ensure_gum_installed() {
    if ! command -v gum &> /dev/null; then
        info "gum belum terpasang. Menginstall gum dari repositori resmi..."
        sudo dnf install -y gum >/dev/null 2>&1 || sudo dnf install -y gum
        success "gum berhasil diinstall."
    fi
}

# Fungsi inisialisasi repositori (RPM Fusion & Flathub)
setup_environment_repos() {
    info "Menyiapkan repository RPM Fusion & Flathub..."

    # RPM Fusion Free & Non-Free
    local FEDORA_VER
    FEDORA_VER="$(rpm -E %fedora)"
    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" >/dev/null 2>&1 || true

    # RPM Fusion Tainted
    sudo dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted >/dev/null 2>&1 || true

    # Flathub
    if ! command -v flatpak &> /dev/null; then
        sudo dnf install -y flatpak >/dev/null 2>&1
    fi
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true

    # Refresh metadata
    sudo dnf makecache --refresh >/dev/null 2>&1 || true
    sudo flatpak update --appstream >/dev/null 2>&1 || true
}

ensure_gum_installed

# Jalankan setup_environment_repos langsung hanya jika skrip ini dieksekusi secara independen
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_environment_repos
    success "Inisialisasi environment repositori selesai."
fi
