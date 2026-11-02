#!/usr/bin/env bash
# Installs Control TV via linux as the `control-tv` command.
# Usage: ./install.sh            -> ~/.local/bin/control-tv
#        PREFIX=/usr/local/bin sudo -E ./install.sh
set -e
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/control-tv.sh"
DEST="${PREFIX:-$HOME/.local/bin}"

[[ -f $SRC ]] || { echo "control-tv.sh not found next to install.sh"; exit 1; }
mkdir -p "$DEST"
install -m 755 "$SRC" "$DEST/control-tv"
echo "✔ Installed: $DEST/control-tv"

if ! command -v adb >/dev/null; then
  echo "⚠ adb is not installed. Install it with:"
  echo "    sudo apt install adb"
fi
case ":$PATH:" in
  *":$DEST:"*) echo "▶ Run:  control-tv" ;;
  *) echo "⚠ $DEST is not in your PATH. Add this line to ~/.bashrc:"
     echo "    export PATH=\"$DEST:\$PATH\""
     echo "▶ Or run directly:  $DEST/control-tv" ;;
esac
