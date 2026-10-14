#!/usr/bin/env bash
# ==============================================================================
# Modern Developer Runtimes & Version Managers
# Node.js (fnm), Python (uv), Rust (rustup), Go, Java (OpenJDK), PHP (Composer)
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# shellcheck source=linux-setup/scripts/env.sh
source "$SCRIPT_DIR/env.sh"

render_breadcrumb "$(_msg "Developer Runtimes & Version Managers" "Developer Runtimes & Version Managers")"

gum style \
    --foreground 220 --border-foreground 220 --border rounded \
    --align center --width 64 --padding "1 2" --bold \
    "DEVELOPER RUNTIMES & VERSION MANAGERS" \
    "$(_msg "Node.js (fnm), Python (uv), Rust, Go, Java & PHP" "Node.js (fnm), Python (uv), Rust, Go, Java & PHP")"

# 1. Install fnm & Node.js LTS
install_fnm_node() {
    info "$(_msg "Menginstall fnm (Fast Node Manager) & Node.js LTS..." "Installing fnm (Fast Node Manager) & Node.js LTS...")"
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v fnm &>/dev/null; then
        local FNM_TMP
        FNM_TMP="$(create_secure_tmp "fnm-install")"
        if safe_download "https://fnm.vercel.app/install" "$FNM_TMP/install.sh"; then
            bash "$FNM_TMP/install.sh" --install-dir "$HOME/.local/bin" --skip-shell
        else
            warn "Gagal mengunduh installer fnm."
        fi
        rm -rf "$FNM_TMP"
    fi

    if [ -x "$HOME/.local/bin/fnm" ]; then
        eval "$("$HOME/.local/bin/fnm" env --shell bash)"
        "$HOME/.local/bin/fnm" install --lts || true
        "$HOME/.local/bin/fnm" default lts-latest || true

        # Aktifkan pnpm via corepack atau npm
        if [ -d "$HOME/.local/share/fnm/current/bin" ]; then
            export PATH="$HOME/.local/share/fnm/current/bin:$PATH"
        fi
        if command -v corepack &>/dev/null; then
            info "$(_msg "Mengaktifkan pnpm via Corepack..." "Enabling pnpm via Corepack...")"
            corepack enable 2>/dev/null || true
            corepack prepare pnpm@latest --activate 2>/dev/null || true
        elif command -v npm &>/dev/null; then
            info "$(_msg "Menginstall pnpm..." "Installing pnpm...")"
            npm install -g pnpm 2>/dev/null || true
        fi

        # Hook ke .zshrc jika belum ada
        if [ -f "$HOME/.zshrc" ] && ! grep -q 'fnm env' "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# Fast Node Manager (fnm)' >> "$HOME/.zshrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            echo 'eval "$(fnm env --use-on-cd --shell zsh 2>/dev/null)"' >> "$HOME/.zshrc"
        fi

        # Hook ke .bashrc jika belum ada
        if [ -f "$HOME/.bashrc" ] && ! grep -q 'fnm env' "$HOME/.bashrc"; then
            echo '' >> "$HOME/.bashrc"
            echo '# Fast Node Manager (fnm)' >> "$HOME/.bashrc"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            echo 'eval "$(fnm env --use-on-cd --shell bash 2>/dev/null)"' >> "$HOME/.bashrc"
        fi

        success "$(_msg "fnm & Node.js LTS berhasil dipasang." "fnm & Node.js LTS successfully installed.")"
    else
        warn "$(_msg "Gagal memasang binary fnm ke ~/.local/bin." "Failed to install fnm binary to ~/.local/bin.")"
    fi
}

# 2. Install uv & Python Toolchain
install_uv_python() {
    info "$(_msg "Menginstall uv (Ultra-fast Python Package & Version Manager)..." "Installing uv (Ultra-fast Python Package & Version Manager)...")"
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v uv &>/dev/null; then
        local UV_TMP
        UV_TMP="$(create_secure_tmp "uv-install")"
        if safe_download "https://astral.sh/uv/install.sh" "$UV_TMP/install.sh"; then
            sh "$UV_TMP/install.sh"
        else
            warn "Gagal mengunduh installer uv."
        fi
        rm -rf "$UV_TMP"
    fi

    if [ -x "$HOME/.local/bin/uv" ] || command -v uv &>/dev/null; then
        local UV_BIN
        UV_BIN="$(command -v uv 2>/dev/null || echo "$HOME/.local/bin/uv")"
        info "$(_msg "Mengunduh Python versi LTS via uv..." "Fetching LTS Python via uv...")"
        "$UV_BIN" python install || true

        # Hook ke shell configs jika belum ada
        for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
            if [ -f "$rc" ] && ! grep -q 'PATH="$HOME/.local/bin:$PATH"' "$rc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            fi
        done
        success "$(_msg "uv (Python Package & Project Manager) siap digunakan." "uv (Python Package & Project Manager) ready to use.")"
    else
        warn "$(_msg "Gagal menginstall uv." "Failed to install uv.")"
    fi
}

# 3. Install Rustup & Cargo
install_rust() {
    info "$(_msg "Menginstall Rust Toolchain (rustup & cargo)..." "Installing Rust Toolchain (rustup & cargo)...")"
    if command -v rustup &>/dev/null || command -v cargo &>/dev/null; then
        success "$(_msg "Rust toolchain sudah terpasang." "Rust toolchain already installed.")"
    else
        local RUSTUP_TMP
        RUSTUP_TMP="$(create_secure_tmp "rustup-install")"
        if safe_download "https://sh.rustup.rs" "$RUSTUP_TMP/rustup-init.sh"; then
            sh "$RUSTUP_TMP/rustup-init.sh" -s -- -y --no-modify-path
            export PATH="$HOME/.cargo/bin:$PATH"

            for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
                if [ -f "$rc" ] && ! grep -q '\.cargo/bin' "$rc"; then
                    echo '' >> "$rc"
                    echo '# Rust Cargo environment' >> "$rc"
                    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$rc"
                fi
            done
            success "$(_msg "Rust toolchain (rustup & cargo) berhasil dipasang." "Rust toolchain (rustup & cargo) successfully installed.")"
        else
            warn "Gagal mengunduh installer Rustup."
        fi
        rm -rf "$RUSTUP_TMP"
    fi
}

# 4. Install Go (Golang)
install_golang() {
    info "$(_msg "Menginstall Go Toolchain (Golang)..." "Installing Go Toolchain (Golang)...")"
    if command -v go &>/dev/null; then
        success "$(_msg "Go sudah terpasang di: $(which go)" "Go already installed at: $(which go)")"
        return 0
    fi

    if [ "$DISTRO_TYPE" = "fedora" ]; then
        sudo dnf install -y golang
    elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
        sudo apt-get install -y golang-go
    fi

    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [ -f "$rc" ] && ! grep -q 'GOPATH' "$rc"; then
            echo '' >> "$rc"
            echo '# Go Language environment' >> "$rc"
            echo 'export GOPATH="$HOME/go"' >> "$rc"
            echo 'export PATH="$PATH:$GOPATH/bin"' >> "$rc"
        fi
    done
    success "$(_msg "Go Toolchain berhasil dipasang." "Go Toolchain successfully installed.")"
}

# 5. Install Java Development Kit (OpenJDK LTS)
install_java() {
    info "$(_msg "Menginstall Java Development Kit (OpenJDK LTS)..." "Installing Java Development Kit (OpenJDK LTS)...")"
    if command -v javac &>/dev/null; then
        success "$(_msg "Java JDK sudah terpasang di: $(which javac)" "Java JDK already installed at: $(which javac)")"
        return 0
    fi

    if [ "$DISTRO_TYPE" = "fedora" ]; then
        sudo dnf install -y java-latest-openjdk-devel
    elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
        sudo apt-get install -y default-jdk
    fi
    success "$(_msg "Java Development Kit berhasil dipasang." "Java Development Kit successfully installed.")"
}

# 6. Install PHP & Composer
install_php() {
    info "$(_msg "Menginstall PHP CLI & Composer..." "Installing PHP CLI & Composer...")"
    if [ "$DISTRO_TYPE" = "fedora" ]; then
        sudo dnf install -y php-cli php-common php-mbstring php-xml php-curl php-zip composer
    elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
        sudo apt-get install -y php-cli php-common php-mbstring php-xml php-curl php-zip composer
    fi
    success "$(_msg "PHP & Composer berhasil dipasang." "PHP & Composer successfully installed.")"
}

# Jika skrip dijalankan langsung secara interaktif
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo ""
    gum style --foreground 245 "$(_msg " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali" " [↑/↓] Navigate • [Space] Toggle Selection • [Enter] Confirm • [Esc] Back")"

    CHOICES=$(gum choose --no-limit \
        --cursor="❯ " \
        --cursor.foreground="220" \
        --selected.foreground="82" \
        "$(_msg "⬅️   [Kembali ke Menu Utama]" "⬅️   [Back to Main Menu]")" \
        "$(_msg "Node.js LTS via fnm (Fast Node Manager) + pnpm" "Node.js LTS via fnm (Fast Node Manager) + pnpm")" \
        "$(_msg "Python via uv (Ultra-fast Python & Package Manager)" "Python via uv (Ultra-fast Python & Package Manager)")" \
        "$(_msg "Rust Language Toolchain (rustup & cargo)" "Rust Language Toolchain (rustup & cargo)")" \
        "$(_msg "Go Toolchain (Golang Compiler & Tools)" "Go Toolchain (Golang Compiler & Tools)")" \
        "$(_msg "Java Development Kit (OpenJDK LTS)" "Java Development Kit (OpenJDK LTS)")" \
        "$(_msg "PHP & Composer (Modern PHP CLI & Package Manager)" "PHP & Composer (Modern PHP CLI & Package Manager)")" || true)

    if [ -z "$CHOICES" ] || [[ "$CHOICES" == *"Kembali"* ]] || [[ "$CHOICES" == *"Back"* ]]; then
        info "$(_msg "Kembali ke Menu Utama..." "Returning to Main Menu...")"
        exit 0
    fi

    mapfile -t SELECTED_RUNTIMES <<< "$CHOICES"

    if [ ${#SELECTED_RUNTIMES[@]} -gt 0 ]; then
        create_system_snapshot "Pre-Dev-Runtimes"
    fi

    for r in "${SELECTED_RUNTIMES[@]}"; do
        [ -z "$r" ] && continue
        case "$r" in
            *"Node.js"*)
                install_fnm_node
                ;;
            *"Python"*)
                install_uv_python
                ;;
            *"Rust"*)
                install_rust
                ;;
            *"Go Toolchain"*)
                install_golang
                ;;
            *"Java"*)
                install_java
                ;;
            *"PHP"*)
                install_php
                ;;
        esac
    done

    echo ""
    success "============================================================"
    success "$(_msg " Setup Developer Runtimes Selesai!" " Developer Runtimes Setup Completed!")"
    success "$(_msg " Jalankan: source ~/.zshrc (atau restart shell)" " Run: source ~/.zshrc (or restart shell)")"
    success "============================================================"
fi
