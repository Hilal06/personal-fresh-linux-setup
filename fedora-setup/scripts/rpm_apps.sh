#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

echo ""
gum style \
    --foreground 33 --border-foreground 33 --border rounded \
    --align center --width 64 --padding "1 2" --bold \
    "RPM APPLICATION REPOSITORY" "DNF, Developer Tools, Antigravity & System Utilities"

info "Pilih aplikasi berbasis RPM (DNF) yang ingin diinstall (Spasi untuk memilih, Enter untuk konfirmasi):"

CHOICES=$(gum choose --no-limit \
    "Development Tools (gcc, make, git, curl, wget, cmake)" \
    "Google Antigravity CLI (agy)" \
    "Google Antigravity IDE (Desktop Application)" \
    "Visual Studio Code" \
    "Docker Engine & Docker Compose" \
    "Fastfetch & Neovim" \
    "HTop & BTop" \
    "BleachBit (System Cleaner)" \
    "EasyEffects & Plugins (Audio Enhancer / Equalizer)" \
    "Flatseal (Flatpak Permissions Manager)")

if [ -z "$CHOICES" ]; then
    info "Tidak ada aplikasi RPM yang dipilih."
    exit 0
fi

mapfile -t SELECTED_APPS <<< "$CHOICES"

for choice in "${SELECTED_APPS[@]}"; do
    [ -z "$choice" ] && continue
    case "$choice" in
        "Development Tools"*)
            info "Menginstall Development Tools..."
            sudo dnf install -y gcc gcc-c++ make git curl wget cmake
            ;;
        "Google Antigravity CLI (agy)")
            info "Menginstall Google Antigravity CLI (agy)..."
            mkdir -p "$HOME/.local/bin"
            if command -v agy &>/dev/null; then
                success "Antigravity CLI (agy) sudah terinstall di: $(which agy)"
            else
                info "Mengunduh binary resmi Google Antigravity CLI..."
                curl -fsSL https://antigravity.google/install.sh | bash || {
                    warn "Pemasangan via install.sh resmi selesai atau memerlukan konfirmasi manual."
                }
                success "Setup Google Antigravity CLI selesai. Pastikan ~/.local/bin berada di PATH."
            fi
            ;;
        "Google Antigravity IDE (Desktop Application)")
            info "Menyiapkan Google Antigravity IDE..."
            if [ -x "/opt/antigravity/antigravity" ] || command -v antigravity &>/dev/null; then
                success "Google Antigravity IDE sudah terpasang di sistem (/opt/antigravity/antigravity)."
            else
                info "Mengunduh dan mengonfigurasi installer resmi Antigravity IDE..."
                curl -fsSL https://antigravity.google/download/linux -o /tmp/antigravity.tar.gz 2>/dev/null || true
                if [ -s /tmp/antigravity.tar.gz ]; then
                    sudo mkdir -p /opt/antigravity
                    sudo tar -xzf /tmp/antigravity.tar.gz -C /opt/antigravity --strip-components=1 || true
                    sudo ln -sf /opt/antigravity/antigravity /usr/local/bin/antigravity
                    rm -f /tmp/antigravity.tar.gz
                fi
                # Buat desktop shortcut jika belum ada
                if [ ! -f /usr/share/applications/antigravity.desktop ] && [ -f /opt/antigravity/antigravity ]; then
                    sudo tee /usr/share/applications/antigravity.desktop >/dev/null << 'DESKTOP_EOF'
[Desktop Entry]
Name=Antigravity
Comment=Antigravity 2.0
Exec=/opt/antigravity/antigravity %U
Icon=/opt/antigravity/icon.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=antigravity
DESKTOP_EOF
                fi
                success "Google Antigravity IDE berhasil dikonfigurasi."
            fi
            ;;
        "Visual Studio Code")
            info "Menginstall Visual Studio Code..."
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            sudo dnf check-update || true
            sudo dnf install -y code
            ;;
        "Docker Engine & Docker Compose")
            info "Menginstall Docker Engine & Docker Compose..."
            sudo dnf -y install dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl enable --now docker
            sudo usermod -aG docker "$USER"
            warn "User $USER telah ditambahkan ke grup 'docker'. Harap logout dan login kembali untuk menggunakan docker tanpa sudo."
            ;;
        "Fastfetch & Neovim")
            info "Menginstall Fastfetch & Neovim..."
            sudo dnf install -y fastfetch neovim
            ;;
        "HTop & BTop")
            info "Menginstall HTop & BTop..."
            sudo dnf install -y htop btop
            ;;
        "BleachBit (System Cleaner)")
            info "Menginstall BleachBit..."
            sudo dnf install -y bleachbit
            ;;
        "EasyEffects & Plugins (Audio Enhancer / Equalizer)")
            info "Menginstall EasyEffects dan audio plugins (LSP, Calf)..."
            sudo dnf install -y easyeffects lsp-plugins-lv2 lv2-calf-plugins
            ;;
        "Flatseal (Flatpak Permissions Manager)")
            info "Menginstall Flatseal..."
            sudo dnf install -y flatseal || sudo flatpak install -y flathub com.github.tchx84.Flatseal
            ;;
    esac
done

success "Instalasi aplikasi RPM selesai."
