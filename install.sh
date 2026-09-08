#!/usr/bin/env bash
# Safe, repeatable setup for Linux. It never replaces an existing user config.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
SETTINGS_SOURCE="$REPO_DIR/vscode/settings.json"
SETTINGS_DESTINATION="$VSCODE_USER_DIR/settings.json"

ensure_git_include() {
  local include_path="$1"
  if git config --global --get-all include.path 2>/dev/null | grep -qxF "$include_path"; then
    echo "ok    Git already includes $include_path"
  else
    git config --global --add include.path "$include_path"
    echo "added Git aliases via include.path"
  fi
}

install_settings_if_missing() {
  mkdir -p "$VSCODE_USER_DIR"
  if [ -e "$SETTINGS_DESTINATION" ]; then
    echo "skip  VS Code settings already exist; review $SETTINGS_SOURCE manually"
  else
    cp "$SETTINGS_SOURCE" "$SETTINGS_DESTINATION"
    echo "created $SETTINGS_DESTINATION"
  fi
}

echo "== Git =="
if command -v git >/dev/null 2>&1; then
  ensure_git_include "$REPO_DIR/git/gitconfig"
else
  echo "skip  Git not found"
fi

echo ""
echo "== shell aliases =="
MARKER="# >>> dev-setup aliases >>>"
if ! grep -qF "$MARKER" "$HOME/.bashrc" 2>/dev/null; then
  {
    echo ""
    echo "$MARKER"
    echo "source \"$REPO_DIR/shell/aliases.sh\""
    echo "# <<< dev-setup aliases <<<"
  } >> "$HOME/.bashrc"
  echo "added source line to ~/.bashrc"
else
  echo "ok    ~/.bashrc already sources aliases.sh"
fi

echo ""
echo "== VS Code settings =="
install_settings_if_missing

echo ""
echo "== VS Code extensions =="
if command -v code >/dev/null 2>&1; then
  mapfile -t extensions < <(python3 - "$REPO_DIR/vscode/extensions.json" <<'PY'
import json, sys

lines = [line for line in open(sys.argv[1], encoding="utf-8") if not line.lstrip().startswith("//")]
for extension in json.loads("".join(lines))["recommendations"]:
    print(extension)
PY
)
  installed_extensions="$(code --list-extensions)"
  for ext in "${extensions[@]}"; do
    if grep -qxF "$ext" <<<"$installed_extensions"; then
      echo "ok    $ext already installed"
    else
      code --install-extension "$ext" --force
    fi
  done
else
  echo "skip  'code' CLI not found, install VS Code first"
fi

echo ""
echo "Done. Open a new shell (or 'source ~/.bashrc') to pick up the aliases."
