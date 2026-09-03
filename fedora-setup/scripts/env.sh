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

# Memastikan gum terinstall
if ! command -v gum &> /dev/null; then
    info "gum tidak ditemukan. Menginstall gum dari repositori resmi..."
    sudo dnf install -y gum
    success "gum berhasil diinstall."
fi

# Menambahkan RPM Fusion (Free & Non-Free)
info "Memastikan repository RPM Fusion terpasang..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true

# Menambahkan RPM Fusion Tainted (untuk codec proprietary seperti libdvdcss)
info "Memastikan repository RPM Fusion Tainted aktif..."
sudo dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted || true

# Menambahkan Flathub
info "Memastikan repository Flathub tersedia..."
if ! command -v flatpak &> /dev/null; then
    warn "Flatpak belum terinstall. Menginstall flatpak..."
    sudo dnf install -y flatpak
fi
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Update Metadata
info "Melakukan update metadata DNF dan Flatpak..."
sudo dnf makecache
sudo flatpak update -y
