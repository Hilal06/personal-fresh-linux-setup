#!/usr/bin/env bash
# ==============================================================================
# Fresh Linux Setup Utility - One-Liner Web Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Hilal06/personal-fresh-linux-setup/main/install.sh | bash
# ==============================================================================

set -e

# Fallback untuk environment root / container minimal tanpa command sudo
if ! command -v sudo &>/dev/null && [ "${EUID:-$(id -u)}" -eq 0 ]; then
    sudo() { "$@"; }
fi

REPO_URL="https://github.com/Hilal06/personal-fresh-linux-setup.git"
TARBALL_URL="https://github.com/Hilal06/personal-fresh-linux-setup/archive/refs/heads/main.tar.gz"
INSTALL_DIR="$HOME/.local/share/personal-fresh-linux-setup"

# 1. Verifikasi kompatibilitas sistem & pastikan curl/tar/git terpasang
if command -v pacman &>/dev/null; then
    echo -e "\033[0;31m[ERROR] Distribusi Arch Linux (pacman) tidak didukung.\033[0m"
    echo "Utilitas ini khusus dirancang untuk Fedora Workstation dan Ubuntu (KDE / GNOME)."
    exit 1
fi

if ! command -v git &>/dev/null || ! command -v curl &>/dev/null || ! command -v tar &>/dev/null; then
    echo "[INFO] Menyiapkan paket dependensi awal (git, curl, tar)..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y git curl tar >/dev/null 2>&1 || true
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update -qq >/dev/null 2>&1 || true
        sudo apt-get install -y git curl tar >/dev/null 2>&1 || true
    else
        echo -e "\033[0;31m[ERROR] Package manager tidak didukung. Utilitas ini hanya mendukung Fedora dan Ubuntu.\033[0m"
        exit 1
    fi
fi

# 2. Unduh atau perbarui repositori ke direktori lokal tersembunyi
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "[INFO] Memperbarui repositori utilitas..."
    git -C "$INSTALL_DIR" pull --quiet --ff-only || true
else
    mkdir -p "$INSTALL_DIR"
    if command -v git &>/dev/null; then
        echo "[INFO] Mengunduh Fresh Linux Setup Utility..."
        git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" --quiet
    else
        echo "[INFO] Mengunduh archive utilitas via curl..."
        curl -fsSL "$TARBALL_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1
    fi
fi

# 3. Jalankan skrip utama dengan TTY interaktif
chmod +x "$INSTALL_DIR/linux-setup/setup.sh" "$INSTALL_DIR/linux-setup/scripts/"*.sh 2>/dev/null || true

# Alihkan stdin ke terminal fisik (/dev/tty)
exec </dev/tty

# Eksekusi setup.sh dan tangkap status keluaran
"$INSTALL_DIR/linux-setup/setup.sh" "$@" || true

# 4. Konfirmasi Pembersihan Direktori di Akhir Sesi
echo ""
if command -v gum &>/dev/null; then
    if gum confirm "Apakah Anda ingin menghapus direktori repositori utilitas ini ($INSTALL_DIR)?"; then
        echo "[INFO] Membersihkan direktori instalasi..."
        rm -rf "$INSTALL_DIR"
        gum style --foreground 82 --bold "✓ Direktori lokal berhasil dibersihkan."
    else
        gum style --foreground 39 "ℹ Direktori tetap disimpan di: $INSTALL_DIR"
    fi
else
    read -r -p "Apakah Anda ingin menghapus direktori repositori utilitas ini? (y/N): " CLEAN_CHOICE
    if [[ "$CLEAN_CHOICE" =~ ^[Yy]$ ]]; then
        echo "[INFO] Membersihkan direktori instalasi..."
        rm -rf "$INSTALL_DIR"
        echo "✓ Direktori lokal berhasil dibersihkan."
    else
        echo "ℹ Direktori tetap disimpan di: $INSTALL_DIR"
    fi
fi
