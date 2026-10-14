#!/usr/bin/env bash
# ==============================================================================
# Maintenance & System Health Check
# Pembersihan cache, kernel lama, flatpak unused, status hardware & services
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env.sh"

render_breadcrumb "$(_msg "System Health & Maintenance" "System Health & Maintenance")"

gum style \
    --foreground 39 --border-foreground 39 --border double \
    --align center --width 60 --padding "1 2" \
    "SYSTEM HEALTH & MAINTENANCE" "$(_msg "Utilitas Diagnostik & Pembersihan Sistem" "Post-Setup Diagnostic & Cleanup Utility")"

echo ""
gum style --foreground 245 "$(_msg " [↑/↓] Navigasi • [Spasi] Pilih / Batal Centang • [Enter] Konfirmasi • [Esc] Kembali" " [↑/↓] Navigate • [Space] Toggle Selection • [Enter] Confirm • [Esc] Back")"

CHOICES=$(gum choose --no-limit \
    --cursor="❯ " \
    --cursor.foreground="39" \
    --selected.foreground="82" \
    "$(_msg "⬅️   [Kembali ke Menu Utama]" "⬅️   [Back to Main Menu]")" \
    "$(_msg "System Health Check (Hardware, Services, GPU & Btrfs Status)" "System Health Check (Hardware, Services, GPU & Btrfs Status)")" \
    "$(_msg "Security Audit & Firewall Status (UFW / firewalld & Open Ports)" "Security Audit & Firewall Status (UFW / firewalld & Open Ports)")" \
    "$(_msg "Clean Package Caches & Old Kernels (DNF / APT & Flatpak Clean)" "Clean Package Caches & Old Kernels (DNF / APT & Flatpak Clean)")" \
    "$(_msg "Btrfs Scrub & Filesystem Health Check" "Btrfs Scrub & Filesystem Health Check")" \
    "$(_msg "Buat Snapshot Sistem Manual (Snapper / Timeshift)" "Create Manual System Snapshot (Snapper / Timeshift)")" \
    "$(_msg "Lihat Log Setup Terpusat (~/.cache/.../setup.log)" "View Centralized Setup Log (~/.cache/.../setup.log)")" \
    "$(_msg "Rollback / Restore Dotfiles dari Backup (~/.dotfiles_backup)" "Rollback / Restore Dotfiles from Backup (~/.dotfiles_backup)")" || true)

if [ -z "$CHOICES" ] || [[ "$CHOICES" == *"Kembali"* ]] || [[ "$CHOICES" == *"Back"* ]]; then
    info "$(_msg "Kembali ke Menu Utama..." "Returning to Main Menu...")"
    exit 0
fi

mapfile -t SELECTED_TASKS <<< "$CHOICES"

for task in "${SELECTED_TASKS[@]}"; do
    [ -z "$task" ] && continue
    case "$task" in
        "System Health Check"*)
            echo ""
            gum style --foreground 99 --bold ">>> $(_msg "Menjalankan Diagnostik Kesehatan Sistem..." "Running System Health Diagnostics...")"

            # 1. Status Baterai & Daya ASUS
            echo ""
            info "$(_msg "--- [Kesehatan Baterai & Daya] ---" "--- [Battery & Power Health] ---")"
            if command -v asusctl &>/dev/null; then
                asusctl battery info 2>/dev/null || true
                PROF="$(asusctl profile get 2>/dev/null || echo 'Unknown')"
                echo "$(_msg "Profile Daya ASUS: $PROF" "ASUS Power Profile: $PROF")"
            fi
            for bat_cap in /sys/class/power_supply/BAT*/capacity; do
                if [ -f "$bat_cap" ]; then
                    echo "$(_msg "Kapasitas Baterai" "Battery Capacity") ($(basename "$(dirname "$bat_cap")")): $(cat "$bat_cap" 2>/dev/null)%"
                fi
            done

            # 2. Status GPU (Mux / Hybrid)
            echo ""
            info "$(_msg "--- [Status GPU Switcher] ---" "--- [GPU Switcher Status] ---")"
            if command -v supergfxctl &>/dev/null; then
                echo "$(_msg "Mode Grafis Aktif: " "Active Graphics Mode: ")$(supergfxctl -g 2>/dev/null || echo 'Unknown')"
            fi

            # 3. Status Service Esensial
            echo ""
            info "$(_msg "--- [Status Background Services] ---" "--- [Background Services Status] ---")"
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
            info "$(_msg "--- [Penggunaan Memori & Swap / ZRAM] ---" "--- [Memory & Swap / ZRAM Usage] ---")"
            free -h
            ;;

        *"Security Audit"*)
            echo ""
            gum style --foreground 196 --bold ">>> $(_msg "Menjalankan Audit Keamanan Sistem..." "Running System Security Audit...")"

            # 1. Firewall Status
            echo ""
            info "$(_msg "--- [Status Firewall] ---" "--- [Firewall Status] ---")"
            if command -v ufw &>/dev/null; then
                sudo ufw status verbose 2>/dev/null || ufw status 2>/dev/null || true
            elif command -v firewall-cmd &>/dev/null; then
                if systemctl is-active --quiet firewalld; then
                    echo -e "  [+] firewalld : \033[0;32mRUNNING / ACTIVE\033[0m"
                    sudo firewall-cmd --state 2>/dev/null || true
                    sudo firewall-cmd --get-active-zones 2>/dev/null || true
                else
                    echo -e "  [-] firewalld : \033[0;31mINACTIVE / NOT RUNNING\033[0m"
                fi
            else
                warn "$(_msg "Tidak ditemukan UFW atau firewalld di sistem." "Neither UFW nor firewalld found on this system.")"
            fi

            # 2. Open Listening Ports
            echo ""
            info "$(_msg "--- [Port & Socket Listening Lokal] ---" "--- [Local Listening Ports & Sockets] ---")"
            if command -v ss &>/dev/null; then
                ss -tuln | grep -E 'State|LISTEN' || true
            fi

            # 3. SSH Key File Permissions
            echo ""
            info "$(_msg "--- [Pemeriksaan Izin File SSH ~/.ssh] ---" "--- [SSH File Permissions Check ~/.ssh] ---")"
            if [ -d "$HOME/.ssh" ]; then
                SSH_PERM="$(stat -c "%a" "$HOME/.ssh" 2>/dev/null || echo 'Unknown')"
                if [ "$SSH_PERM" = "700" ]; then
                    echo -e "  [+] ~/.ssh folder permission: \033[0;32m$SSH_PERM (Aman / Secure)\033[0m"
                else
                    echo -e "  [!] ~/.ssh folder permission: \033[0;33m$SSH_PERM (Disarankan: 700)\033[0m"
                fi
                for priv in "$HOME/.ssh/id_"*; do
                    if [[ "$priv" != *".pub" ]] && [ -f "$priv" ]; then
                        P_PERM="$(stat -c "%a" "$priv" 2>/dev/null || echo 'Unknown')"
                        if [ "$P_PERM" = "600" ]; then
                            echo -e "  [+] $priv: \033[0;32m$P_PERM (Aman / Secure)\033[0m"
                        else
                            echo -e "  [!] $priv: \033[0;31m$P_PERM (Bahaya! Disarankan: 600)\033[0m"
                        fi
                    fi
                done
            else
                info "$(_msg "Direktori ~/.ssh belum ada." "Directory ~/.ssh does not exist yet.")"
            fi
            ;;

        "Clean Package Caches & Old Kernels"*)
            echo ""
            gum style --foreground 99 --bold ">>> $(_msg "Membersihkan Cache Sistem & Paket Tidak Terpakai..." "Cleaning System Cache & Unused Packages...")"
            
            if command -v dnf &>/dev/null; then
                info "$(_msg "Membersihkan metadata dan cache DNF..." "Cleaning DNF metadata and cache...")"
                sudo dnf clean all
                info "$(_msg "Menghapus dependensi yang tidak lagi dibutuhkan (dnf autoremove)..." "Removing unused dependencies (dnf autoremove)...")"
                sudo dnf autoremove -y
            elif command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
                info "$(_msg "Membersihkan cache paket APT..." "Cleaning APT package cache...")"
                sudo apt-get clean
                info "$(_msg "Menghapus dependensi yang tidak lagi dibutuhkan (apt autoremove)..." "Removing unused dependencies (apt autoremove)...")"
                sudo apt-get autoremove -y
            fi

            if command -v flatpak &>/dev/null; then
                info "$(_msg "Menghapus runtime Flatpak yang tidak terpakai (flatpak uninstall --unused)..." "Removing unused Flatpak runtimes (flatpak uninstall --unused)...")"
                flatpak uninstall --unused -y || true
            fi

            if command -v bleachbit &>/dev/null; then
                info "$(_msg "BleachBit terpasang. Anda dapat menjalankan 'bleachbit' untuk pembersihan mendalam." "BleachBit is installed. You can run 'bleachbit' for deep system cleaning.")"
            fi

            success "$(_msg "Pembersihan cache paket selesai." "Package cache cleaning completed.")"
            ;;

        "Btrfs Scrub & Filesystem Health Check"*)
            echo ""
            gum style --foreground 99 --bold ">>> $(_msg "Memeriksa Kesehatan Filesystem Btrfs..." "Checking Btrfs Filesystem Health...")"
            
            if command -v btrfs &>/dev/null; then
                info "$(_msg "Menampilkan penggunaan ruang filesystem Btrfs (/) & (/home)..." "Displaying Btrfs filesystem usage (/) & (/home)...")"
                sudo btrfs filesystem usage / 2>/dev/null || df -h /
                
                if gum confirm "$(_msg "Jalankan btrfs scrub pada root (/) sekarang?" "Run btrfs scrub on root (/) now?")"; then
                    info "$(_msg "Menjalankan btrfs scrub..." "Running btrfs scrub...")"
                    sudo btrfs scrub start -B / || true
                    success "$(_msg "Scrub selesai." "Scrub completed.")"
                fi
            else
                warn "$(_msg "Btrfs tool tidak ditemukan." "Btrfs tool not found.")"
            fi
            ;;

        *"Snapshot Sistem"*|*"System Snapshot"*)
            echo ""
            gum style --foreground 99 --bold ">>> $(_msg "Membuat Snapshot Sistem..." "Creating System Snapshot...")"
            create_system_snapshot "Manual-Maintenance-$(date +%Y%m%d%H%M%S)"
            ;;

        *"Log Setup"*|*"Setup Log"*)
            echo ""
            gum style --foreground 99 --bold ">>> $(_msg "Membuka Log Setup Terpusat..." "Opening Centralized Setup Log...")"
            if [ -f "$LOG_FILE" ]; then
                if command -v gum &>/dev/null; then
                    gum pager < "$LOG_FILE" || cat "$LOG_FILE"
                else
                    less "$LOG_FILE" || cat "$LOG_FILE"
                fi
            else
                info "$(_msg "File log belum ditemukan di: $LOG_FILE" "Log file not found at: $LOG_FILE")"
            fi
            ;;

        "Rollback / Restore Dotfiles"*)
            echo ""
            gum style --foreground 99 --bold ">>> $(_msg "Rollback / Restore Dotfiles dari Backup..." "Rollback / Restore Dotfiles from Backup...")"
            BACKUP_DIR="$HOME/.dotfiles_backup"
            
            if [ ! -d "$BACKUP_DIR" ]; then
                warn "$(_msg "Direktori backup $BACKUP_DIR tidak ditemukan." "Backup directory $BACKUP_DIR not found.")"
                continue
            fi

            info "$(_msg "Pilih opsi pemulihan dotfiles:" "Select dotfiles recovery option:")"
            RESTORE_ACTION=$(gum choose \
                --cursor="❯ " \
                --cursor.foreground="39" \
                "$(_msg "Rollback ~/.zshrc dari Riwayat Backup (Timestamp)" "Rollback ~/.zshrc from Backup History (Timestamp)")" \
                "$(_msg "Rollback ~/.config/starship.toml dari Riwayat Backup (Timestamp)" "Rollback ~/.config/starship.toml from Backup History (Timestamp)")" \
                "$(_msg "Restore Semua dari Backup Terakhir (.latest)" "Restore All from Latest Backup (.latest)")" \
                "$(_msg "⬅️   [Kembali]" "⬅️   [Back]")" || true)

            case "$RESTORE_ACTION" in
                *"~/.zshrc"*)
                    mapfile -t ZSH_FILES < <(find "$BACKUP_DIR" -maxdepth 1 -name ".zshrc.backup.*" -printf "%f\n" 2>/dev/null | sort -r)
                    if [ ${#ZSH_FILES[@]} -eq 0 ]; then
                        warn "$(_msg "Tidak ada file riwayat backup ~/.zshrc di $BACKUP_DIR" "No ~/.zshrc backup history files found in $BACKUP_DIR")"
                    else
                        info "$(_msg "Pilih snapshot backup ~/.zshrc yang ingin di-restore:" "Select ~/.zshrc backup snapshot to restore:")"
                        CHOSEN_ZSH=$(gum choose "${ZSH_FILES[@]}")
                        if [ -n "$CHOSEN_ZSH" ] && [ -f "$BACKUP_DIR/$CHOSEN_ZSH" ]; then
                            if [ -f "$HOME/.zshrc" ]; then
                                SAFETY_BACKUP="$BACKUP_DIR/.zshrc.pre_restore.$(date +%Y%m%d%H%M%S)"
                                cp "$HOME/.zshrc" "$SAFETY_BACKUP"
                                info "$(_msg "Safety snapshot dibuat: $SAFETY_BACKUP" "Safety snapshot created: $SAFETY_BACKUP")"
                            fi
                            cp "$BACKUP_DIR/$CHOSEN_ZSH" "$HOME/.zshrc"
                            success "$(_msg "Berhasil merestore ~/.zshrc dari snapshot: $CHOSEN_ZSH" "Successfully restored ~/.zshrc from snapshot: $CHOSEN_ZSH")"
                        fi
                    fi
                    ;;

                *"starship.toml"*)
                    mapfile -t STARSHIP_FILES < <(find "$BACKUP_DIR" -maxdepth 1 -name "starship.toml.backup.*" -printf "%f\n" 2>/dev/null | sort -r)
                    if [ ${#STARSHIP_FILES[@]} -eq 0 ]; then
                        warn "$(_msg "Tidak ada file riwayat backup starship.toml di $BACKUP_DIR" "No starship.toml backup history files found in $BACKUP_DIR")"
                    else
                        info "$(_msg "Pilih snapshot backup starship.toml yang ingin di-restore:" "Select starship.toml backup snapshot to restore:")"
                        CHOSEN_STARSHIP=$(gum choose "${STARSHIP_FILES[@]}")
                        if [ -n "$CHOSEN_STARSHIP" ] && [ -f "$BACKUP_DIR/$CHOSEN_STARSHIP" ]; then
                            mkdir -p "$HOME/.config"
                            if [ -f "$HOME/.config/starship.toml" ]; then
                                SAFETY_BACKUP="$BACKUP_DIR/starship.toml.pre_restore.$(date +%Y%m%d%H%M%S)"
                                cp "$HOME/.config/starship.toml" "$SAFETY_BACKUP"
                                info "$(_msg "Safety snapshot dibuat: $SAFETY_BACKUP" "Safety snapshot created: $SAFETY_BACKUP")"
                            fi
                            cp "$BACKUP_DIR/$CHOSEN_STARSHIP" "$HOME/.config/starship.toml"
                            success "$(_msg "Berhasil merestore ~/.config/starship.toml dari snapshot: $CHOSEN_STARSHIP" "Successfully restored ~/.config/starship.toml from snapshot: $CHOSEN_STARSHIP")"
                        fi
                    fi
                    ;;

                *"Restore Semua"*|*"Restore All"*|*".latest"*)
                    if [ -f "$BACKUP_DIR/.zshrc.latest" ]; then
                        cp "$BACKUP_DIR/.zshrc.latest" "$HOME/.zshrc"
                        success "$(_msg "$HOME/.zshrc berhasil di-restore dari .latest" "$HOME/.zshrc successfully restored from .latest")"
                    fi
                    if [ -f "$BACKUP_DIR/starship.toml.latest" ]; then
                        mkdir -p "$HOME/.config"
                        cp "$BACKUP_DIR/starship.toml.latest" "$HOME/.config/starship.toml"
                        success "$(_msg "$HOME/.config/starship.toml berhasil di-restore dari .latest" "$HOME/.config/starship.toml successfully restored from .latest")"
                    fi
                    ;;
                *)
                    info "$(_msg "Batal melakukan pemulihan dotfiles." "Cancelled dotfiles restore.")"
                    ;;
            esac
            ;;
    esac
done

echo ""
success "$(_msg "============================================================" "============================================================")"
success "$(_msg " Proses Maintenance & Diagnostic Selesai!" " Maintenance & Diagnostic Process Completed!")"
success "$(_msg "============================================================" "============================================================")"
