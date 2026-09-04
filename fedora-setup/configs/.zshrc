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

# Fedora specific
alias dnfup='sudo dnf upgrade --refresh'
alias dco='docker compose'
alias ff='fastfetch'

# ASUS ROG / TUF & GPU Quick Controls
if command -v asusctl >/dev/null 2>&1; then
    alias asus-bat='asusctl battery info'
    alias asus-prof='asusctl profile get'
    alias asus-quiet='asusctl profile set Quiet'
    alias asus-bal='asusctl profile set Balanced'
    alias asus-perf='asusctl profile set Performance'
fi

if command -v supergfxctl >/dev/null 2>&1; then
    alias gpu-status='supergfxctl -g'
    alias gpu-hybrid='supergfxctl -m Hybrid'
    alias gpu-igpu='supergfxctl -m Integrated'
    alias gpu-dgpu='supergfxctl -m AsusMuxDgpu'
fi

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
