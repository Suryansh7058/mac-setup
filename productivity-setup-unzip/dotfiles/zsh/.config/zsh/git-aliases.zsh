# --- Git Aliases ---
alias gs='git status'
alias gst='git status -sb'

alias ga='git add'
alias gap='git add -p'
alias gaa='git add .'
alias gcm='git commit -m'
alias gca='git commit -am'
alias gcan='git commit --amend --no-edit'
alias gfix='git add . && git commit --amend --no-edit && git push -f'

alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'
gnb() { git checkout -b "$1" && git push -u origin "$1"; }
alias gm='git checkout master && git pull'

alias gl='git log --oneline --decorate --graph --all'
alias gld="git log --graph --decorate --date=relative --pretty=format:'%C(auto)%h %Cblue%ad%Creset %C(yellow)%an%Creset %Cgreen%d%Creset %s'"
alias gd='git diff'
alias gds='git diff --staged'
alias gbl='git blame -w'

alias gsta='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsts='git stash show -p'
alias gstd='git stash drop'

alias gmerge='git merge'
alias gma='git merge --abort'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

alias grh='git reset HEAD'
alias grhh='git reset --hard'
alias gclean='git clean -fd'

alias gf='git fetch --all --prune'
alias gpr='git pull --rebase'
alias gpl='git pull'
alias gps='git push'
alias gpsu='git push -u origin HEAD'
alias gpsf='git push --force-with-lease'
alias gpf='git push -f'

alias gbr='git branch -vv'
alias glast='git log -1 --stat'
alias groot='git rev-parse --show-toplevel'
alias gwho='git shortlog -sn'
