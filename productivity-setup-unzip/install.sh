#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Clean installer for your dotfiles (zsh, wezterm, aerospace)
# - Uses GNU stow to symlink from ./dotfiles into $HOME
# - Zsh aliases are sourced via ~/.zshrc.d/productivity.zsh
# - Git aliases live in zsh: ~/.config/zsh/git-aliases.zsh
# - No .gitconfig/.ini alias includes are used anymore
# ------------------------------------------------------------

# --- helpers ---
say() { printf "\033[1;32m[install]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; }
backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local ts; ts=$(date +%Y%m%d-%H%M%S)
    say "backup: moving $target -> ${target}.backup.${ts}"
    mv "$target" "${target}.backup.${ts}"
  fi
}

# --- preflight ---
if ! command -v brew >/dev/null 2>&1; then
  err "Homebrew not found. Install from https://brew.sh and re-run."
  exit 1
fi

say "Ensuring GNU stow is installed"
brew install stow >/dev/null || true

# repo/dotfiles root
DOTROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/dotfiles" && pwd)"
say "DOTROOT = $DOTROOT"
cd "$DOTROOT"

# --- ensure target directories exist ---
say "Creating target directories"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/wezterm"
mkdir -p "$HOME/.config/aerospace"
mkdir -p "$HOME/.config/zsh"
mkdir -p "$HOME/.zshrc.d"

# --- backup files we manage (only if regular files; skip symlinks) ---
backup "$HOME/.config/wezterm/wezterm.lua"
backup "$HOME/.config/aerospace/aerospace.toml"
backup "$HOME/.config/zsh/git-aliases.zsh"
backup "$HOME/.zshrc.d/productivity.zsh"
backup "$HOME/.zshrc" || true

# --- stow (symlink) packages ---
# Expected tree under $DOTROOT:
#   wezterm/.config/wezterm/wezterm.lua
#   aerospace/.config/aerospace/aerospace.toml
#   zsh/.zshrc.d/productivity.zsh
#   zsh/.config/zsh/git-aliases.zsh
#   (optional) zsh/.zshrc  if you want to own full zshrc via stow
say "Stowing packages → \$HOME"
stow -v -R -t "$HOME" zsh wezterm aerospace

# --- ensure .zshrc sources the stowed snippet (append once) ---
ZDOT_LINE='[ -f "$HOME/.zshrc.d/productivity.zsh" ] && source "$HOME/.zshrc.d/productivity.zsh"'
if ! grep -Fq '.zshrc.d/productivity.zsh' "$HOME/.zshrc" 2>/dev/null; then
  say "Appending source line to ~/.zshrc"
  {
    echo ""
    echo "# Load stowed productivity snippet (added by installer)"
    echo "$ZDOT_LINE"
  } >> "$HOME/.zshrc"
fi

# --- safety net: if git-aliases.zsh didn't get linked, force-link it ---
if [ -f "$DOTROOT/zsh/.config/zsh/git-aliases.zsh" ] && [ ! -e "$HOME/.config/zsh/git-aliases.zsh" ]; then
  say "Linking git-aliases.zsh (safety net)"
  ln -s "$DOTROOT/zsh/.config/zsh/git-aliases.zsh" "$HOME/.config/zsh/git-aliases.zsh"
fi

# --- Dock & menu bar autohide for your productivity profile ---
say "Configuring Dock & menu bar auto-hide (optional)"
defaults write com.apple.dock autohide -bool true
defaults write NSGlobalDomain _HIHideMenuBar -bool true
killall Dock >/dev/null 2>&1 || true

# --- Aerospace install & restart ---
say "Installing Aerospace (cask)"
brew tap nikitabobko/tap >/dev/null || true
brew install --cask nikitabobko/tap/aerospace >/dev/null || true

say "Restarting Aerospace"
osascript -e 'quit app "AeroSpace"' >/dev/null 2>&1 || true
sleep 1
open -a "AeroSpace"

echo
say "Done. Open a new terminal or run: source ~/.zshrc"
