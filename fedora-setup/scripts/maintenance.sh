#!/usr/bin/env bash
# ==============================================================================
# Maintenance & System Health Check
# Pembersihan cache, kernel lama, flatpak unused, status hardware & services
# ==============================================================================

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env.sh"

echo ""
gum style \
    --foreground 39 --border-foreground 39 --border double \
    --align center --width 60 --padding "1 2" \
    "SYSTEM HEALTH & MAINTENANCE" "Post-Setup Diagnostic & Cleanup Utility"

info "Pilih tugas maintenance yang ingin dijalankan (Spasi untuk memilih, Enter untuk konfirmasi):"

CHOICES=$(gum choose --no-limit \
    "System Health Check (Hardware, Services, GPU & Btrfs Status)" \
    "Clean Package Caches & Old Kernels (DNF / APT & Flatpak Clean)" \
    "Btrfs Scrub & Filesystem Health Check" \
    "Rollback / Restore Dotfiles dari Backup (~/.dotfiles_backup)")

if [ -z "$CHOICES" ]; then
    info "Tidak ada tugas maintenance yang dipilih."
    exit 0
fi

mapfile -t SELECTED_TASKS <<< "$CHOICES"

for task in "${SELECTED_TASKS[@]}"; do
    [ -z "$task" ] && continue
    case "$task" in
        "System Health Check"*)
            echo ""
            gum style --foreground 99 --bold ">>> Menjalankan Diagnostik Kesehatan Sistem..."

            # 1. Status Baterai & Daya ASUS
            echo ""
            info "--- [Kesehatan Baterai & Daya] ---"
            if command -v asusctl &>/dev/null; then
                asusctl battery info 2>/dev/null || true
                PROF="$(asusctl profile get 2>/dev/null || echo 'Unknown')"
                echo "Profile Daya ASUS: $PROF"
            fi
            for bat_cap in /sys/class/power_supply/BAT*/capacity; do
                if [ -f "$bat_cap" ]; then
                    echo "Kapasitas Baterai ($(basename "$(dirname "$bat_cap")")): $(cat "$bat_cap" 2>/dev/null)%"
                fi
            done

            # 2. Status GPU (Mux / Hybrid)
            echo ""
            info "--- [Status GPU Switcher] ---"
            if command -v supergfxctl &>/dev/null; then
                echo "Mode Grafis Aktif: $(supergfxctl -g 2>/dev/null || echo 'Unknown')"
            fi

            # 3. Status Service Esensial
            echo ""
            info "--- [Status Background Services] ---"
            SERVICES=("asusd.service" "supergfxd.service" "thermald.service" "tuned.service" "preload.service")
            for s in "${SERVICES[@]}"; do
                if systemctl is-active --quiet "$s"; then
                    echo -e "  [+] $s : \033[0;32mRUNNING\033[0m"
                else
                    echo -e "  [-] $s : \033[0;33mNOT RUNNING / INACTIVE\033[0m"
                fi
            done

            # 4. Penggunaan RAM & Zram
            echo ""
            info "--- [Penggunaan Memori & Swap / ZRAM] ---"
            free -h
            ;;

        "Clean Package Caches & Old Kernels"*)
            echo ""
            gum style --foreground 99 --bold ">>> Membersihkan Cache Sistem & Paket Tidak Terpakai..."
            
            if command -v dnf &>/dev/null; then
                info "Membersihkan metadata dan cache DNF..."
                sudo dnf clean all
                info "Menghapus dependensi yang tidak lagi dibutuhkan (dnf autoremove)..."
                sudo dnf autoremove -y
            elif command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
                info "Membersihkan cache paket APT..."
                sudo apt-get clean
                info "Menghapus dependensi yang tidak lagi dibutuhkan (apt autoremove)..."
                sudo apt-get autoremove -y
            fi

            if command -v flatpak &>/dev/null; then
                info "Menghapus runtime Flatpak yang tidak terpakai (flatpak uninstall --unused)..."
                flatpak uninstall --unused -y || true
            fi

            if command -v bleachbit &>/dev/null; then
                info "BleachBit terpasang. Anda dapat menjalankan 'bleachbit' untuk pembersihan mendalam."
            fi

            success "Pembersihan cache paket selesai."
            ;;

        "Btrfs Scrub & Filesystem Health Check"*)
            echo ""
            gum style --foreground 99 --bold ">>> Memeriksa Kesehatan Filesystem Btrfs..."
            
            if command -v btrfs &>/dev/null; then
                info "Menampilkan penggunaan ruang filesystem Btrfs (/) & (/home)..."
                sudo btrfs filesystem usage / 2>/dev/null || df -h /
                
                if gum confirm "Jalankan btrfs scrub pada root (/) sekarang?"; then
                    info "Menjalankan btrfs scrub..."
                    sudo btrfs scrub start -B / || true
                    success "Scrub selesai."
                fi
            else
                warn "Btrfs tool tidak ditemukan."
            fi
            ;;

        "Rollback / Restore Dotfiles"*)
            echo ""
            gum style --foreground 99 --bold ">>> Rollback / Restore Dotfiles dari Backup..."
            BACKUP_DIR="$HOME/.dotfiles_backup"
            
            if [ ! -d "$BACKUP_DIR" ]; then
                warn "Direktori backup $BACKUP_DIR tidak ditemukan."
                continue
            fi

            info "Pilih opsi pemulihan dotfiles:"
            RESTORE_ACTION=$(gum choose \
                "Rollback ~/.zshrc dari Riwayat Backup (Timestamp)" \
                "Rollback ~/.config/starship.toml dari Riwayat Backup (Timestamp)" \
                "Restore Semua dari Backup Terakhir (.latest)" \
                "Batal")

            case "$RESTORE_ACTION" in
                "Rollback ~/.zshrc"*)
                    mapfile -t ZSH_FILES < <(find "$BACKUP_DIR" -maxdepth 1 -name ".zshrc.backup.*" -printf "%f\n" 2>/dev/null | sort -r)
                    if [ ${#ZSH_FILES[@]} -eq 0 ]; then
                        warn "Tidak ada file riwayat backup ~/.zshrc di $BACKUP_DIR"
                    else
                        info "Pilih snapshot backup ~/.zshrc yang ingin di-restore:"
                        CHOSEN_ZSH=$(gum choose "${ZSH_FILES[@]}")
                        if [ -n "$CHOSEN_ZSH" ] && [ -f "$BACKUP_DIR/$CHOSEN_ZSH" ]; then
                            if [ -f "$HOME/.zshrc" ]; then
                                SAFETY_BACKUP="$BACKUP_DIR/.zshrc.pre_restore.$(date +%Y%m%d%H%M%S)"
                                cp "$HOME/.zshrc" "$SAFETY_BACKUP"
                                info "Safety snapshot dibuat: $SAFETY_BACKUP"
                            fi
                            cp "$BACKUP_DIR/$CHOSEN_ZSH" "$HOME/.zshrc"
                            success "Berhasil merestore ~/.zshrc dari snapshot: $CHOSEN_ZSH"
                        fi
                    fi
                    ;;

                "Rollback ~/.config/starship.toml"*)
                    mapfile -t STARSHIP_FILES < <(find "$BACKUP_DIR" -maxdepth 1 -name "starship.toml.backup.*" -printf "%f\n" 2>/dev/null | sort -r)
                    if [ ${#STARSHIP_FILES[@]} -eq 0 ]; then
                        warn "Tidak ada file riwayat backup starship.toml di $BACKUP_DIR"
                    else
                        info "Pilih snapshot backup starship.toml yang ingin di-restore:"
                        CHOSEN_STARSHIP=$(gum choose "${STARSHIP_FILES[@]}")
                        if [ -n "$CHOSEN_STARSHIP" ] && [ -f "$BACKUP_DIR/$CHOSEN_STARSHIP" ]; then
                            mkdir -p "$HOME/.config"
                            if [ -f "$HOME/.config/starship.toml" ]; then
                                SAFETY_BACKUP="$BACKUP_DIR/starship.toml.pre_restore.$(date +%Y%m%d%H%M%S)"
                                cp "$HOME/.config/starship.toml" "$SAFETY_BACKUP"
                                info "Safety snapshot dibuat: $SAFETY_BACKUP"
                            fi
                            cp "$BACKUP_DIR/$CHOSEN_STARSHIP" "$HOME/.config/starship.toml"
                            success "Berhasil merestore ~/.config/starship.toml dari snapshot: $CHOSEN_STARSHIP"
                        fi
                    fi
                    ;;

                "Restore Semua dari Backup Terakhir"*)
                    if [ -f "$BACKUP_DIR/.zshrc.latest" ]; then
                        cp "$BACKUP_DIR/.zshrc.latest" "$HOME/.zshrc"
                        success "$HOME/.zshrc berhasil di-restore dari .latest"
                    fi
                    if [ -f "$BACKUP_DIR/starship.toml.latest" ]; then
                        mkdir -p "$HOME/.config"
                        cp "$BACKUP_DIR/starship.toml.latest" "$HOME/.config/starship.toml"
                        success "$HOME/.config/starship.toml berhasil di-restore dari .latest"
                    fi
                    ;;
                *)
                    info "Batal melakukan pemulihan dotfiles."
                    ;;
            esac
            ;;
    esac
done

echo ""
success "============================================================"
success " Proses Maintenance & Diagnostic Selesai!"
success "============================================================"
