#!/usr/bin/env bash
# ==============================================================================
# Script Setup Git Identity & SSH Key Developer
# Mengonfigurasi nama/email Git, default branch, dan ed25519 SSH Key
# ==============================================================================

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env.sh"

render_breadcrumb "$(_msg "Git Identity & SSH Key Setup" "Git Identity & SSH Key Setup")"

gum style \
    --foreground 214 --border-foreground 214 --border rounded \
    --align center --width 64 --padding "1 2" --bold \
    "GIT & SSH DEVELOPER SETUP" "$(_msg "Identitas Global & Autentikasi Ed25519" "Global Identity & Ed25519 Authentication")"

echo ""
ACTION=$(gum choose \
    --cursor="❯ " \
    --cursor.foreground="214" \
    --header="$(_msg "Pilih tindakan Git & SSH:" "Select Git & SSH action:")" \
    "⚡  $(_msg "Konfigurasi Identitas Git & Generate SSH Key" "Configure Git Identity & Generate SSH Key")" \
    "📋  $(_msg "Tampilkan & Salin Public SSH Key yang Ada" "Display & Copy Existing Public SSH Key")" \
    "$(_msg "⬅️   [Kembali ke Menu Utama]" "⬅️   [Back to Main Menu]")" || true)

if [ -z "$ACTION" ] || [[ "$ACTION" == *"Kembali"* ]] || [[ "$ACTION" == *"Back"* ]]; then
    info "$(_msg "Kembali ke Menu Utama..." "Returning to Main Menu...")"
    exit 0
fi

# Fungsi Tampilkan Public Key
show_existing_public_key() {
    local SSH_KEY="$HOME/.ssh/id_ed25519.pub"
    if [ ! -f "$SSH_KEY" ]; then
        SSH_KEY="$HOME/.ssh/id_rsa.pub"
    fi

    if [ -f "$SSH_KEY" ]; then
        local PUB_CONTENT
        PUB_CONTENT="$(cat "$SSH_KEY")"
        if command -v wl-copy &>/dev/null; then
            echo "$PUB_CONTENT" | wl-copy 2>/dev/null || true
            info "✓ Public Key ($SSH_KEY) disalin ke Clipboard (Wayland)."
        elif command -v xclip &>/dev/null; then
            echo "$PUB_CONTENT" | xclip -selection clipboard 2>/dev/null || true
            info "✓ Public Key ($SSH_KEY) disalin ke Clipboard (X11)."
        fi
        echo ""
        gum style --border rounded --padding "1 2" --border-foreground 82 \
            "PUBLIC SSH KEY ($SSH_KEY):" \
            "$PUB_CONTENT"
    else
        warn "Tidak ditemukan file public SSH key di ~/.ssh/"
    fi
}
configure_git_identity() {
    info "Memeriksa konfigurasi Git..."
    if ! command -v git &>/dev/null; then
        warn "Git belum terinstall. Melewati konfigurasi identitas Git."
        return 0
    fi

    local CURRENT_NAME CURRENT_EMAIL
    CURRENT_NAME="$(git config --global user.name 2>/dev/null || echo '')"
    CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || echo '')"

    if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_EMAIL" ]; then
        info "Konfigurasi Git saat ini: $CURRENT_NAME <$CURRENT_EMAIL>"
        if ! gum confirm "Apakah Anda ingin memperbarui identitas Git Anda?"; then
            return 0
        fi
    fi

    local GIT_NAME GIT_EMAIL
    GIT_NAME=$(gum input --placeholder "Nama Lengkap (e.g. John Doe)" --value "$CURRENT_NAME" --header "Masukkan Nama Git (user.name):")
    GIT_EMAIL=$(gum input --placeholder "Email (e.g. user@example.com)" --value "$CURRENT_EMAIL" --header "Masukkan Email Git (user.email):")

    if [ -n "$GIT_NAME" ]; then
        git config --global user.name "$GIT_NAME"
        git config --global init.defaultBranch main
        success "Git user.name diatur ke: $GIT_NAME"
        success "Git default branch diatur ke: main"
    fi

    if [ -n "$GIT_EMAIL" ]; then
        git config --global user.email "$GIT_EMAIL"
        success "Git user.email diatur ke: $GIT_EMAIL"
    fi
}

# 2. Setup SSH Key ed25519
configure_ssh_key() {
    local SSH_DIR="$HOME/.ssh"
    local SSH_KEY="$SSH_DIR/id_ed25519"
    local HOSTNAME_STR
    HOSTNAME_STR="$(hostname 2>/dev/null || echo 'linux')"
    local GIT_EMAIL
    GIT_EMAIL="$(git config --global user.email 2>/dev/null || echo "$USER@$HOSTNAME_STR")"

    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    if [ -f "$SSH_KEY" ]; then
        info "SSH Key ed25519 sudah ditemukan di: $SSH_KEY"
    else
        if gum confirm "SSH Key belum ditemukan. Generate SSH Key baru (ed25519)?"; then
            info "Membuat SSH Key ed25519..."
            ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
            chmod 600 "$SSH_KEY"
            chmod 644 "$SSH_KEY.pub"
            success "SSH Key baru berhasil dibuat: $SSH_KEY"
        else
            info "Melewati pembuatan SSH Key."
            return 0
        fi
    fi

    # Aktifkan ssh-agent & daftarkan private key
    eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
    ssh-add "$SSH_KEY" >/dev/null 2>&1 || true

    # Salin ke clipboard jika tool tersedia
    local PUB_KEY_CONTENT
    PUB_KEY_CONTENT="$(cat "$SSH_KEY.pub")"

    if command -v wl-copy &>/dev/null; then
        echo "$PUB_KEY_CONTENT" | wl-copy 2>/dev/null || true
        info "✓ Public Key otomatis disalin ke Clipboard (Wayland / wl-copy)."
    elif command -v xclip &>/dev/null; then
        echo "$PUB_KEY_CONTENT" | xclip -selection clipboard 2>/dev/null || true
        info "✓ Public Key otomatis disalin ke Clipboard (X11 / xclip)."
    fi

    echo ""
    gum style --border rounded --padding "1 2" --border-foreground 82 \
        "PUBLIC SSH KEY ANDA (Tambahkan ke GitHub / GitLab):" \
        "$PUB_KEY_CONTENT"
    
    info "Buka https://github.com/settings/ssh/new untuk menempelkan SSH key di atas."
}

case "$ACTION" in
    *"Konfigurasi Identitas Git"*|*"Configure Git Identity"*)
        configure_git_identity
        configure_ssh_key
        echo ""
        success "$(_msg "Konfigurasi Git & SSH selesai." "Git & SSH configuration completed.")"
        ;;
    *"Tampilkan & Salin"*|*"Display & Copy"*)
        show_existing_public_key
        ;;
esac
