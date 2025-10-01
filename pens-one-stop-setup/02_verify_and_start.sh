#!/usr/bin/env bash
set -euo pipefail
info(){ printf "\033[1;34m[CHK]\033[0m %s\n" "$*"; }

info "Reload brew + nvm"
eval "$(/opt/homebrew/bin/brew shellenv)" || true
export NVM_DIR="$HOME/.nvm"; [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh" || true

info "Ensure key CLI symlinks"
ln -sf "$(brew --prefix docker)/bin/docker" /opt/homebrew/bin/docker 2>/dev/null || true
ln -sf "$(brew --prefix kubernetes-cli)/bin/kubectl" /opt/homebrew/bin/kubectl 2>/dev/null || true

info "Start Colima (Docker daemon)"
colima status || true
colima start -f --cpu 4 --memory 6 --disk 40 --vm-type=vz

info "Versions:"
echo "node:     $(command -v node  || echo MISSING) -> $(node -v 2>/dev/null || true)"
echo "npm:      $(npm -v 2>/dev/null || true)"
echo "nvm:      $(command -v nvm   || echo MISSING)"
echo "docker:   $(docker --version 2>/dev/null || echo MISSING)"
echo "kubectl:  $(kubectl version --client=true 2>/dev/null || echo MISSING)"
echo "helm:     $(helm version --short 2>/dev/null || echo MISSING)"
echo "tf:       $(terraform version 2>/dev/null | head -n1 || echo MISSING)"
echo "stskeygen: $(stskeygen -v 2>/dev/null || echo MISSING)"

echo
echo "Try: aws_devops  (opens Chrome SSO, then runs stskeygen)"
