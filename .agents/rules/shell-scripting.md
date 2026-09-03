# Shell Scripting Rules & Conventions

## Code Quality and Safety
1. **Header**: Always begin with `#!/usr/bin/env bash`.
2. **Error Handling**: Use `set -e` at the top of executable scripts to fail fast upon unexpected errors.
3. **Quoting**: Quote all variables unless word splitting is explicitly intended (e.g. `"$HOME/.config"`).
4. **Idempotency**:
   - Check directory/file existence (`[ ! -d "$DIR" ]`, `[ -f "$FILE" ]`) before cloning or writing.
   - For git repositories, pull updates if directory exists (`git -C "$DIR" pull --quiet || true`).
5. **Backups**: Never overwrite existing user configs without creating a timestamped backup copy (`.backup.$(date +%Y%m%d%H%M%S)`).
6. **Package Manager Abstraction**: Always write cross-distro package checks with fallback handling.
