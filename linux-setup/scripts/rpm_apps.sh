#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

render_breadcrumb "Aplikasi Sistem Native (DNF / APT)"

gum style \
    --foreground 33 --border-foreground 33 --border rounded \
    --align center --width 64 --padding "1 2" --bold \
    "NATIVE APPLICATION REPOSITORY" "Developer Tools, Antigravity, VSCode, Docker & Utilities"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali"

CHOICES=$(gum choose --no-limit \
    --cursor="❯ " \
    --cursor.foreground="33" \
    --selected.foreground="82" \
    "⬅️   [Kembali ke Menu Utama]" \
    "Development Tools (gcc, make, git, curl, wget, cmake)" \
    "Google Antigravity CLI (agy)" \
    "Google Antigravity IDE (Desktop Application)" \
    "Visual Studio Code" \
    "Docker Engine & Docker Compose" \
    "Fastfetch & Neovim" \
    "BTop (Modern Resource Monitor)" \
    "BleachBit (System Cleaner)" \
    "EasyEffects & Plugins (Audio Enhancer / Equalizer)" \
    "Flatseal (Flatpak Permissions Manager)" || true)

if [ -z "$CHOICES" ] || [[ "$CHOICES" == *"Kembali ke Menu Utama"* ]]; then
    info "Kembali ke Menu Utama..."
    exit 0
fi

mapfile -t SELECTED_APPS <<< "$CHOICES"

for choice in "${SELECTED_APPS[@]}"; do
    [ -z "$choice" ] && continue
    case "$choice" in
        "Development Tools"*)
            info "Menginstall Development Tools..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo dnf install -y gcc gcc-c++ make git curl wget cmake
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo apt-get install -y build-essential gcc g++ make git curl wget cmake
            fi
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
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                sudo dnf check-update || true
                sudo dnf install -y code
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo apt-get install -y wget gpg apt-transport-https
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
                sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
                rm -f /tmp/packages.microsoft.gpg
                echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
                sudo apt-get update -qq
                sudo apt-get install -y code
            fi
            ;;
        "Docker Engine & Docker Compose")
            info "Menginstall Docker Engine & Docker Compose..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo dnf -y install dnf-plugins-core
                sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo apt-get update -qq
                sudo apt-get install -y ca-certificates curl
                sudo install -m 0755 -d /etc/apt/keyrings
                sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                sudo chmod a+r /etc/apt/keyrings/docker.asc
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -qq
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            fi
            sudo systemctl enable --now docker
            sudo usermod -aG docker "$USER"
            warn "User $USER telah ditambahkan ke grup 'docker'. Harap logout dan login kembali untuk menggunakan docker tanpa sudo."
            ;;
        "Fastfetch & Neovim")
            info "Menginstall Fastfetch & Neovim..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo dnf install -y fastfetch neovim
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo apt-get install -y neovim
                sudo apt-get install -y fastfetch 2>/dev/null || {
                    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null || true
                    sudo apt-get update -qq 2>/dev/null || true
                    sudo apt-get install -y fastfetch 2>/dev/null || true
                }
            fi
            ;;
        "BTop"*)
            info "Menginstall BTop..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo dnf install -y btop
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo apt-get install -y btop
            fi
            ;;
        "BleachBit (System Cleaner)")
            info "Menginstall BleachBit..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo dnf install -y bleachbit
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo apt-get install -y bleachbit
            fi
            ;;
        "EasyEffects & Plugins (Audio Enhancer / Equalizer)")
            info "Menginstall EasyEffects..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo dnf install -y easyeffects lsp-plugins-lv2 lv2-calf-plugins
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo apt-get install -y easyeffects 2>/dev/null || sudo flatpak install -y flathub com.github.wwmm.easyeffects
            fi
            ;;
        "Flatseal (Flatpak Permissions Manager)")
            info "Menginstall Flatseal..."
            if [ "$DISTRO_TYPE" = "fedora" ]; then
                sudo dnf install -y flatseal || sudo flatpak install -y flathub com.github.tchx84.Flatseal
            elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
                sudo flatpak install -y flathub com.github.tchx84.Flatseal
            fi
            ;;
    esac
done

success "Instalasi aplikasi native selesai."
