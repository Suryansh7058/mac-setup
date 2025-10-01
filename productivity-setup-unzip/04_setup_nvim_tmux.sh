#!/usr/bin/env bash
set -euo pipefail

say() { printf "\033[1;32m[nvim+tmux]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; }

# Where this script lives → repo root → dotfiles
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTROOT="$REPO_ROOT/dotfiles"

# 1) CLI deps
say "Installing CLI dependencies via Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  err "Homebrew not found. Install https://brew.sh first."
  exit 1
fi

# Note: Homebrew 'tldr' formula is deprecated; prefer 'tealdeer' which provides 'tldr'
brew install neovim tmux ripgrep fd bat git-delta eza tealdeer thefuck stow pipx >/dev/null || true

# 2) Python support for Neovim (do NOT break the Homebrew python env)
say "Ensuring pynvim via pipx"
pipx ensurepath >/dev/null 2>&1 || true
pipx install --include-deps pynvim >/dev/null 2>&1 || true

# 3) Ensure target dirs exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.tmux/plugins" # TPM goes here if you use it

# 4) Prefer GNU stow to link your local files
say "Linking nvim & tmux configs from dotfiles"
if [ -d "$DOTROOT/nvim" ] || [ -d "$DOTROOT/tmux" ]; then
  # Expected:
  #   dotfiles/nvim/.config/nvim/***
  #   dotfiles/tmux/.tmux.conf
  stow -v -R -t "$HOME" nvim tmux || warn "stow failed; will attempt manual symlinks"
else
  warn "dotfiles/nvim or dotfiles/tmux not found next to this script"
fi

# 5) Manual symlink safety net (only if stow didn’t place them)
if [ -d "$DOTROOT/nvim/.config/nvim" ] && [ ! -e "$HOME/.config/nvim/init.lua" ] && [ ! -L "$HOME/.config/nvim" ]; then
  say "Manual link: ~/.config/nvim -> dotfiles/nvim/.config/nvim"
  rm -rf "$HOME/.config/nvim"
  ln -s "$DOTROOT/nvim/.config/nvim" "$HOME/.config/nvim"
fi

if [ -f "$DOTROOT/tmux/.tmux.conf" ] && [ ! -e "$HOME/.tmux.conf" ]; then
  say "Manual link: ~/.tmux.conf -> dotfiles/tmux/.tmux.conf"
  ln -s "$DOTROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

# 6) (Optional) Install TPM if you use it
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  say "Installing TPM (tmux plugin manager)"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR" >/dev/null 2>&1 || warn "TPM clone failed"
fi

echo
say "Done."
echo "Neovim: first launch will install plugins (lazy.nvim). Use :Lazy to check."
echo "tmux: start tmux, then press Prefix + I to install TPM plugins."
