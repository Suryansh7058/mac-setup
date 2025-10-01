#!/usr/bin/env bash
set -euo pipefail

# ---------- Config (can be overridden via env) ----------
GIT_NAME="${GIT_NAME:-Suryansh Singh}"
GIT_EMAIL="${GIT_EMAIL:-suryansh.singh1@pens.com}"
SSH_KEY_COMMENT="${SSH_KEY_COMMENT:-$GIT_EMAIL}"
NODE_LTS_MAJOR="${NODE_LTS_MAJOR:-22}"
NODE_ALT_MAJOR="${NODE_ALT_MAJOR:-20}"
# --------------------------------------------------------

log() { printf "\n\033[1;32m[%s]\033[0m %s\n" "$(date '+%H:%M:%S')" "$*"; }
fail(){ printf "\n\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; exit 1; }
trap 'fail "Script aborted (line $LINENO)."' ERR

log "Ensure Homebrew is installed (if not, install it)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

log "Ensure shell profiles + brew PATH"
touch "$HOME/.zprofile" "$HOME/.zshrc"
grep -q 'brew shellenv' "$HOME/.zprofile" || cat >> "$HOME/.zprofile" <<'ZP'
# Homebrew on PATH (login shells)
eval "$(/opt/homebrew/bin/brew shellenv)"
ZP
grep -q 'brew shellenv' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'ZR'
# Homebrew on PATH (interactive shells)
eval "$(/opt/homebrew/bin/brew shellenv)"
ZR
eval "$(/opt/homebrew/bin/brew shellenv)" || true

log "brew update"
brew update || true

log "Install core formulae"
FORMULAE=(
  git yarn awscli jq wget fzf nvm
  zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
  docker colima dive lazydocker
  kubernetes-cli kubectx k9s stern helm
  terraform tflint tfsec terraform-docs
  yq
)
brew install "${FORMULAE[@]}" || true

log "Install casks (WezTerm + JetBrainsMono Nerd Font)"
brew install --cask wezterm font-jetbrains-mono-nerd-font || true

log "Link kubectl/docker into /opt/homebrew/bin if needed"
KUBECTL_SRC="$(brew --prefix kubernetes-cli)/bin/kubectl"; [ -x "$KUBECTL_SRC" ] && ln -sf "$KUBECTL_SRC" /opt/homebrew/bin/kubectl
DOCKER_SRC="$(brew --prefix docker)/bin/docker";         [ -x "$DOCKER_SRC" ]  && ln -sf "$DOCKER_SRC"  /opt/homebrew/bin/docker

log "Install Oh-My-Zsh (non-interactive) + Powerlevel10k"
export RUNZSH=no CHSH=no
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
[ -d "$HOME/powerlevel10k" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"

log "Fix compaudit warnings (permissions)"
chmod go-w /opt/homebrew/share 2>/dev/null || true
chmod -R go-w /opt/homebrew/share/zsh 2>/dev/null || true
rm -f "$HOME"/.zcompdump* 2>/dev/null || true

log "WezTerm config"
cat > "$HOME/.wezterm.lua" <<"WZRC"
local wezterm = require 'wezterm'
return {
  font = wezterm.font_with_fallback({
    { family = os.getenv("WEZTERM_FONT") or "JetBrainsMono Nerd Font", weight="Regular" },
    "Apple Color Emoji",
  }),
  font_size = 13.0,
  harfbuzz_features = { "calt=1", "liga=1", "clig=1" },
  color_scheme = "Catppuccin Mocha",
  window_decorations = "RESIZE",
  enable_tab_bar = true, use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  window_padding = { left=6, right=6, top=6, bottom=6 },
  default_prog = { "/bin/zsh", "-l" },
  audible_bell = "Disabled", check_for_updates = false,
}
WZRC

log "Git config"
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global credential.helper osxkeychain

log "SSH for Bitbucket"
mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
KEY="$HOME/.ssh/id_ed25519"
[ -f "$KEY" ] || ssh-keygen -t ed25519 -C "$SSH_KEY_COMMENT" -f "$KEY" -N ""
ssh-add --apple-use-keychain "$KEY" || true
if ! grep -q "Host bitbucket.org" "$HOME/.ssh/config" 2>/dev/null; then
  cat >> "$HOME/.ssh/config" <<"SSHCONF"
Host bitbucket.org
  HostName bitbucket.org
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
  UseKeychain yes
SSHCONF
  chmod 600 "$HOME/.ssh/config"
fi

log "Append zsh aliases/functions (after OMZ installed) if missing"
if ! grep -q '# --- START: TEMP DEV SETUP ---' "$HOME/.zshrc" 2>/dev/null; then
cat >> "$HOME/.zshrc" <<"ZRC"
# --- START: TEMP DEV SETUP ---
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export WEZTERM_FONT="JetBrainsMono Nerd Font"

ZSH_THEME="powerlevel10k/powerlevel10k"
source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"

plugins=(git kubectl helm terraform docker)

[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

# --- NVM (keep above any `set -u`) ---
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

export NODE_OPTIONS="--max-old-space-size=4096"
alias ws='cd ~/work'

# Docker / Colima
alias dstart='colima start -f --cpu 4 --memory 6 --disk 40 --vm-type=vz'
alias dstop='colima stop'
alias dstatus='colima status'
alias d='docker'
alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dimages='docker images'
alias dlogs='docker logs -f'
alias dsh='docker exec -it'
alias drm='docker rm -f'
alias drmi='docker rmi'
dclean() { docker system prune -f && docker volume prune -f && docker builder prune -f; }
alias ld='lazydocker'

# Kubernetes
alias k='kubectl'
alias kgp='kubectl get pods -o wide'
alias kgs='kubectl get svc -o wide'
alias kga='kubectl get all'
alias kgn='kubectl get nodes -o wide'
alias kdesc='kubectl describe'
alias kctx='kubectx'
kns() { if command -v kubens >/dev/null 2>&1; then kubens "$@"; else kubectl config set-context --current --namespace "$1"; fi; }
kxns() { kubectx "$1" && kns "$2"; }
klogs() { kubectl logs -f "$@"; }
kexec() { kubectl exec -it "$1" -- ${@:2}; }
kpf() { kubectl port-forward "$@"; }
klbl() { stern -l "$@"; }
alias kaf='kubectl apply -f'
alias ktop='kubectl top pods --all-namespaces'
alias k9='k9s'
[ -n "$commands[kubectl]" ] && source <(kubectl completion zsh)

# Helm
alias h='helm'; alias hi='helm install'; alias hu='helm upgrade --install'
alias hls='helm ls -A'; alias hdel='helm uninstall'

# Terraform
alias tf='terraform'; alias tfi='terraform init -upgrade'
alias tfp='terraform plan -out=tf.plan'; alias tfa='terraform apply -auto-approve'
alias tfd='terraform destroy -auto-approve'; alias tfs='terraform show -no-color'
alias tff='terraform fmt -recursive'; alias tfl='tflint'; alias tfs2='tfsec .'
alias tfdocs='terraform-docs markdown table .'
tfw() { terraform workspace select "$1" 2>/dev/null || terraform workspace new "$1"; }

# AWS SSO helpers (Chrome + stskeygen)
aws_abc()        { open -a "Google Chrome" "https://nationalpenabc.aws.cimpress.io/role/AWS_NPDevelopers-ABC"; sleep 2; stskeygen --account nationalpenabc --duration 43200 --role "AWS_NPDevelopers-ABC"; }
aws_devops()     { open -a "Google Chrome" "https://np-devops.aws.cimpress.io/role/AWS_Developers-DevOps";    sleep 2; stskeygen --account np-devops      --duration 43200 --role "AWS_Developers-DevOps"; }
aws_infra()      { open -a "Google Chrome" "https://npadmins-infrastructure.aws.cimpress.io/role/NP-AWS-ABCDevelopers-Infra"; sleep 2; stskeygen --account npadmins-infrastructure --duration 3600  --role "NP-AWS-ABCDevelopers-Infra"; }
aws_dp_ro()      { open -a "Google Chrome" "https://npdataplatform.aws.cimpress.io/role/AWS_ReadOnly-DataPlatform"; sleep 2; stskeygen --account npdataplatform --duration 43200 --role "AWS_ReadOnly-DataPlatform"; }
aws_dp_admin()   { open -a "Google Chrome" "https://npdataplatform.aws.cimpress.io/role/AWS_Admins-DataPlatform";   sleep 2; stskeygen --account npdataplatform --duration 43200 --role "AWS_Admins-DataPlatform"; }
aws_dp_dev()     { open -a "Google Chrome" "https://npdataplatform.aws.cimpress.io/role/AWS_Developers-DataPlatform"; sleep 2; stskeygen --account npdataplatform --duration 43200 --role "AWS_Developers-DataPlatform"; }
aws_ds()         { open -a "Google Chrome" "https://np-datascience.aws.cimpress.io/role/AWS_Developers-DataScience"; sleep 2; stskeygen --account np-datascience --duration 43200 --role "AWS_Developers-DataScience"; }
aws_psys_dev()   { open -a "Google Chrome" "https://np-infrastructure-phone-system.aws.cimpress.io/role/AWS_Developers-phonesystem"; sleep 2; stskeygen --account np-infrastructure-phone-system --duration 43200 --role "AWS_Developers-phonesystem"; }
aws_psys_admin() { open -a "Google Chrome" "https://np-infrastructure-phone-system.aws.cimpress.io/role/AWS_NPAdmins-PhoneSystem";   sleep 2; stskeygen --account np-infrastructure-phone-system --duration 43200 --role "AWS_NPAdmins-PhoneSystem"; }
aws_gold_admin() { open -a "Google Chrome" "https://npgoldstar.aws.cimpress.io/role/aws_admins-goldstar"; sleep 2; stskeygen --account npgoldstar --duration 43200 --role "aws_admins-goldstar"; }
aws_gold_sre()   { open -a "Google Chrome" "https://npgoldstar.aws.cimpress.io/role/AWS_NationalPen_SRE";  sleep 2; stskeygen --account npgoldstar --duration 43200 --role "AWS_NationalPen_SRE"; }
aws_gold_dev()   { open -a "Google Chrome" "https://npgoldstar.aws.cimpress.io/role/AWS_Developers_Goldstar"; sleep 2; stskeygen --account npgoldstar --duration 43200 --role "AWS_Developers_Goldstar"; }

# --- END: TEMP DEV SETUP ---
ZRC
fi

log "Install stskeygen from Cimpress (as per instructions)"
brew tap cimpress-mcp/stskeygen-installers https://github.com/Cimpress-MCP/stskeygen-installers.git || true
brew install stskeygen || true
stskeygen -v || true

log "Install Node via NVM (default LTS ${NODE_LTS_MAJOR}, also ${NODE_ALT_MAJOR})"
export NVM_DIR="$HOME/.nvm"; mkdir -p "$NVM_DIR"
. /opt/homebrew/opt/nvm/nvm.sh
nvm install "${NODE_LTS_MAJOR}" >/dev/null
nvm install "${NODE_ALT_MAJOR}" >/dev/null
nvm alias default "${NODE_LTS_MAJOR}" >/dev/null
nvm use default >/dev/null

log "Bootstrap complete ✅
- Add this SSH public key to Bitbucket:
$(cat "$KEY.pub")
- Start Docker daemon: dstart
- Open WezTerm:        wezterm
- Reload zsh:          exec zsh -l
"
