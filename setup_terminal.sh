#!/usr/bin/env bash
# ==============================================================================
# Script Setup & Konfigurasi Terminal Otomatis
# Berdasarkan konfigurasi: Zsh, Starship, Zsh Plugins, Zoxide, FZF, Bat, Eza, FD
# ==============================================================================

set -e

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

info "Memulai setup konfigurasi terminal..."

# 1. Deteksi Paket Manager & Install CLI Tools
install_dependencies() {
    info "Mendeteksi sistem dan menginstall dependensi..."
    if command -v dnf &>/dev/null; then
        info "Menggunakan DNF (Fedora/RHEL)..."
        sudo dnf install -y zsh git curl fzf bat eza fd-find zoxide
    elif command -v apt &>/dev/null; then
        info "Menggunakan APT (Ubuntu/Debian)..."
        sudo apt update
        sudo apt install -y zsh git curl fzf bat fd-find zoxide
        # eza di Debian/Ubuntu membutuhkan repo terpisah jika belum ada
        if ! command -v eza &>/dev/null; then
            warn "eza belum tersedia di apt default, menginstall eza via cargo / official repo jika dibutuhkan."
        fi
    elif command -v pacman &>/dev/null; then
        info "Menggunakan Pacman (Arch Linux)..."
        sudo pacman -Sy --noconfirm zsh git curl fzf bat eza fd zoxide
    else
        warn "Package manager tidak dikenali. Pastikan git, zsh, curl, fzf, bat, eza, fd, dan zoxide sudah terinstall manual."
    fi

    # Install Starship jika belum ada
    if ! command -v starship &>/dev/null; then
        info "Menginstall Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        success "Starship sudah terinstall."
    fi
}

# 2. Setup Folder & Clone Zsh Plugins
setup_plugins() {
    info "Menyiapkan plugin Zsh..."
    local PLUGIN_DIR="$HOME/.zsh/plugins"
    mkdir -p "$PLUGIN_DIR"
    mkdir -p "$HOME/.zsh/completions"

    # zsh-autosuggestions
    if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
        info "Cloning zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
    else
        info "Mengupdate zsh-autosuggestions..."
        git -C "$PLUGIN_DIR/zsh-autosuggestions" pull --quiet || true
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
        info "Cloning zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
    else
        info "Mengupdate zsh-syntax-highlighting..."
        git -C "$PLUGIN_DIR/zsh-syntax-highlighting" pull --quiet || true
    fi

    # zsh-completions
    if [ ! -d "$PLUGIN_DIR/zsh-completions" ]; then
        info "Cloning zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$PLUGIN_DIR/zsh-completions"
    else
        info "Mengupdate zsh-completions..."
        git -C "$PLUGIN_DIR/zsh-completions" pull --quiet || true
    fi

    success "Semua plugin Zsh berhasil disiapkan."
}

# 3. Buat File Starship Configuration (~/.config/starship.toml)
setup_starship_config() {
    info "Mengonfigurasi Starship (~/.config/starship.toml)..."
    mkdir -p "$HOME/.config"
    if [ -f "$HOME/.config/starship.toml" ]; then
        cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.backup.$(date +%Y%m%d%H%M%S)"
        info "Backup file starship.toml lama telah dibuat."
    fi

    cat <<'STARSHIP_CONF' > "$HOME/.config/starship.toml"
format = """\
[╭╴](fg:arrow)\
$username\
$os\
$git_branch\
(\
    at \
    $directory\
)\
$cmd_duration\
(\
    via \
    $python\
    $conda\
    $nodejs\
    $c\
    $rust\
    $java\
)
[╰─](fg:arrow)$character\
"""
# Disable the blank line at the start of the prompt
add_newline = true

palette = "normal"

[palettes.normal]
arrow = "#f17f29"
os = "#16f4d0"
os_admin = "#e4ff1a"
directory = "#9ffff5"
time = "#bdfffd"
node = "#a5e6ba"
git = "#f17f29"
git_status = "#DFEBED"
python = "#edf67d"
conda = "#70e000"
java = "#F86279"
rust = "#ffdac6"
clang = "#caf0f8"
duration = "#ce4257"
text_color = "#EDF2F4"
text_light = "#26272A"

[username]
style_user = 'bold os'
style_root = 'bold os_admin'
format = '[  $user](fg:$style) '
disabled = false
show_always = true

[os]
format = "on [($name)]($style) "
style = "bold blue"
disabled = true

[os.symbols]
Alpine = " "
Arch = " "
Debian = " "
EndeavourOS = " "
Fedora = " "
Linux = " "
Macos = " "
Manjaro = " "
Mint = " "
NixOS = " "
openSUSE = " "
Pop = " "
SUSE = " "
Ubuntu = " "
Windows = " "

[character]
success_symbol = "[󰍟](fg:arrow)"
error_symbol = "[󰍟](fg:red)"

[directory]
format = "[$path](bold $style)[$read_only]($read_only_style) "
truncation_length = 2
style = "fg:directory"
read_only_style = "fg:directory"
before_repo_root_style = "fg:directory"
truncation_symbol = "…/"
truncate_to_repo = true
read_only ="  "

[time]
disabled = true
format = "at [󱑈 $time]($style)"
time_format = "%H:%M"
style = "bold fg:time"

[cmd_duration]
format = "took [ $duration]($style) "
style = "bold fg:duration"
min_time = 500

[git_branch]
format = "via [$symbol$branch]($style) "
style = "bold fg:git"
symbol = " "

[git_status]
format = '[ $all_status$ahead_behind ]($style)'
style = "fg:text_color bg:git"
disabled = true

[docker_context]
disabled = true
symbol = " "

[package]
disabled = true

[fill]
symbol = " "

[nodejs]
format = "[ $symbol$version ]($style)"
style = "bg:node fg:text_light"
symbol = " "
version_format = "${raw}"
disabled = false

[python]
disabled = false
format = '[ ${symbol}${pyenv_prefix}(${version})( \($virtualenv\)) ]($style)'
symbol = " "
version_format = "${raw}"
style = "bg:python fg:text_light"

[conda]
format = "[ $symbol$environment ]($style)"
style = "bg:conda fg:text_light"
ignore_base = false
disabled = false
symbol = " "

[java]
format = "[ $symbol$version ]($style)"
style = "bg:java fg:text_light"
version_format = "${raw}"
symbol = " "
disabled = true

[c]
format = "[ $symbol($version(-$name)) ]($style)"
style = "bg:clang fg:text_light"
symbol = " "
version_format = "${raw}"
disabled = true

[rust]
format = "[ $symbol$version ]($style)"
style = "bg:rust fg:text_light"
symbol = " "
version_format = "${raw}"
disabled = true
STARSHIP_CONF
    success "Konfigurasi Starship berhasil diterapkan."
}

# 4. Buat File ~/.zshrc
setup_zshrc() {
    info "Mengonfigurasi ~/.zshrc..."
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        info "Backup file ~/.zshrc lama telah dibuat."
    fi

    # Buat direktori zoxide backup jika belum ada
    mkdir -p "$HOME/ZoxideBackup"

    cat <<'ZSHRC_CONF' > "$HOME/.zshrc"
# ==========================================
# 1. ENVIRONMENT VARIABLES & PORTABILITY
# ==========================================
export _ZO_DATA_DIR="$HOME/ZoxideBackup"
export EDITOR="nano"

# Android SDK dan Java JDK PATH (jika ada)
export JAVA_HOME="$HOME/.local/opt/jdk"
export ANDROID_HOME="$HOME/.local/opt/android-sdk"
if [ -d "$JAVA_HOME/bin" ] || [ -d "$ANDROID_HOME" ]; then
    export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
fi

# ==========================================
# 2. TOOL INITIALIZATION
# ==========================================
# Starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Zoxide (cd replacement)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# FZF + FD Integration
if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
    FD_BIN=$(command -v fd || command -v fdfind)
    export FZF_DEFAULT_COMMAND="$FD_BIN --type f --strip-cwd-prefix --hidden --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$FD_BIN --type d --strip-cwd-prefix --hidden --exclude .git"
fi

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}"'

# ==========================================
# 3. ALIASES
# ==========================================
# Aliases for eza
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --git --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias tree='eza --tree --icons'
fi

# Aliases for bat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=plain'  
    alias bcat='bat'
    alias peek='bat --line-range :20'
elif command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
    alias cat='batcat --style=plain'
    alias bcat='batcat'
    alias peek='batcat --line-range :20'
fi

# FD alias jika di Debian/Ubuntu
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd='fdfind'
fi

# ==========================================
# 4. CUSTOM POWER FUNCTIONS
# ==========================================
# Interactive eza + zoxide
cl() {
  local dir=$(ls -D --icons 2>/dev/null | fzf --height 40% --reverse --header "Jump to:" \
    --preview "eza -T -L 2 --color=always {} 2>/dev/null | head -20")

  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi
}

# Interactive jump using ONLY zoxide history
zi() {
  local dir=$(zoxide query -l | fzf --height 40% --reverse --header "Zoxide History")
  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi
}

# Search files and preview them with bat
fp() {
  fzf --preview "bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}"
}

# ==========================================
# 5. ZSH SETTINGS & PLUGINS
# ==========================================
[ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# FZF key bindings
if [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
    source /usr/share/fzf/shell/key-bindings.zsh
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# Autocompletions
if [ -d ~/.zsh/plugins/zsh-completions/src ]; then
    fpath+=(~/.zsh/plugins/zsh-completions/src)
fi

autoload -Uz compinit && compinit

# History Search binding
bindkey '^R' fzf-history-widget 2>/dev/null || true

# Local bin path
export PATH="$HOME/.local/bin:$PATH"
ZSHRC_CONF

    success "Konfigurasi ~/.zshrc berhasil dibuat."
}

# 5. Ubah default shell ke Zsh jika belum
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Mengubah default shell ke Zsh..."
        chsh -s "$(which zsh)" "$USER" || warn "Gagal menjalankan chsh secara otomatis. Silakan jalankan 'chsh -s $(which zsh)' secara manual."
    fi
}

# Eksekusi
install_dependencies
setup_plugins
setup_starship_config
setup_zshrc
set_default_shell

echo ""
success "============================================================"
success " Setup Terminal Selesai!"
success " Silakan restart terminal atau jalankan: exec zsh"
success "============================================================"
