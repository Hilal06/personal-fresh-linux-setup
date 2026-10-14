#!/usr/bin/env bash
set -eo pipefail

# Wrapper to maintain backwards compatibility with setup_terminal.sh
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
exec "$SCRIPT_DIR/setup_terminal.sh" "$@"
