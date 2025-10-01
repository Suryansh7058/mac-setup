#!/usr/bin/env bash
set -euo pipefail

# --------- Settings (override via env) ----------
CONFIG_FILE_DEFAULT="$HOME/Desktop/pens_repos.yml"
CONFIG_FILE="${CONFIG_FILE:-}"
DEST_DIR="${DEST_DIR:-$HOME/Desktop/pens}"
DEFAULT_WORKSPACE="${DEFAULT_WORKSPACE:-national-pen}"
BITBUCKET_HOST="${BITBUCKET_HOST:-bitbucket.org}"
# ------------------------------------------------

log(){ printf "\033[1;32m[clone]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err(){ printf "\033[1;31m[err]\033[0m %s\n" "$*"; }

need() { command -v "$1" >/dev/null 2>&1 || { err "missing '$1' – install it first"; exit 1; }; }

need git
need yq

# Resolve config file: prefer ./pens_repos.yml if present; else $CONFIG_FILE_DEFAULT; else create template in PWD
if [ -z "${CONFIG_FILE}" ]; then
  if [ -f "./pens_repos.yml" ]; then
    CONFIG_FILE="$(pwd)/pens_repos.yml"
  elif [ -f "${CONFIG_FILE_DEFAULT}" ]; then
    CONFIG_FILE="${CONFIG_FILE_DEFAULT}"
  else
    CONFIG_FILE="$(pwd)/pens_repos.yml"
    log "Creating template config at ${CONFIG_FILE}"
    cat > "${CONFIG_FILE}" <<'YAML'
projects:
  ABC: []
  SRE: []
  DATA PLATFORM: []
  DATA SCIENCE: []
  PHONESYSTEMS: []
  INFRASTRUCTURE: []
  GOLDSTAR: []
YAML
    log "Edit ${CONFIG_FILE} and re-run this script."
    exit 0
  fi
fi

log "Using config: ${CONFIG_FILE}"
mkdir -p "${DEST_DIR}"

slugify() {
  echo "$1" | awk '{print tolower($0)}' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9._-]//g'
}

to_git_url_and_dir() {
  local entry="$1"
  local url dir
  if [[ "$entry" =~ ^git@|^ssh://|^https?:// ]]; then
    url="$entry"
    dir="$(basename "${entry%.git}")"
  elif [[ "$entry" == */* ]]; then
    url="git@${BITBUCKET_HOST}:${entry}.git"
    dir="$(basename "$entry")"
  else
    url="git@${BITBUCKET_HOST}:${DEFAULT_WORKSPACE}/${entry}.git"
    dir="$entry"
  fi
  printf "%s|%s\n" "$url" "$dir"
}

# List of project keys
projects=$(yq -r '.projects | keys[]' "$CONFIG_FILE" 2>/dev/null || true)
if [ -z "${projects:-}" ]; then
  warn "No projects found in ${CONFIG_FILE} (.projects is empty)."
  exit 0
fi

while IFS= read -r project; do
  [ -z "$project" ] && continue
  slug="$(slugify "$project")"
  proj_dir="${DEST_DIR}/${slug}"
  mkdir -p "$proj_dir"

  # mikefarah/yq: pass project via env and use strenv()
  repos=()
  while IFS= read -r _repo; do
    [ -n "${_repo:-}" ] && repos+=("$_repo")
  done < <(P="$project" yq -r '.projects[strenv(P)][]?' "$CONFIG_FILE" 2>/dev/null || true)

  if [ "${#repos[@]}" -eq 0 ]; then
    log "[$project] no repos listed. Created: $proj_dir"
    continue
  fi

  log "[$project] processing ${#repos[@]} repo(s) → ${proj_dir}"
  for entry in "${repos[@]}"; do
    [ -z "$entry" ] && continue
    IFS='|' read -r git_url repo_dir <<<"$(to_git_url_and_dir "$entry")"
    target="${proj_dir}/${repo_dir}"

    if [ -d "$target/.git" ]; then
      log " - updating ${repo_dir}"
      (cd "$target" && git pull --ff-only --quiet || warn "   pull failed for ${repo_dir}")
    else
      log " - cloning ${git_url}"
      if ! git clone --quiet "$git_url" "$target"; then
        warn "   clone failed for ${git_url}"
      fi
    fi
  done
done <<< "${projects}"

log "Done. Repos in: ${DEST_DIR}"
