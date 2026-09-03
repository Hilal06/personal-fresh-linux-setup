#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

info "Memulai instalasi Zsh dan dependensi shell..."
sudo dnf install -y zsh util-linux-user

# Konfirmasi ubah shell
if gum confirm "Apakah Anda ingin mengubah default shell ke Zsh?"; then
    info "Mengubah default shell ke Zsh..."
    sudo chsh -s "$(command -v zsh)" "$USER"
    success "Default shell berhasil diubah. Harap relogin (atau restart) agar perubahan ini aktif sepenuhnya."
else
    info "Melewati pengubahan default shell."
fi

# Konfirmasi salin .zshrc
if gum confirm "Apakah Anda ingin menyalin konfigurasi .zshrc yang disediakan ke home directory Anda?"; then
    CONFIG_ZSH="$(dirname "$0")/../configs/.zshrc"
    
    if [ -f "$HOME/.zshrc" ]; then
        BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        cp "$HOME/.zshrc" "$BACKUP_FILE"
        info "File .zshrc lama ditemukan. Backup telah dibuat di: $BACKUP_FILE"
    fi
    
    cp "$CONFIG_ZSH" "$HOME/.zshrc"
    success "Konfigurasi .zshrc berhasil disalin."
else
    info "Melewati penyalinan .zshrc."
fi
