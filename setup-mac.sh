#!/usr/bin/env bash
# Install git-tools globally on macOS
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Install git if missing (Xcode CLI or Homebrew)
if ! command -v git &>/dev/null; then
  echo "Git not found. Install Xcode Command Line Tools with: xcode-select --install"
  echo "Or install via Homebrew: brew install git"
  exit 1
fi

# Default new repos to branch "main" (suppresses master/main hint)
git config --global init.defaultBranch main

# Create install dir if needed
sudo mkdir -p "$INSTALL_DIR"

echo "Installing git-tools to $INSTALL_DIR..."
for f in "$SCRIPT_DIR/scripts"/git-*; do
  [ -f "$f" ] || continue
  [[ "$f" == *.ps1 ]] && continue
  name="$(basename "$f")"
  sudo install -m 0755 "$f" "$INSTALL_DIR/$name"
  echo "  $name"
done
echo "Done. Run git-pull, git-push, git-commit, etc. from any terminal."
