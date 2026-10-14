#!/usr/bin/env bash
set -eo pipefail

# ==============================================================================
# Environment Setup & Helpers
# ==============================================================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Centralized Logging Setup
LOG_DIR="${HOME}/.cache/fresh-linux-setup"
LOG_FILE="${LOG_DIR}/setup.log"
mkdir -p "$LOG_DIR" 2>/dev/null || true
chmod 700 "$LOG_DIR" 2>/dev/null || true

# Safe HTTPS Download Helper (TLS 1.2+, HTTPS enforcement, retry & timeout)
safe_download() {
    local url="$1"
    local dest="$2"
    if ! curl --proto '=https' --tlsv1.2 -fsSL --retry 3 --connect-timeout 10 -o "$dest" "$url"; then
        warn "Gagal mengunduh $url (periksa koneksi atau URL)."
        return 1
    fi
    if [ ! -s "$dest" ]; then
        warn "Hasil unduhan kosong untuk $url"
        return 1
    fi
    return 0
}

# Create a secured temporary directory with restricted permissions (0700)
create_secure_tmp() {
    local prefix="${1:-fresh-setup}"
    local tmp_dir
    tmp_dir="$(mktemp -d -t "${prefix}.XXXXXX")"
    chmod 700 "$tmp_dir"
    echo "$tmp_dir"
}

_log_to_file() {
    local level="$1"
    local text="$2"
    local clean_text
    clean_text="$(echo -e "$text" | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g" 2>/dev/null || echo "$text")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $clean_text" >> "$LOG_FILE" 2>/dev/null || true
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    _log_to_file "INFO" "$1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    _log_to_file "SUCCESS" "$1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    _log_to_file "WARN" "$1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    _log_to_file "ERROR" "$1"
    exit 1
}

# Auto Btrfs / Snapper / Timeshift Snapshot Helper
create_system_snapshot() {
    local description="${1:-Pre-Setup-System-Snapshot}"
    info "$(_msg "Memeriksa dukungan snapshot sistem (Snapper / Timeshift)..." "Checking system snapshot support (Snapper / Timeshift)...")"

    if command -v snapper &>/dev/null && sudo snapper -c root list &>/dev/null 2>&1; then
        info "$(_msg "Membuat Snapper snapshot: '$description'..." "Creating Snapper snapshot: '$description'...")"
        if sudo snapper -c root create -d "$description" -c timeline 2>&1 | tee -a "$LOG_FILE"; then
            success "$(_msg "Snapper snapshot berhasil dibuat." "Snapper snapshot successfully created.")"
            return 0
        else
            warn "$(_msg "Gagal membuat Snapper snapshot." "Failed to create Snapper snapshot.")"
        fi
    elif command -v timeshift &>/dev/null; then
        info "$(_msg "Membuat Timeshift snapshot: '$description'..." "Creating Timeshift snapshot: '$description'...")"
        if sudo timeshift --create --comments "$description" --tags D 2>&1 | tee -a "$LOG_FILE"; then
            success "$(_msg "Timeshift snapshot berhasil dibuat." "Timeshift snapshot successfully created.")"
            return 0
        else
            warn "$(_msg "Gagal membuat Timeshift snapshot." "Failed to create Timeshift snapshot.")"
        fi
    else
        info "$(_msg "Snapper/Timeshift belum aktif di sistem ini. Melewati pembuatan snapshot." "Snapper/Timeshift not active on this system. Skipping snapshot.")"
    fi
    return 0
}

# Execution Summary Card Display
show_execution_summary() {
    local total_success="${1:-0}"
    local total_failed="${2:-0}"
    local profile_name="${3:-Setup}"

    echo ""
    if [ "$total_failed" -eq 0 ]; then
        gum style \
            --foreground 82 --border-foreground 82 --border rounded \
            --align center --width 64 --padding "1 2" --bold \
            "✓ $(_msg "EKSEKUSI SELESAI DENGAN SUKSES" "EXECUTION COMPLETED SUCCESSFULLY")" \
            "$profile_name: $total_success $(_msg "tugas berhasil" "tasks succeeded")" \
            "$(gum style --foreground 245 --faint "Log: $LOG_FILE")"
    else
        gum style \
            --foreground 214 --border-foreground 214 --border rounded \
            --align center --width 64 --padding "1 2" --bold \
            "⚠ $(_msg "EKSEKUSI SELESAI DENGAN CATATAN" "EXECUTION COMPLETED WITH WARNINGS")" \
            "$profile_name: $total_success $(_msg "berhasil" "succeeded"), $total_failed $(_msg "gagal" "failed")" \
            "$(gum style --foreground 245 --faint "$(_msg "Periksa log di" "Check log at"): $LOG_FILE")"
    fi
    echo ""
}

# Pre-flight System & Diagnostic Health Check
run_preflight_checks() {
    info "$(_msg "Menjalankan diagnostik & pre-flight checks sistem..." "Running system diagnostics & pre-flight checks...")"
    local issues=0

    # 1. Distro & Package Manager
    if [ "$DISTRO_TYPE" = "fedora" ]; then
        success "$(_msg "Distribusi: Fedora Workstation (dnf terdeteksi)" "Distribution: Fedora Workstation (dnf detected)")"
    elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
        success "$(_msg "Distribusi: Ubuntu (apt-get terdeteksi)" "Distribution: Ubuntu (apt-get detected)")"
    else
        warn "$(_msg "Distribusi tidak dikenal!" "Unknown distribution!")"
        issues=$((issues + 1))
    fi

    # 2. Internet Connectivity
    if curl -s --connect-timeout 4 -I https://github.com >/dev/null 2>&1; then
        success "$(_msg "Koneksi Internet: Terhubung ke GitHub" "Internet Connectivity: Connected to GitHub")"
    else
        warn "$(_msg "Koneksi Internet: Gagal menjangkau GitHub (periksa jaringan Anda)" "Internet Connectivity: Cannot reach GitHub (check your network)")"
        issues=$((issues + 1))
    fi

    # 3. Disk Space Check (/ root)
    local root_avail_kb
    root_avail_kb="$(df -k / | awk 'NR==2 {print $4}')"
    local root_avail_gb=$((root_avail_kb / 1024 / 1024))
    if [ "$root_avail_gb" -ge 5 ]; then
        success "$(_msg "Ruang Disk Root (/): ${root_avail_gb} GB tersedia (Cukup)" "Root Disk Space (/): ${root_avail_gb} GB available (Sufficient)")"
    else
        warn "$(_msg "Ruang Disk Root (/): ${root_avail_gb} GB tersedia (Rekomendasi minimal 5 GB)" "Root Disk Space (/): ${root_avail_gb} GB available (Recommended at least 5 GB)")"
        issues=$((issues + 1))
    fi

    # 4. System Snapshot Capability
    if command -v snapper &>/dev/null; then
        success "$(_msg "Snapshot Engine: Snapper terdeteksi" "Snapshot Engine: Snapper detected")"
    elif command -v timeshift &>/dev/null; then
        success "$(_msg "Snapshot Engine: Timeshift terdeteksi" "Snapshot Engine: Timeshift detected")"
    else
        info "$(_msg "Snapshot Engine: Snapper/Timeshift belum aktif (opsional)" "Snapshot Engine: Snapper/Timeshift not active (optional)")"
    fi

    # 5. Laptop Battery Check (if on battery and < 20%)
    if [ -d /sys/class/power_supply ]; then
        for bat in /sys/class/power_supply/BAT*; do
            if [ -d "$bat" ] && [ -f "$bat/capacity" ] && [ -f "$bat/status" ]; then
                local cap status
                cap="$(cat "$bat/capacity" 2>/dev/null || echo 100)"
                status="$(cat "$bat/status" 2>/dev/null || echo "Unknown")"
                if [ "$status" = "Discharging" ] && [ "$cap" -lt 20 ]; then
                    warn "$(_msg "Baterai laptop kritis (${cap}%, Discharging). Colok charger sebelum instalasi!" "Laptop battery critical (${cap}%, Discharging). Plug in charger before setup!")"
                    issues=$((issues + 1))
                else
                    info "$(_msg "Baterai Laptop: ${cap}% ($status)" "Laptop Battery: ${cap}% ($status)")"
                fi
            fi
        done
    fi

    echo ""
    if [ "$issues" -eq 0 ]; then
        success "$(_msg "Semua pre-flight check lulus! Sistem siap untuk instalasi." "All pre-flight checks passed! System ready for installation.")"
    else
        warn "$(_msg "Ditemukan $issues catatan pra-instalasi. Tinjau kembali sebelum melanjutkan." "Found $issues pre-flight warnings. Please review before proceeding.")"
    fi
    return 0
}

# Language / i18n helper (Default: id)
LANG_STATE_FILE="${LOG_DIR}/.setup_lang"
if [ -f "$LANG_STATE_FILE" ]; then
    SETUP_LANG="$(cat "$LANG_STATE_FILE" 2>/dev/null || echo 'id')"
elif [ -f /tmp/.setup_lang ]; then
    SETUP_LANG="$(cat /tmp/.setup_lang 2>/dev/null || echo 'id')"
fi
export SETUP_LANG="${SETUP_LANG:-id}"

_msg() {
    if [ "$SETUP_LANG" = "en" ]; then
        echo "$2"
    else
        echo "$1"
    fi
}

# Helper untuk merender breadcrumbs navigasi modern TUI
render_breadcrumb() {
    local PATH_STR="$1"
    local MAIN_LABEL
    MAIN_LABEL="$(_msg "Menu Utama" "Main Menu")"
    echo ""
    gum style --foreground 240 "🧭 $MAIN_LABEL > $PATH_STR"
}

# Fallback untuk environment root / container minimal tanpa command sudo
if ! command -v sudo &>/dev/null && [ "${EUID:-$(id -u)}" -eq 0 ]; then
    sudo() { "$@"; }
fi

# Deteksi Package Manager & Distribusi
if command -v pacman &>/dev/null; then
    error "Distribusi Arch Linux (pacman) tidak didukung. Skrip ini hanya mendukung Fedora Workstation dan Ubuntu (KDE / GNOME)."
fi

if command -v dnf &>/dev/null; then
    DISTRO_TYPE="fedora"
elif command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
    DISTRO_TYPE="ubuntu"
else
    error "Distribusi sistem tidak didukung. Skrip ini hanya mendukung Fedora Workstation dan Ubuntu (KDE / GNOME)."
fi

# Memastikan gum terinstall (dibutuhkan untuk TUI)
ensure_gum_installed() {
    if ! command -v gum &> /dev/null; then
        info "gum belum terpasang. Menginstall gum..."
        if [ "$DISTRO_TYPE" = "fedora" ]; then
            sudo dnf install -y gum >/dev/null 2>&1 || sudo dnf install -y gum
        elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
            sudo apt-get update -qq >/dev/null 2>&1 || true
            sudo apt-get install -y -qq curl gpg >/dev/null 2>&1 || true
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/charm.gpg 2>/dev/null || true
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
            sudo apt-get update -qq >/dev/null 2>&1 || true
            sudo apt-get install -y -qq gum >/dev/null 2>&1 || {
                local GUM_TEMP
                GUM_TEMP="$(create_secure_tmp "gum-setup")"
                if safe_download "https://github.com/charmbracelet/gum/releases/latest/download/gum_linux_amd64.tar.gz" "$GUM_TEMP/gum.tar.gz"; then
                    tar -xzf "$GUM_TEMP/gum.tar.gz" -C "$GUM_TEMP" --no-same-owner
                    local GUM_BIN
                    GUM_BIN="$(find "$GUM_TEMP" -maxdepth 2 -type f -name gum | head -n 1)"
                    if [ -n "$GUM_BIN" ] && [ -f "$GUM_BIN" ]; then
                        sudo install -m 0755 "$GUM_BIN" /usr/local/bin/gum
                    fi
                fi
                rm -rf "$GUM_TEMP"
            }
        fi

        if command -v gum &>/dev/null; then
            success "gum berhasil diinstall."
        else
            error "Gagal memasang 'gum'. Silakan pasang gum secara manual."
        fi
    fi
}

# Fungsi optimasi performa DNF (/etc/dnf/dnf.conf)
optimize_dnf_performance() {
    local DNF_CONF="/etc/dnf/dnf.conf"
    if [ -f "$DNF_CONF" ]; then
        local MODIFIED=false
        if ! grep -q "^max_parallel_downloads" "$DNF_CONF"; then
            echo "max_parallel_downloads=10" | sudo tee -a "$DNF_CONF" >/dev/null
            MODIFIED=true
        fi
        if ! grep -q "^fastestmirror" "$DNF_CONF"; then
            echo "fastestmirror=True" | sudo tee -a "$DNF_CONF" >/dev/null
            MODIFIED=true
        fi
        if ! grep -q "^defaultyes" "$DNF_CONF"; then
            echo "defaultyes=True" | sudo tee -a "$DNF_CONF" >/dev/null
            MODIFIED=true
        fi
        if [ "$MODIFIED" = true ]; then
            info "Optimasi konfigurasi DNF (/etc/dnf/dnf.conf) berhasil diterapkan."
        fi
    fi
}

# Fungsi inisialisasi repositori (RPM Fusion & Flathub) secara cepat & idempoten
setup_environment_repos() {
    if [ "$DISTRO_TYPE" = "fedora" ]; then
        optimize_dnf_performance

        # 1. Periksa apakah RPM Fusion sudah terpasang
        if ! rpm -q rpmfusion-free-release &>/dev/null || ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
            info "Menginstall RPM Fusion Free & Non-Free..."
            local FEDORA_VER
            FEDORA_VER="$(rpm -E %fedora 2>/dev/null || echo '41')"
            sudo dnf install -y \
                "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
                "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm" >/dev/null 2>&1 || true
        fi

        # 2. Periksa RPM Fusion Tainted
        if ! rpm -q rpmfusion-free-release-tainted &>/dev/null || ! rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
            info "Menginstall RPM Fusion Tainted..."
            sudo dnf install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted >/dev/null 2>&1 || true
        fi
    elif [ "$DISTRO_TYPE" = "ubuntu" ]; then
        info "Memeriksa repositori universe & multiverse pada Ubuntu..."
        sudo apt-get update -qq >/dev/null 2>&1 || true
        if command -v add-apt-repository &>/dev/null; then
            sudo add-apt-repository -y universe >/dev/null 2>&1 || true
            sudo add-apt-repository -y multiverse >/dev/null 2>&1 || true
        else
            sudo apt-get install -y -qq software-properties-common >/dev/null 2>&1 || true
            sudo add-apt-repository -y universe >/dev/null 2>&1 || true
            sudo add-apt-repository -y multiverse >/dev/null 2>&1 || true
        fi
    fi

    # 3. Flathub remote
    if command -v flatpak &>/dev/null; then
        if ! flatpak remotes 2>/dev/null | grep -q "flathub"; then
            info "Menambahkan remote Flathub..."
            sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || true
        fi
    fi
}

ensure_gum_installed

# Jalankan setup_environment_repos langsung hanya jika skrip ini dieksekusi secara independen
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_environment_repos
    success "Inisialisasi environment repositori selesai."
fi
