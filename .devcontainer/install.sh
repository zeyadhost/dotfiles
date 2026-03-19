#!/usr/bin/env bash
set -euo pipefail

# Determine repository root (assumes script is inside .devcontainer)
REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_ROOT"

# Ensure GNU Stow is available (installed via apt in Dockerfile)
# Stow should already be installed via Dockerfile; if missing, warn the user.
if ! command -v stow >/dev/null 2>&1; then
  echo "Warning: stow not found. Please ensure it's installed."
fi

# Use Stow to symlink dotfiles (expects a 'dotfiles' directory with subfolders)
if [ -d "dotfiles" ]; then
  echo "Stowing dotfiles..."
  stow --adopt -t $HOME -d dotfiles zsh tmux nvim
else
  echo "No 'dotfiles' directory found; skipping stow."
fi

# Install Zap (Zsh plugin manager) if not present
ZAP_DIR="$HOME/.zap"
if [ ! -d "$ZAP_DIR" ]; then
  echo "Installing Zap..."
  git clone --depth=1 https://github.com/zap-zsh/zap.git "$ZAP_DIR"
fi
# Source Zap to make the 'zap' function available
ZSHRC="$HOME/.zshrc"

# Ensure Zap initialization is in .zshrc for future sessions
if [ ! -f "$ZSHRC" ]; then
    touch "$ZSHRC"
fi

if ! grep -q 'source.*\.zap/zap.zsh' "$ZSHRC" 2>/dev/null; then
    echo -e '\n# Zap initialization\nsource ~/.zap/zap.zsh' >> "$ZSHRC"
fi

# Source Zap for current session (this defines the 'zap' function)
# shellcheck source=/dev/null
source "$ZAP_DIR/zap.zsh"

# Install Powerlevel10k via Zap
zap install romkatv/powerlevel10k

# Install Zsh plugins via Zap
zap install zsh-users/zsh-autosuggestions
zap install zsh-users/zsh-syntax-highlighting
zap install Aloxaf/fzf-tab

# Install Tmux Plugin Manager (TPM)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
# Install any tmux plugins defined in .tmux.conf via TPM
"$TPM_DIR/scripts/install_plugins.sh"



# Done – advise user to restart shell
if [ -t 1 ]; then
  echo "Setup complete. Restart the terminal to load Zsh with Powerlevel10k."
else
  exec zsh
fi
