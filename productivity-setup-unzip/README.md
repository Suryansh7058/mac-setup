# productivity-setup (stow-powered)
This package manages your user configs via GNU **stow** and installs dev helpers.

## Contents
- dotfiles/
  - git/.gitconfig.d/aliases.ini        → g* aliases (rebase, gfix, gnb, gm, etc.)
  - zsh/.zshrc.d/productivity.zsh       → fzf/fd/bat/eza/zoxide/thefuck bindings
  - wezterm/.config/wezterm/wezterm.lua → default wezterm config (safe to override)
  - aerospace/.config/aerospace/aerospace.toml → tiling rules (WezTerm→T, Chrome→S)
- install.sh              → installs stow, stows dotfiles, wires git include & zsh
- 04_setup_nvim_tmux.sh   → installs Neovim+tmux configs (Josean-style)
- 05_cli_tools.sh         → installs zoxide/tlrc/fzf-git etc.

## Usage
unzip productivity-setup.zip -d ~/Desktop/
cd ~/Desktop/productivity-setup
./install.sh
./04_setup_nvim_tmux.sh
./05_cli_tools.sh
