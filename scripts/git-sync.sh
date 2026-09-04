#!/usr/bin/env bash
# ==============================================================================
# Git Automated Sync & Changelog Generator
# Updates CHANGELOG.md automatically from commit history, stages, commits & pushes
# ==============================================================================

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# Load gum helper jika tersedia
if command -v gum &>/dev/null; then
    USE_GUM=true
else
    USE_GUM=false
fi

# 1. Pastikan tidak ada secret file yang bocor
if git status --porcelain | grep -E "\.env|id_ed25519|mcp_config\.json" | grep -v "^!!" >/dev/null 2>&1; then
    echo -e "\033[0;31m[ERROR] File rahasia (.env / private key / token) terdeteksi akan ikut ter-stage!\033[0m"
    echo "Harap periksa .gitignore Anda."
    exit 1
fi

# 2. Minta pesan commit
COMMIT_MSG="$*"
if [ -z "$COMMIT_MSG" ]; then
    if [ "$USE_GUM" = true ]; then
        COMMIT_TYPE=$(gum choose "feat" "fix" "docs" "style" "refactor" "perf" "test" "chore")
        COMMIT_SCOPE=$(gum input --placeholder "scope (opsional, misal: asus, terminal, dnf)")
        COMMIT_DESC=$(gum input --placeholder "Ringkasan perubahan (misal: add antigravity installer)")
        if [ -n "$COMMIT_SCOPE" ]; then
            COMMIT_MSG="${COMMIT_TYPE}(${COMMIT_SCOPE}): ${COMMIT_DESC}"
        else
            COMMIT_MSG="${COMMIT_TYPE}: ${COMMIT_DESC}"
        fi
    else
        read -r -p "Masukkan pesan commit: " COMMIT_MSG
    fi
fi

if [ -z "$COMMIT_MSG" ]; then
    echo "Pesan commit tidak boleh kosong. Dibatalkan."
    exit 1
fi

# 3. Generate / Update CHANGELOG.md
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"
DATE_STR="$(date +'%Y-%m-%d %H:%M:%S')"

echo "Mencatat perubahan ke CHANGELOG.md..."

TMP_ENTRY="$(mktemp)"
cat << ENTRY_EOF > "$TMP_ENTRY"

### 🚀 [$DATE_STR] - $COMMIT_MSG

- **Author**: $(git config user.name || echo "$USER") <$(git config user.email || echo "$USER@local")>
- **Branch**: $(git rev-parse --abbrev-ref HEAD)
- **Files Changed**:
$(git status --porcelain | sed 's/^/  - /')
ENTRY_EOF

if [ ! -f "$CHANGELOG_FILE" ]; then
    cat << HEADER_EOF > "$CHANGELOG_FILE"
# 📜 Changelog

Dokumentasi riwayat pembaruan dan otomasi commit proyek \`personal-fresh-linux-setup\`.

---
HEADER_EOF
fi

# Sisipkan catatan terbaru di baris paling atas setelah header
sed -i "/---/r $TMP_ENTRY" "$CHANGELOG_FILE"
rm -f "$TMP_ENTRY"

# 4. Stage, Commit & Push
git add -A
git commit -m "$COMMIT_MSG"

echo "Mendorong perubahan ke remote GitHub..."
git push origin HEAD

echo -e "\033[0;32m[SUCCESS] Commit & Push berhasil disinkronkan beserta CHANGELOG.md!\033[0m"
