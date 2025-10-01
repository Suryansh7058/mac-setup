# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Git aliases
[ -f "$HOME/.config/zsh/git-aliases.zsh" ] && source "$HOME/.config/zsh/git-aliases.zsh"

# Any other productivity configs…
export PATH="$HOME/bin:$PATH"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# --- START: TEMP M1 SETUP ---
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

ZSH_THEME="powerlevel10k/powerlevel10k"
source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"

plugins=(git kubectl helm terraform docker)

[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Homebrew zsh completions (matches brew caveat)
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

export NODE_OPTIONS="--max-old-space-size=4096"
alias ws='cd ~/work'

# Docker / Colima
alias dstart='colima start --cpu 4 --memory 6 --disk 40 --vm-type=vz'
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
alias kns='kubens'
kxns() { kubectx "$1" && kubens "$2"; }
klogs() { kubectl logs -f "$@"; }
kexec() { kubectl exec -it "$1" -- ${@:2}; }
kpf() { kubectl port-forward "$@"; }
klbl() { stern -l "$@"; }
alias kaf='kubectl apply -f'
alias ktop='kubectl top pods --all-namespaces'
alias k9='k9s'

# Helm
alias h='helm'
alias hi='helm install'
alias hu='helm upgrade --install'
alias hls='helm ls -A'
alias hdel='helm uninstall'

# Terraform
alias tf='terraform'
alias tfi='terraform init -upgrade'
alias tfp='terraform plan -out=tf.plan'
alias tfa='terraform apply -auto-approve'
alias tfd='terraform destroy -auto-approve'
alias tfs='terraform show -no-color'
alias tff='terraform fmt -recursive'
alias tfl='tflint'
alias tfs2='tfsec .'
alias tfdocs='terraform-docs markdown table .'
tfw() { terraform workspace select "$1" 2>/dev/null || terraform workspace new "$1"; }

# # --- Git Aliases ---
# alias gs='git status'
# alias gst='git status -sb'

# alias ga='git add'
# alias gap='git add -p'
# alias gaa='git add .'
# alias gcm='git commit -m'
# alias gca='git commit -am'
# alias gcan='git commit --amend --no-edit'
# alias gfix='git add . && git commit --amend --no-edit && git push -f'

# alias gco='git checkout'
# alias gcb='git checkout -b'
# alias gsw='git switch'
# alias gswc='git switch -c'
# gnb() { git checkout -b "$1" && git push -u origin "$1"; }
# alias gm='git checkout master && git pull'

# alias gl='git log --oneline --decorate --graph --all'
# alias gld="git log --graph --decorate --date=relative --pretty=format:'%C(auto)%h %Cblue%ad%Creset %C(yellow)%an%Creset %Cgreen%d%Creset %s'"
# alias gd='git diff'
# alias gds='git diff --staged'
# alias gbl='git blame -w'

# alias gsta='git stash'
# alias gstp='git stash pop'
# alias gstl='git stash list'
# alias gsts='git stash show -p'
# alias gstd='git stash drop'

# alias gmerge='git merge'
# alias gma='git merge --abort'
# alias grb='git rebase'
# alias grbi='git rebase -i'
# alias grba='git rebase --abort'
# alias grbc='git rebase --continue'
# alias grbs='git rebase --skip'
# alias gcp='git cherry-pick'
# alias gcpa='git cherry-pick --abort'
# alias gcpc='git cherry-pick --continue'

# alias grh='git reset HEAD'
# alias grhh='git reset --hard'
# alias gclean='git clean -fd'

# alias gf='git fetch --all --prune'
# alias gpr='git pull --rebase'
# alias gpl='git pull'
# alias gps='git push'
# alias gpsu='git push -u origin HEAD'
# alias gpsf='git push --force-with-lease'
# alias gpf='git push -f'

# alias gbr='git branch -vv'
# alias glast='git log -1 --stat'
# alias groot='git rev-parse --show-toplevel'
# alias gwho='git shortlog -sn'


# AWS SSO helpers
aws_abc() { open -a "Google Chrome" "https://nationalpenabc.aws.cimpress.io/role/AWS_NPDevelopers-ABC"; sleep 2; stskeygen --account nationalpenabc --duration 43200 --role "AWS_NPDevelopers-ABC"; }
aws_devops() { open -a "Google Chrome" "https://np-devops.aws.cimpress.io/role/AWS_Developers-DevOps"; sleep 2; stskeygen --account np-devops --duration 43200 --role "AWS_Developers-DevOps"; }
aws_infra() { open -a "Google Chrome" "https://npadmins-infrastructure.aws.cimpress.io/role/NP-AWS-ABCDevelopers-Infra"; sleep 2; stskeygen --account npadmins-infrastructure --duration 3600 --role "NP-AWS-ABCDevelopers-Infra"; }
aws_dp_ro() { open -a "Google Chrome" "https://npdataplatform.aws.cimpress.io/role/AWS_ReadOnly-DataPlatform"; sleep 2; stskeygen --account npdataplatform --duration 43200 --role "AWS_ReadOnly-DataPlatform"; }
aws_dp_admin() { open -a "Google Chrome" "https://npdataplatform.aws.cimpress.io/role/AWS_Admins-DataPlatform"; sleep 2; stskeygen --account npdataplatform --duration 43200 --role "AWS_Admins-DataPlatform"; }
aws_dp_dev() { open -a "Google Chrome" "https://npdataplatform.aws.cimpress.io/role/AWS_Developers-DataPlatform"; sleep 2; stskeygen --account npdataplatform --duration 43200 --role "AWS_Developers-DataPlatform"; }
aws_ds() { open -a "Google Chrome" "https://np-datascience.aws.cimpress.io/role/AWS_Developers-DataScience"; sleep 2; stskeygen --account np-datascience --duration 43200 --role "AWS_Developers-DataScience"; }
aws_psys_dev() { open -a "Google Chrome" "https://np-infrastructure-phone-system.aws.cimpress.io/role/AWS_Developers-phonesystem"; sleep 2; stskeygen --account np-infrastructure-phone-system --duration 43200 --role "AWS_Developers-phonesystem"; }
aws_psys_admin() { open -a "Google Chrome" "https://np-infrastructure-phone-system.aws.cimpress.io/role/AWS_NPAdmins-PhoneSystem"; sleep 2; stskeygen --account np-infrastructure-phone-system --duration 43200 --role "AWS_NPAdmins-PhoneSystem"; }
aws_gold_admin() { open -a "Google Chrome" "https://npgoldstar.aws.cimpress.io/role/aws_admins-goldstar"; sleep 2; stskeygen --account npgoldstar --duration 43200 --role "aws_admins-goldstar"; }
aws_gold_sre() { open -a "Google Chrome" "https://npgoldstar.aws.cimpress.io/role/AWS_NationalPen_SRE"; sleep 2; stskeygen --account npgoldstar --duration 43200 --role "AWS_NationalPen_SRE"; }
aws_gold_dev() { open -a "Google Chrome" "https://npgoldstar.aws.cimpress.io/role/AWS_Developers_Goldstar"; sleep 2; stskeygen --account npgoldstar --duration 43200 --role "AWS_Developers_Goldstar"; }

export WEZTERM_FONT="JetBrainsMono Nerd Font"
# --- END: TEMP M1 SETUP ---

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# --- NVM (keep above any `set -u`) ---
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
# Homebrew on PATH for interactive zsh
eval "$(/opt/homebrew/bin/brew shellenv)"

# Load stowed productivity snippet
[ -f "$HOME/.zshrc.d/productivity.zsh" ] && source "$HOME/.zshrc.d/productivity.zsh"

# Created by `pipx` on 2025-10-01 05:17:02
export PATH="$PATH:/Users/suryansh/.local/bin"
