#!/usr/bin/env python3
import subprocess
import time
import os
from PIL import Image

PROJECT_ROOT = "/home/faulfedora/Documents/Script/personal-fresh-linux-setup"
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "screenshoots")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Definition of screens to capture
SCREENS = [
    {
        "filename": "01_language_selection.png",
        "cmd": '''
clear
gum style \\
    --foreground 212 --border-foreground 212 --border rounded \\
    --align center --width 68 --margin "0 1 1 1" --padding "1 2" --bold \\
    "$(gum style --foreground 39 --bold '█░█ █ █░░ ▄▀█ █░░ █▀█ █▄▄')" \\
    "$(gum style --foreground 39 --bold '█▀█ █ █▄▄ █▀█ █▄▄ █▄█ █▄█')" \\
    "" \\
    "Fresh Linux Setup Suite" \\
    "Language Selection • Pemilihan Bahasa"

echo ""
gum style --foreground 245 " [↑/↓] Select / Pilih • [Enter] Confirm / Konfirmasi"

gum choose \\
    --cursor="❯ " \\
    --cursor.foreground="212" \\
    --header="Choose your preferred language / Pilih bahasa yang digunakan:" \\
    "🇮🇩  Bahasa Indonesia (Default)" \\
    "🇬🇧  English (International)"
'''
    },
    {
        "filename": "02_main_dashboard.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
DISTRO_NAME="Fedora Linux 41 (KDE Plasma)"
CURRENT_DESKTOP="KDE Plasma 6"
KERNEL_VER="6.13.4-200.fc41.x86_64"
HOST_NAME="asus-rog-strix"
SYS_USER="faulfedora"
DISTRO_TYPE="fedora"
clear
echo ""
gum style \\
    --foreground 212 --border-foreground 212 --border rounded \\
    --align center --width 68 --margin "0 1 1 1" --padding "1 2" --bold \\
    "$(gum style --foreground 39 --bold '█░█ █ █░░ ▄▀█ █░░ █▀█ █▄▄')" \\
    "$(gum style --foreground 39 --bold '█▀█ █ █▄▄ █▀█ █▄▄ █▄█ █▄█')" \\
    "" \\
    "Fresh Linux Setup Suite" \\
    "Personal System Setup & Automation Dashboard" \\
    "" \\
    "$(gum style --foreground 245 --faint "OS: $DISTRO_NAME ($CURRENT_DESKTOP) • Kernel: $KERNEL_VER")" \\
    "$(gum style --foreground 245 --faint "User: $SYS_USER@$HOST_NAME • Distro Target: ${DISTRO_TYPE^^}")"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi Pilihan • [Enter] Buka Modul • [Esc] Keluar"

gum choose \\
    --cursor="❯ " \\
    --cursor.foreground="212" \\
    --header="Pilih modul yang ingin Anda konfigurasi:" \\
    "🎯  Instalasi Berbasis Profil / Presets (Quick Setup)" \\
    "💻  Setup Shell & Terminal (Zsh, Starship, Dotfiles)" \\
    "🛠️  Install Developer Runtimes (fnm/Node, uv/Python, Rust, Go)" \\
    "⚡  Install System Essentials & Media Codecs" \\
    "📦  Install Aplikasi Sistem Native (DNF / APT)" \\
    "🚀  Install Aplikasi Flatpak (Flathub)" \\
    "🎮  Setup & Konfigurasi ASUS ROG / TUF Utilities" \\
    "🔑  Setup Identitas Git & SSH Key Developer" \\
    "🩺  System Maintenance & Health Check (Rollback Dotfiles)" \\
    "🌐  Ganti Bahasa / Change Language (ID ⇄ EN)" \\
    "────────────────────────────────────────────────────────────" \\
    "🚪  Keluar / Selesai"
'''
    },
    {
        "filename": "03_profiles_presets.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "Instalasi Berbasis Profil (Presets)"

gum style \\
    --foreground 208 --border-foreground 208 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "QUICK SETUP PROFILES & PRESETS" \\
    "Otomasi Setup Cepat Sesuai Kebutuhan Anda"

echo ""
gum style --foreground 245 " [↑/↓] Pilih Profil • [Enter] Tinjau & Pasang • [Esc] Kembali"

gum choose \\
    --cursor="❯ " \\
    --cursor.foreground="208" \\
    --header="Pilih profil instalasi yang ingin dipasang:" \\
    "💻  Minimal Developer (Zsh, Starship, FiraCode Font, Dev Tools, fnm, uv, Docker, Neovim)" \\
    "🎨  Full Workstation (Minimal Dev + Codecs, VA-API, Snapper, Office, VSCode, Flatpaks)" \\
    "🎮  Gaming & Creator (Codecs, Steam, Discord, OBS Studio, GameMode, MangoHud)" \\
    "⚡  ASUS ROG / TUF Suite (Minimal Dev + System Essentials + asusctl & Battery Limit)" \\
    "⬅️   [Kembali ke Menu Utama]"
'''
    },
    {
        "filename": "04_setup_terminal.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "Setup Shell & Terminal Workspace"

gum style \\
    --foreground 45 --border-foreground 45 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "TERMINAL & SHELL WORKSPACE" "Zsh, Starship, FiraCode Nerd Font & Dotfiles"

echo ""
gum choose \\
    --cursor="❯ " \\
    --cursor.foreground="45" \\
    --header="Pilih mode setup terminal:" \\
    "🚀  Jalankan Setup Lengkap (CLI Tools, Font, Plugins, Dotfiles)" \\
    "🎨  Hanya Terapkan Dotfiles (~/.zshrc & starship.toml)" \\
    "🔤  Hanya Install FiraCode Nerd Font & Konfigurasi Profil Terminal" \\
    "⬅️   [Kembali ke Menu Utama]"
'''
    },
    {
        "filename": "05_dev_runtimes.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "Developer Runtimes Setup"

gum style \\
    --foreground 220 --border-foreground 220 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "DEVELOPER RUNTIMES MANAGER" "Node.js, Python, Rust, Go, Java & PHP"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali"

gum choose --no-limit \\
    --cursor="❯ " \\
    --cursor.foreground="220" \\
    --selected.foreground="82" \\
    "⬅️   [Kembali ke Menu Utama]" \\
    "Node.js LTS via fnm (Fast Node Manager) + pnpm" \\
    "Python via uv (Ultra-fast Python & Package Manager)" \\
    "Rust Language Toolchain (rustup & cargo)" \\
    "Go Toolchain (Golang Compiler & Tools)" \\
    "Java Development Kit (OpenJDK LTS)" \\
    "PHP & Composer (Modern PHP CLI & Package Manager)"
'''
    },
    {
        "filename": "06_system_essentials.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "System Essentials & Media Codecs"

gum style \\
    --foreground 141 --border-foreground 141 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "SYSTEM ESSENTIALS & CODECS" "Multimedia, Btrfs Snapshots & Optimasi Desktop"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali"

gum choose --no-limit \\
    --cursor="❯ " \\
    --cursor.foreground="141" \\
    --selected.foreground="82" \\
    "⬅️   [Kembali ke Menu Utama]" \\
    "Multimedia Codecs Lengkap (FFmpeg, GStreamer, libdvdcss, Audio/Video Extras)" \\
    "Hardware Video Acceleration / Drivers (VA-API, Mesa Freeworld, Intel/AMD)" \\
    "System Utilities & Compression (p7zip, unrar, tar, rsync, lshw, pciutils)" \\
    "KDE Plasma Enhancements (KDE Connect, Flatpak KCM integration)" \\
    "Btrfs Assistant & Snapper (GUI Snapshot, Maintenance, Subvolume Management)" \\
    "System Performance & Thermal Tuning (thermald, tuned, preload)" \\
    "Kernel & Sysctl Desktop Tuning (ZRAM Swappiness, File Watcher Handles)"
'''
    },
    {
        "filename": "07_rpm_apps.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "Aplikasi Sistem Native (DNF / APT)"

gum style \\
    --foreground 33 --border-foreground 33 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "NATIVE APPLICATION REPOSITORY" "Developer Tools, Antigravity, VSCode, Docker & Utilitas"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali"

gum choose --no-limit \\
    --cursor="❯ " \\
    --cursor.foreground="33" \\
    --selected.foreground="82" \\
    "⬅️   [Kembali ke Menu Utama]" \\
    "Development Tools (gcc, make, git, curl, wget, cmake)" \\
    "Google Antigravity CLI (agy)" \\
    "Google Antigravity IDE (Desktop Application)" \\
    "Visual Studio Code" \\
    "Docker Engine & Docker Compose" \\
    "Fastfetch & Neovim" \\
    "BTop (Modern Resource Monitor)" \\
    "BleachBit (System Cleaner)" \\
    "EasyEffects & Plugins (Audio Enhancer / Equalizer)" \\
    "Flatseal (Flatpak Permissions Manager)"
'''
    },
    {
        "filename": "08_flatpak_apps.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "Aplikasi Flatpak (Flathub)"

gum style \\
    --foreground 69 --border-foreground 69 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "FLATHUB APPLICATION STORE" "Aplikasi Desktop Terisolasi & Produktivitas"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali"

gum choose --no-limit \\
    --cursor="❯ " \\
    --cursor.foreground="69" \\
    --selected.foreground="82" \\
    "⬅️   [Kembali ke Menu Utama]" \\
    "Google Chrome" \\
    "ONLYOFFICE Desktop Editors" \\
    "Thunderbird Mail ESR" \\
    "Discord" \\
    "Spotube (Spotify Client)" \\
    "VLC Media Player" \\
    "Pika Backup" \\
    "DBeaver Community" \\
    "Bruno API Client" \\
    "Logseq" \\
    "LocalSend" \\
    "Podman Desktop" \\
    "Arduino IDE"
'''
    },
    {
        "filename": "09_asus_setup.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "ASUS ROG / TUF Gaming Utility"

gum style \\
    --foreground 196 --border-foreground 196 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "ROG & TUF GAMING UTILITY" "ASUS Power, GPU MUX Switch & Perawatan Baterai"

echo ""
gum choose \\
    --cursor="❯ " \\
    --cursor.foreground="196" \\
    --header="Pilih tindakan utilitas ASUS ROG / TUF:" \\
    "⚡  Setup Lengkap (Install Driver, Background Services & Konfigurasi)" \\
    "⚙️   Hanya Buka Pengaturan (Battery Limit, Profil Daya, GPU Switcher)" \\
    "⬅️   [Kembali ke Menu Utama]"
'''
    },
    {
        "filename": "10_git_ssh_setup.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "Git Identity & SSH Key Setup"

gum style \\
    --foreground 214 --border-foreground 214 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "GIT & SSH DEVELOPER SETUP" "Identitas Global & Autentikasi Ed25519"

echo ""
gum choose \\
    --cursor="❯ " \\
    --cursor.foreground="214" \\
    --header="Pilih tindakan Git & SSH:" \\
    "⚡  Konfigurasi Identitas Git & Generate SSH Key" \\
    "📋  Tampilkan & Salin Public SSH Key yang Ada" \\
    "⬅️   [Kembali ke Menu Utama]"
'''
    },
    {
        "filename": "11_system_maintenance.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "System Health & Maintenance"

gum style \\
    --foreground 39 --border-foreground 39 --border double \\
    --align center --width 60 --padding "1 2" \\
    "SYSTEM HEALTH & MAINTENANCE" "Utilitas Diagnostik & Pembersihan Sistem"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali"

gum choose --no-limit \\
    --cursor="❯ " \\
    --cursor.foreground="39" \\
    --selected.foreground="82" \\
    "⬅️   [Kembali ke Menu Utama]" \\
    "System Health Check (Hardware, Services, GPU & Btrfs Status)" \\
    "Clean Package Caches & Old Kernels (DNF / APT & Flatpak Clean)" \\
    "Btrfs Scrub & Filesystem Health Check" \\
    "Buat Snapshot Sistem Manual (Snapper / Timeshift)" \\
    "Lihat Log Setup Terpusat (~/.cache/.../setup.log)" \\
    "Rollback / Restore Dotfiles dari Backup (~/.dotfiles_backup)"
'''
    },
    {
        "filename": "12_asus_settings_subscreen.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "ASUS ROG / TUF Gaming Utility > Pengaturan Hardware"

gum style \\
    --foreground 196 --border-foreground 196 --border rounded \\
    --align center --width 64 --padding "1 2" --bold \\
    "ASUS HARDWARE CONFIGURATION" "Baterai 80%, Profil Daya & GPU Switcher"

echo ""
gum style --foreground 245 " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali"

gum choose --no-limit \\
    --cursor="❯ " \\
    --cursor.foreground="196" \\
    --selected.foreground="82" \\
    "⬅️   [Kembali ke Menu Utama]" \\
    "Atur Batas Pengisian Baterai ke 80% (Battery Charge Limit)" \\
    "Aktifkan Profil Daya Performance (asusctl profile)" \\
    "Aktifkan Mode GPU Hybrid / Dynamic Switcher (supergfxctl)" \\
    "Set Kecerahan Keyboard Backlight (asusctl leds)"
'''
    },
    {
        "filename": "13_health_check_summary.png",
        "cmd": '''
source linux-setup/scripts/env.sh
export SETUP_LANG=id
clear
render_breadcrumb "System Health & Maintenance > Diagnostic Report"
echo ""
gum style --foreground 99 --bold ">>> Menjalankan Diagnostik Kesehatan Sistem..."
echo ""
info "--- [Kesehatan Baterai & Daya] ---"
echo "Profile Daya ASUS: Performance"
echo "Kapasitas Baterai (BAT0): 98% (Health: Excellent)"
echo ""
info "--- [Penggunaan Ruang Penyimpanan Btrfs / Root] ---"
df -h / | awk 'NR==1 || NR==2'
echo ""
info "--- [Status GPU & Penghematan Daya] ---"
echo "GPU Mode: Hybrid (Intel UHD + NVIDIA RTX 4060 Laptop)"
echo ""
info "--- [Pemeriksaan Layanan Sistem] ---"
echo "✓ thermald.service    [ACTIVE]"
echo "✓ tuned.service       [ACTIVE]"
echo "✓ snapper-timeline    [ACTIVE]"
echo ""
gum style --border rounded --border-foreground 82 --padding "1 2" \\
    "✓ DIAGNOSTIK KESEHATAN SISTEM SELESAI" \\
    "Sistem beroperasi secara optimal tanpa masalah terdeteksi."
'''
    }
]

def capture_screen(screen_info):
    filename = screen_info["filename"]
    cmd_text = screen_info["cmd"]
    out_path = os.path.join(OUTPUT_DIR, filename)
    win_temp = os.path.join(OUTPUT_DIR, f"temp_{filename}")

    full_shell_cmd = f"cd {PROJECT_ROOT} && {cmd_text.strip()} && sleep 3"

    proc = subprocess.Popen([
        'konsole', '--qwindowgeometry', '960x1080+0+0', '-e', 'bash', '-c', full_shell_cmd
    ])
    
    time.sleep(1.4)
    
    # Capture active window
    subprocess.run(['spectacle', '-a', '-b', '-o', win_temp])
    proc.kill()

    if os.path.exists(win_temp):
        win = Image.open(win_temp)
        
        # Create 960x1080 canvas with Catppuccin Mocha dark background #181825
        canvas = Image.new('RGBA', (960, 1080), (24, 24, 37, 255))
        
        w, h = win.size
        # Fit window nicely into 960x1080 canvas with padding
        scale = min((960 - 30) / w, (1080 - 30) / h, 1.0)
        new_w, new_h = int(w * scale), int(h * scale)
        win_resized = win.resize((new_w, new_h), Image.Resampling.LANCZOS)
        
        pos_x = (960 - new_w) // 2
        pos_y = (1080 - new_h) // 2
        
        canvas.paste(win_resized, (pos_x, pos_y), win_resized if win_resized.mode == 'RGBA' else None)
        canvas.save(out_path)
        
        print(f"✓ Saved {filename} -> Size: {canvas.size}")
        if os.path.exists(win_temp):
            os.remove(win_temp)
    else:
        print(f"✗ Failed to capture {filename}")

def main():
    print(f"Generating {len(SCREENS)} screenshots in 960x1080 resolution...")
    for idx, s in enumerate(SCREENS, 1):
        print(f"[{idx}/{len(SCREENS)}] Capturing {s['filename']}...")
        capture_screen(s)
        time.sleep(0.5)
    print("\nAll screenshots generated successfully in 'screenshoots/' directory!")

if __name__ == "__main__":
    main()
