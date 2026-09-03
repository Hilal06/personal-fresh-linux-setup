#!/usr/bin/env bash
# ==============================================================================
# Script Setup & Konfigurasi Terminal Otomatis
# Konfigurasi: Zsh, Starship, Zsh Plugins, Zoxide, FZF, Bat, Eza, FD
# ==============================================================================

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CONFIGS_DIR="$SCRIPT_DIR/../configs"

# Load environment & helper functions (info, success, warn, error, gum)
source "$SCRIPT_DIR/env.sh"

info "Memulai setup dan konfigurasi terminal modern..."

# 1. Install CLI Tools & Starship
install_cli_tools() {
    info "Menginstall CLI tools (zsh, git, curl, fzf, bat, eza, fd-find, zoxide, util-linux-user)..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y zsh git curl fzf bat eza fd-find zoxide util-linux-user
    elif command -v apt &>/dev/null; then
        sudo apt update
        sudo apt install -y zsh git curl fzf bat fd-find zoxide util-linux
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm zsh git curl fzf bat eza fd zoxide
    else
        warn "Package manager tidak dikenali. Pastikan tool esensial terminal sudah terinstall manual."
    fi

    # Install Starship jika belum ada
    if ! command -v starship &>/dev/null; then
        info "Menginstall Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        success "Starship prompt berhasil diinstall."
    else
        success "Starship prompt sudah terinstall."
    fi
}

# 2. Setup Folder & Clone Zsh Plugins
setup_plugins() {
    info "Menyiapkan plugin Zsh..."
    local PLUGIN_DIR="$HOME/.zsh/plugins"
    mkdir -p "$PLUGIN_DIR"
    mkdir -p "$HOME/.zsh/completions"

    # zsh-autosuggestions
    if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
        info "Mengunduh zsh-autosuggestions..."
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
    else
        info "Mengupdate zsh-autosuggestions..."
        git -C "$PLUGIN_DIR/zsh-autosuggestions" pull --quiet || true
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
        info "Mengunduh zsh-syntax-highlighting..."
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
    else
        info "Mengupdate zsh-syntax-highlighting..."
        git -C "$PLUGIN_DIR/zsh-syntax-highlighting" pull --quiet || true
    fi

    # zsh-completions
    if [ ! -d "$PLUGIN_DIR/zsh-completions" ]; then
        info "Mengunduh zsh-completions..."
        git clone --depth 1 https://github.com/zsh-users/zsh-completions "$PLUGIN_DIR/zsh-completions"
    else
        info "Mengupdate zsh-completions..."
        git -C "$PLUGIN_DIR/zsh-completions" pull --quiet || true
    fi

    success "Semua plugin Zsh siap digunakan."
}

# 3. Setup Konfigurasi Starship (~/.config/starship.toml)
deploy_starship_config() {
    local SOURCE_STARSHIP="$CONFIGS_DIR/starship.toml"
    local TARGET_STARSHIP="$HOME/.config/starship.toml"

    mkdir -p "$HOME/.config"

    if [ -f "$TARGET_STARSHIP" ]; then
        local BACKUP_STARSHIP="$HOME/.config/starship.toml.backup.$(date +%Y%m%d%H%M%S)"
        cp "$TARGET_STARSHIP" "$BACKUP_STARSHIP"
        info "Backup konfigurasi starship lama dibuat di: $BACKUP_STARSHIP"
    fi

    if [ -f "$SOURCE_STARSHIP" ]; then
        cp "$SOURCE_STARSHIP" "$TARGET_STARSHIP"
        success "Konfigurasi Starship (~/.config/starship.toml) berhasil diterapkan."
    else
        warn "File konfigurasi $SOURCE_STARSHIP tidak ditemukan."
    fi
}

# 4. Setup Konfigurasi Zsh (~/.zshrc)
deploy_zshrc_config() {
    local SOURCE_ZSHRC="$CONFIGS_DIR/.zshrc"
    local TARGET_ZSHRC="$HOME/.zshrc"

    mkdir -p "$HOME/ZoxideBackup"

    if [ -f "$TARGET_ZSHRC" ]; then
        local BACKUP_ZSHRC="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        cp "$TARGET_ZSHRC" "$BACKUP_ZSHRC"
        info "Backup ~/.zshrc lama dibuat di: $BACKUP_ZSHRC"
    fi

    if [ -f "$SOURCE_ZSHRC" ]; then
        cp "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
        success "Konfigurasi ~/.zshrc berhasil diterapkan."
    else
        warn "File konfigurasi $SOURCE_ZSHRC tidak ditemukan."
    fi
}

# 5. Ubah Default Shell ke Zsh
set_default_shell() {
    local ZSH_PATH
    ZSH_PATH="$(command -v zsh || true)"

    if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
        if gum confirm "Apakah Anda ingin mengubah default shell pengguna ($USER) ke Zsh?"; then
            info "Mengubah default shell ke $ZSH_PATH..."
            sudo chsh -s "$ZSH_PATH" "$USER" || warn "Gagal menjalankan chsh otomatis. Silakan jalankan 'chsh -s $(which zsh)' manual."
            success "Default shell berhasil diubah ke Zsh."
        else
            info "Melewati penggantian default shell."
        fi
    else
        info "Zsh sudah menjadi default shell aktif atau belum terpasang."
    fi
}

# Eksekusi
install_cli_tools
setup_plugins

if gum confirm "Terapkan file konfigurasi dotfiles (starship.toml & .zshrc)?"; then
    deploy_starship_config
    deploy_zshrc_config
else
    info "Melewati penyalinan dotfiles terminal."
fi

set_default_shell

echo ""
success "============================================================"
success " Setup Terminal & Shell Modern Selesai!"
success " Silakan restart terminal atau jalankan: exec zsh"
success "============================================================"
