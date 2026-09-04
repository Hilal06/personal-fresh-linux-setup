#!/usr/bin/env bash
# ==============================================================================
# Fresh Fedora KDE Utillity - One-Liner Web Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Hilal06/personal-fresh-linux-setup/main/install.sh | bash
# ==============================================================================

set -e

REPO_URL="https://github.com/Hilal06/personal-fresh-linux-setup.git"
TARBALL_URL="https://github.com/Hilal06/personal-fresh-linux-setup/archive/refs/heads/main.tar.gz"
INSTALL_DIR="$HOME/.local/share/personal-fresh-linux-setup"

# 1. Pastikan curl dan tar atau git terpasang
if ! command -v git &>/dev/null && ! command -v curl &>/dev/null; then
    echo "[INFO] Menyiapkan curl & git..."
    sudo dnf install -y git curl tar >/dev/null 2>&1 || true
fi

# 2. Unduh atau perbarui repositori ke direktori lokal tersembunyi
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "[INFO] Memperbarui repositori utilitas..."
    git -C "$INSTALL_DIR" pull --quiet --ff-only || true
else
    mkdir -p "$INSTALL_DIR"
    if command -v git &>/dev/null; then
        echo "[INFO] Mengunduh Fresh Fedora KDE Utillity..."
        git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" --quiet
    else
        echo "[INFO] Mengunduh archive utilitas via curl..."
        curl -fsSL "$TARBALL_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1
    fi
fi

# 3. Jalankan skrip utama langsung dengan TTY interaktif
chmod +x "$INSTALL_DIR/fedora-setup/setup.sh" "$INSTALL_DIR/fedora-setup/scripts/"*.sh 2>/dev/null || true

# Menghubungkan stdin TTY (/dev/tty) agar TUI Gum interaktif bekerja sempurna melalui curl pipe
exec </dev/tty
exec "$INSTALL_DIR/fedora-setup/setup.sh" "$@"
