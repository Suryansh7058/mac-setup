#!/usr/bin/env bash
set -euo pipefail

echo "[cli] Ensure brew on PATH"
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "[cli] Install tools (skips if present)"
brew install fzf fd bat git-delta eza thefuck zoxide tlrc ripgrep >/dev/null || true

if [ ! -d "$HOME/fzf-git.sh" ]; then
  git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git "$HOME/fzf-git.sh"
fi

echo "[cli] Done. Source your shell or start a new tab."
