# .zshrc – managed by Stow
export PATH="$HOME/.zap/bin:$PATH"
if [ -f "$HOME/.zap/init.zsh" ]; then
  source "$HOME/.zap/init.zsh"
fi
if [ -f "$HOME/.config/powerlevel10k/p10k.zsh" ]; then
  source "$HOME/.config/powerlevel10k/p10k.zsh"
fi
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
alias ls='eza --icons'
alias cat='bat'
alias grep='rg'
