#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/linux.lua"
DEST="$HOME/.wezterm.lua"

if [ -L "$DEST" ]; then
  echo "Updating symlink: $DEST -> $SRC"
  ln -sfn "$SRC" "$DEST"
  exit 0
fi

if [ -e "$DEST" ]; then
  echo "Skipping: $DEST already exists and is not a symlink"
  echo "Rename it first, e.g.: mv $DEST ${DEST}.bak"
  exit 0
fi

echo "Creating symlink: $DEST -> $SRC"
ln -s "$SRC" "$DEST"
