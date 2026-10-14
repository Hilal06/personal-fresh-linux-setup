#!/usr/bin/env bash
# ==============================================================================
# Helper Script to Generate Terminal Demo GIF using Charm VHS
# ==============================================================================

set -eo pipefail

REPO_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
cd "$REPO_ROOT"

if ! command -v vhs &>/dev/null; then
    echo "[INFO] Charm VHS belum terpasang."
    echo "Untuk memasang VHS:"
    echo "  Fedora: sudo dnf copr enable agriffis/vhs && sudo dnf install -y vhs"
    echo "  Ubuntu/Debian: sudo apt install -y vhs (atau unduh dari https://github.com/charmbracelet/vhs/releases)"
    echo "  Atau via Go: go install github.com/charmbracelet/vhs@latest"
    exit 1
fi

echo "[INFO] Merekam demo animasi terminal dari assets/vhs/demo.tape..."
mkdir -p assets
vhs assets/vhs/demo.tape

echo "[SUCCESS] Demo GIF berhasil dibuat di assets/demo.gif!"
