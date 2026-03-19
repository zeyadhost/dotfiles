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

# Install Oh My Zsh (unattended) if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
fi

# Set up Powerlevel10k theme
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
fi

# Install desired plugins
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
git clone --depth=1 https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM}/plugins/fzf-tab"

# Ensure .zshrc has proper configuration
ZSHRC="$HOME/.zshrc"
if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC" 2>/dev/null; then
  cat <<'EOF' >> "$ZSHRC"

# Oh My Zsh configuration (added by install.sh)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)
source $ZSH/oh-my-zsh.sh
EOF
fi

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
