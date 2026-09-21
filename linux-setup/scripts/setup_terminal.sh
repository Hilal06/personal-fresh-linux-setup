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

# 1. Install CLI Tools & Starship
install_cli_tools() {
    info "Menginstall CLI tools (zsh, git, curl, fzf, bat, eza, fd-find, zoxide, util-linux)..."
    if command -v dnf &>/dev/null; then
        sudo dnf install -y zsh git curl fzf bat eza fd-find zoxide util-linux-user
    elif command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y zsh git curl fzf bat fd-find zoxide util-linux
        # Cek dan pasang eza untuk Ubuntu
        if ! command -v eza &>/dev/null; then
            if ! sudo apt-get install -y eza 2>/dev/null; then
                info "Menyiapkan repository eza untuk Ubuntu..."
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc 2>/dev/null | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null 2>&1 || true
                sudo apt-get update -qq 2>/dev/null || true
                sudo apt-get install -y eza >/dev/null 2>&1 || warn "eza tidak tersedia di repo apt, alias ls fallback di .zshrc akan digunakan."
            fi
        fi
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

# 2. Install & Verifikasi FiraCode Nerd Font (Wajib untuk Starship & Glyphs)
install_firacode_nerd_font() {
    info "Memeriksa instalasi FiraCode Nerd Font..."

    # Cek apakah font sudah terdeteksi di sistem
    if fc-list : family | grep -qi "FiraCode Nerd Font"; then
        success "FiraCode Nerd Font sudah terinstall di sistem."
        configure_kde_konsole_font
        configure_gnome_terminal_font
        return 0
    fi

    info "FiraCode Nerd Font belum ditemukan. Memulai proses instalasi..."

    # Instalasi langsung dari rilis resmi Nerd Fonts GitHub
    info "Mengunduh FiraCode Nerd Font dari rilis resmi GitHub..."
    local FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
    local TEMP_DIR
    TEMP_DIR="$(mktemp -d)"

    mkdir -p "$FONT_DIR"

    if curl -fLo "$TEMP_DIR/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"; then
        info "Mengekstrak FiraCode Nerd Font ke $FONT_DIR..."
        unzip -q -o "$TEMP_DIR/FiraCode.zip" -d "$FONT_DIR" "*.ttf" || unzip -q -o "$TEMP_DIR/FiraCode.zip" -d "$FONT_DIR"
    else
        warn "Gagal mengunduh FiraCode Nerd Font dari GitHub."
    fi

    rm -rf "$TEMP_DIR"

    # Refresh font cache
    if command -v fc-cache &>/dev/null; then
        info "Memperbarui cache font sistem (fc-cache)..."
        fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || fc-cache -f 2>/dev/null || true
    fi

    # Verifikasi akhir
    if fc-list : family | grep -qi "FiraCode Nerd Font"; then
        success "FiraCode Nerd Font berhasil diinstall dan siap digunakan!"
    else
        warn "Instalasi font selesai, pastikan mengatur font terminal Anda ke 'FiraCode Nerd Font'."
    fi

    # Auto-set font untuk terminal (KDE Plasma & GNOME Terminal)
    configure_kde_konsole_font
    configure_gnome_terminal_font
}

# 3. Konfigurasi Otomatis Font Konsole KDE
configure_kde_konsole_font() {
    local KWRITE_BIN
    KWRITE_BIN="$(command -v kwriteconfig6 || command -v kwriteconfig5 || true)"

    if [ -n "$KWRITE_BIN" ] && [ -d "$HOME/.local/share/konsole" ]; then
        info "Mendeteksi lingkungan KDE Plasma. Mengonfigurasi font Konsole..."
        local KONSOLE_RC="$HOME/.config/konsolerc"
        local PROFILE_NAME=""

        # Cari default profile aktif dari konsolerc
        if [ -f "$KONSOLE_RC" ]; then
            PROFILE_NAME="$(grep "^DefaultProfile=" "$KONSOLE_RC" 2>/dev/null | cut -d'=' -f2 || true)"
        fi

        # Fallback profile jika tidak ditemukan
        if [ -z "$PROFILE_NAME" ]; then
            PROFILE_NAME="Personal.profile"
            mkdir -p "$HOME/.local/share/konsole"
            "$KWRITE_BIN" --file "$KONSOLE_RC" --group "Desktop Entry" --key "DefaultProfile" "$PROFILE_NAME"
        fi

        local PROFILE_PATH="$HOME/.local/share/konsole/$PROFILE_NAME"
        info "Menerapkan 'FiraCode Nerd Font' ke profile Konsole: $PROFILE_NAME..."
        "$KWRITE_BIN" --file "$PROFILE_PATH" --group "Appearance" --key "Font" "FiraCode Nerd Font,11,-1,5,700,0,0,0,0,0,0,0,0,0,0,1,Bold"
        "$KWRITE_BIN" --file "$PROFILE_PATH" --group "Appearance" --key "UseFontLineChararacters" "false"
        success "Font KDE Konsole berhasil diatur ke FiraCode Nerd Font."
    fi
}

# 4. Konfigurasi Otomatis Font GNOME Terminal
configure_gnome_terminal_font() {
    if command -v gsettings &>/dev/null; then
        if gsettings list-schemas 2>/dev/null | grep -q "org.gnome.Terminal.ProfilesList"; then
            local DEFAULT_PROFILE
            DEFAULT_PROFILE="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d \'\")"
            if [ -n "$DEFAULT_PROFILE" ]; then
                info "Mendeteksi GNOME Terminal. Menerapkan 'FiraCode Nerd Font'..."
                gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles/:$DEFAULT_PROFILE/" use-system-font false 2>/dev/null || true
                gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles/:$DEFAULT_PROFILE/" font 'FiraCode Nerd Font 11' 2>/dev/null || true
                success "Font GNOME Terminal berhasil diatur ke FiraCode Nerd Font."
            fi
        fi
    fi
}

# 3. Setup Folder & Clone Zsh Plugins
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

# Helper instalasi GNU Stow jika diperlukan
ensure_stow_installed() {
    if ! command -v stow &>/dev/null; then
        info "$(_msg "Menginstall GNU Stow..." "Installing GNU Stow...")"
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            sudo dnf install -y stow
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            sudo apt-get install -y stow
        fi
    fi
}

# 4. Setup Konfigurasi Starship (~/.config/starship.toml)
deploy_starship_config() {
    local MODE="${1:-copy}"
    local SOURCE_STARSHIP="$CONFIGS_DIR/starship.toml"
    local TARGET_STARSHIP="$HOME/.config/starship.toml"
    local BACKUP_DIR="$HOME/.dotfiles_backup"

    mkdir -p "$HOME/.config" "$BACKUP_DIR"

    if [ -f "$TARGET_STARSHIP" ] && [ ! -L "$TARGET_STARSHIP" ]; then
        local TIMESTAMP
        TIMESTAMP="$(date +%Y%m%d%H%M%S)"
        local BACKUP_STARSHIP="$BACKUP_DIR/starship.toml.backup.$TIMESTAMP"
        cp "$TARGET_STARSHIP" "$BACKUP_STARSHIP"
        cp "$TARGET_STARSHIP" "$BACKUP_DIR/starship.toml.latest"
        info "Backup konfigurasi starship tersimpan aman di: $BACKUP_STARSHIP"
    fi

    if [ -f "$SOURCE_STARSHIP" ]; then
        rm -f "$TARGET_STARSHIP"
        if [ "$MODE" = "symlink" ]; then
            ln -sf "$SOURCE_STARSHIP" "$TARGET_STARSHIP"
            success "Symlink Starship (~/.config/starship.toml -> $SOURCE_STARSHIP) berhasil dibuat."
        else
            cp "$SOURCE_STARSHIP" "$TARGET_STARSHIP"
            success "Konfigurasi Starship (~/.config/starship.toml) berhasil diterapkan."
        fi
    else
        warn "File konfigurasi $SOURCE_STARSHIP tidak ditemukan."
    fi
}

# 5. Setup Konfigurasi Zsh (~/.zshrc)
deploy_zshrc_config() {
    local MODE="${1:-copy}"
    local SOURCE_ZSHRC="$CONFIGS_DIR/.zshrc"
    local TARGET_ZSHRC="$HOME/.zshrc"
    local BACKUP_DIR="$HOME/.dotfiles_backup"

    mkdir -p "$HOME/ZoxideBackup" "$BACKUP_DIR"

    if [ -f "$TARGET_ZSHRC" ] && [ ! -L "$TARGET_ZSHRC" ]; then
        local TIMESTAMP
        TIMESTAMP="$(date +%Y%m%d%H%M%S)"
        local BACKUP_ZSHRC="$BACKUP_DIR/.zshrc.backup.$TIMESTAMP"
        cp "$TARGET_ZSHRC" "$BACKUP_ZSHRC"
        cp "$TARGET_ZSHRC" "$BACKUP_DIR/.zshrc.latest"
        info "Backup ~/.zshrc tersimpan aman di: $BACKUP_ZSHRC"
    fi

    if [ -f "$SOURCE_ZSHRC" ]; then
        rm -f "$TARGET_ZSHRC"
        if [ "$MODE" = "symlink" ]; then
            ln -sf "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
            success "Symlink ~/.zshrc (-> $SOURCE_ZSHRC) berhasil dibuat."
        else
            cp "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
            success "Konfigurasi ~/.zshrc berhasil diterapkan."
        fi
    else
        warn "File konfigurasi $SOURCE_ZSHRC tidak ditemukan."
    fi
}

# Deploy dengan GNU Stow
deploy_with_stow() {
    ensure_stow_installed
    local STOW_DIR="$CONFIGS_DIR/stow"
    local PKG_DIR="$STOW_DIR/profile"
    mkdir -p "$PKG_DIR/.config"

    cp -f "$CONFIGS_DIR/.zshrc" "$PKG_DIR/.zshrc"
    cp -f "$CONFIGS_DIR/starship.toml" "$PKG_DIR/.config/starship.toml"

    local BACKUP_DIR="$HOME/.dotfiles_backup"
    local TIMESTAMP
    TIMESTAMP="$(date +%Y%m%d%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.backup.$TIMESTAMP"
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.latest"
        rm -f "$HOME/.zshrc"
    fi
    if [ -f "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
        cp "$HOME/.config/starship.toml" "$BACKUP_DIR/starship.toml.backup.$TIMESTAMP"
        cp "$HOME/.config/starship.toml" "$BACKUP_DIR/starship.toml.latest"
        rm -f "$HOME/.config/starship.toml"
    fi

    stow -R -d "$STOW_DIR" -t "$HOME" profile
    success "$(_msg "Dotfiles berhasil di-link menggunakan GNU Stow!" "Dotfiles successfully linked using GNU Stow!")"
}

# Menu Interaktif Pemilihan Mode Deployment Dotfiles
deploy_dotfiles_interactive() {
    local METHOD
    info "$(_msg "Pilih metode deployment dotfiles:" "Select dotfiles deployment method:")"
    METHOD=$(gum choose \
        --cursor="❯ " \
        --cursor.foreground="45" \
        "$(_msg "📋 Salin Fisik (Copy dengan riwayat backup timestamp)" "📋 Direct Copy (with timestamped backup history)")" \
        "$(_msg "🔗 Symbolic Link (Tautkan langsung file ke repositori ini)" "🔗 Symbolic Link (Symlink directly to this repository)")" \
        "$(_msg "📦 GNU Stow (Kelola via paket symlink GNU Stow)" "📦 GNU Stow (Manage via GNU Stow symlink package)")" || true)

    case "$METHOD" in
        *"Symbolic Link"*|*"Symlink"*)
            deploy_starship_config "symlink"
            deploy_zshrc_config "symlink"
            ;;
        *"GNU Stow"*)
            deploy_with_stow
            ;;
        *)
            deploy_starship_config "copy"
            deploy_zshrc_config "copy"
            ;;
    esac
}

# 6. Ubah Default Shell ke Zsh
set_default_shell() {
    local ZSH_PATH
    ZSH_PATH="$(command -v zsh || true)"

    if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
        if gum confirm "$(_msg "Apakah Anda ingin mengubah default shell pengguna ($USER) ke Zsh?" "Do you want to change default shell for user ($USER) to Zsh?")"; then
            info "Mengubah default shell ke $ZSH_PATH..."
            sudo chsh -s "$ZSH_PATH" "$USER" || warn "Gagal menjalankan chsh otomatis. Silakan jalankan 'chsh -s $(which zsh)' manual."
            success "Default shell berhasil diubah ke Zsh."
        else
            info "Default shell tidak diubah."
        fi
    fi
}

# 7. Setup Konfigurasi Git & SSH (Opsional)
configure_git_and_ssh() {
    if [ -f "$SCRIPT_DIR/git_ssh_setup.sh" ]; then
        if gum confirm "$(_msg "Apakah Anda ingin mengonfigurasi identitas Git & SSH Key sekarang?" "Do you want to configure Git identity & SSH Key now?")"; then
            bash "$SCRIPT_DIR/git_ssh_setup.sh"
        else
            info "Melewati konfigurasi Git & SSH."
        fi
    fi
}

# Eksekusi interaktif jika skrip dijalankan secara langsung
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    render_breadcrumb "$(_msg "Setup Shell & Terminal Workspace" "Shell & Terminal Workspace Setup")"

    gum style \
        --foreground 45 --border-foreground 45 --border rounded \
        --align center --width 64 --padding "1 2" --bold \
        "TERMINAL & SHELL WORKSPACE" "$(_msg "Zsh, Starship, FiraCode Nerd Font & Dotfiles" "Zsh, Starship, FiraCode Nerd Font & Dotfiles")"

    echo ""
    ACTION=$(gum choose \
        --cursor="❯ " \
        --cursor.foreground="45" \
        --header="$(_msg "Pilih mode setup terminal:" "Select terminal setup mode:")" \
        "🚀  $(_msg "Jalankan Setup Lengkap (CLI Tools, Font, Plugins, Dotfiles)" "Run Full Setup (CLI Tools, Font, Plugins, Dotfiles)")" \
        "🎨  $(_msg "Hanya Terapkan Dotfiles (~/.zshrc & starship.toml)" "Apply Dotfiles Only (~/.zshrc & starship.toml)")" \
        "🔤  $(_msg "Hanya Install FiraCode Nerd Font & Konfigurasi Profil Terminal" "Install FiraCode Nerd Font & Configure Terminal Profile Only")" \
        "$(_msg "⬅️   [Kembali ke Menu Utama]" "⬅️   [Back to Main Menu]")" || true)

    if [ -z "$ACTION" ] || [[ "$ACTION" == *"Kembali"* ]] || [[ "$ACTION" == *"Back"* ]]; then
        info "$(_msg "Kembali ke Menu Utama..." "Returning to Main Menu...")"
        exit 0
    fi

    case "$ACTION" in
        *"Setup Lengkap"*|*"Full Setup"*)
            install_cli_tools
            install_firacode_nerd_font
            setup_plugins

            if gum confirm "$(_msg "Terapkan file konfigurasi dotfiles (starship.toml & .zshrc)?" "Apply dotfiles configuration files (starship.toml & .zshrc)?")"; then
                deploy_dotfiles_interactive
            else
                info "Melewati penyalinan dotfiles terminal."
            fi

            configure_git_and_ssh
            set_default_shell
            ;;

        *"Dotfiles"*)
            deploy_dotfiles_interactive
            ;;

        *"FiraCode"*)
            install_firacode_nerd_font
            ;;
    esac

    echo ""
    success "============================================================"
    success "$(_msg " Setup Terminal & Shell Modern Selesai!" " Terminal & Shell Modern Setup Completed!")"
    success "$(_msg " Silakan restart terminal atau jalankan: exec zsh" " Please restart your terminal or run: exec zsh")"
    success "============================================================"
fi
