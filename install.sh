#!/usr/bin/env bash
# Idempotent: safe to run more than once. Existing files are backed up
# once, never clobbered silently.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_USER_DIR="${HOME}/.config/Code/User"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    echo "ok    $dst (already linked)"
    return
  fi
  if [ -e "$dst" ]; then
    mv "$dst" "${dst}.bak.$(date +%s)"
    echo "backup $dst -> ${dst}.bak.*"
  fi
  ln -s "$src" "$dst"
  echo "linked $dst -> $src"
}

echo "== dotfiles =="
link "$REPO_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
link "$REPO_DIR/git/gitconfig" "$HOME/.gitconfig"

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
echo "== VS Code extensions =="
if command -v code >/dev/null 2>&1; then
  while read -r ext; do
    if code --list-extensions | grep -qxF "$ext"; then
      echo "ok    $ext already installed"
    else
      code --install-extension "$ext" --force
    fi
  done < <(python3 - "$REPO_DIR/vscode/extensions.json" <<'PY'
import json, re, sys
raw = open(sys.argv[1]).read()
raw = re.sub(r"//.*", "", raw)
for ext in json.loads(raw)["recommendations"]:
    print(ext)
PY
)
else
  echo "skip  'code' CLI not found, install VS Code first"
fi

echo ""
echo "Done. Open a new shell (or 'source ~/.bashrc') to pick up the aliases."
