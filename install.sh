#!/usr/bin/env bash
# ==============================================================================
# Fresh Linux Setup Utility - One-Liner Web Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Hilal06/personal-fresh-linux-setup/main/install.sh | bash
# ==============================================================================

set -eo pipefail

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
        TMP_TAR="$(mktemp -t setup-repo.XXXXXX.tar.gz)"
        chmod 600 "$TMP_TAR"
        curl --proto '=https' --tlsv1.2 -fsSL "$TARBALL_URL" -o "$TMP_TAR"
        tar -xzf "$TMP_TAR" -C "$INSTALL_DIR" --strip-components=1 --no-same-owner
        rm -f "$TMP_TAR"
    fi
fi

# 3. Jalankan skrip utama dengan TTY interaktif
chmod +x "$INSTALL_DIR/linux-setup/setup.sh" "$INSTALL_DIR/linux-setup/scripts/"*.sh 2>/dev/null || true

# Alihkan stdin ke terminal fisik (/dev/tty)
exec </dev/tty

# Eksekusi setup.sh dan tangkap status keluaran
"$INSTALL_DIR/linux-setup/setup.sh" "$@" || true

# 4. Konfirmasi Pembersihan Direktori di Akhir Sesi
LANG_STATE_FILE="$HOME/.cache/fresh-linux-setup/.setup_lang"
if [ -f "$LANG_STATE_FILE" ]; then
    SETUP_LANG="$(cat "$LANG_STATE_FILE" 2>/dev/null)"
    rm -f "$LANG_STATE_FILE"
elif [ -f /tmp/.setup_lang ]; then
    SETUP_LANG="$(cat /tmp/.setup_lang 2>/dev/null)"
    rm -f /tmp/.setup_lang
fi

CLEAN_PROMPT="Apakah Anda ingin menghapus direktori repositori utilitas ini ($INSTALL_DIR)?"
CLEAN_INFO="[INFO] Membersihkan direktori instalasi..."
CLEAN_SUCCESS="✓ Direktori lokal berhasil dibersihkan."
CLEAN_RETAIN="ℹ Direktori tetap disimpan di: $INSTALL_DIR"

if [ "${SETUP_LANG:-}" = "en" ]; then
    CLEAN_PROMPT="Do you want to remove this utility repository directory ($INSTALL_DIR)?"
    CLEAN_INFO="[INFO] Cleaning up installation directory..."
    CLEAN_SUCCESS="✓ Local directory successfully cleaned up."
    CLEAN_RETAIN="ℹ Directory retained at: $INSTALL_DIR"
fi

echo ""
if command -v gum &>/dev/null; then
    if gum confirm "$CLEAN_PROMPT"; then
        echo "$CLEAN_INFO"
        rm -rf "$INSTALL_DIR"
        gum style --foreground 82 --bold "$CLEAN_SUCCESS"
    else
        gum style --foreground 39 "$CLEAN_RETAIN"
    fi
else
    read -r -p "$CLEAN_PROMPT (y/N): " CLEAN_CHOICE
    if [[ "$CLEAN_CHOICE" =~ ^[Yy]$ ]]; then
        echo "$CLEAN_INFO"
        rm -rf "$INSTALL_DIR"
        echo "$CLEAN_SUCCESS"
    else
        echo "$CLEAN_RETAIN"
    fi
fi
