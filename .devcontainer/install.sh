#!/usr/bin/env bash
set -euo pipefail

# Determine repository root (assumes script is inside .devcontainer)
REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_ROOT"

# Ensure GNU Stow is available (installed via apt in Dockerfile)
if ! command -v stow >/dev/null 2>&1; then
  echo "Warning: stow not found. Please ensure it's installed."
fi

# Use Stow to symlink dotfiles (excluding zsh)
if [ -d "dotfiles" ]; then
  echo "Stowing dotfiles..."
  stow --adopt -t "$HOME" -d dotfiles tmux nvim
else
  echo "No 'dotfiles' directory found; skipping stow."
fi

# Install additional useful packages (e.g., neofetch)
if command -v apt-get >/dev/null 2>&1; then
  echo "Installing additional packages..."
  apt-get update -y && apt-get install -y neofetch
else
  echo "apt-get not available; skipping package installation."
fi

# Done – advise user to restart terminal
if [ -t 1 ]; then
  echo "Setup complete."
else
  echo "Setup complete."
fi
