#!/usr/bin/env bash
set -e

source "$(dirname "$0")/env.sh"

info "Pilih aplikasi berbasis RPM (DNF) yang ingin diinstall:"

# Menggunakan \n delimiter untuk multiple choice karena gum choose per line
CHOICES=$(gum choose --no-limit \
    "Development Tools (gcc, make, git, curl, wget, cmake)" \
    "Visual Studio Code" \
    "Docker Engine & Docker Compose" \
    "Fastfetch & Neovim" \
    "HTop & BTop")

if [ -z "$CHOICES" ]; then
    info "Tidak ada aplikasi RPM yang dipilih."
    exit 0
fi

# Loop setiap baris yang dipilih
echo "$CHOICES" | while read -r choice; do
    case "$choice" in
        "Development Tools"*)
            info "Menginstall Development Tools..."
            sudo dnf install -y gcc gcc-c++ make git curl wget cmake
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
    esac
done

success "Instalasi aplikasi RPM selesai."
