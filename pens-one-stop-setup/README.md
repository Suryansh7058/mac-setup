# Pens One-Stop Mac Setup

This bundle gives you a quick, repeatable setup for a temporary or new Mac:

- **01_bootstrap_macos.sh** — installs dev tools (Homebrew formulae/casks), zsh/Oh-My-Zsh + Powerlevel10k, WezTerm + Nerd Font, Node (nvm: LTS 22 + 20), Docker CLI + **Colima**, Kubernetes (kubectl/k9s/helm), Terraform toolchain, Bitbucket SSH, and **stskeygen** from Cimpress. Also wires aliases (Docker/K8s/Terraform/AWS SSO) and opens SSO URLs in **Chrome**.
- **02_verify_and_start.sh** — starts Colima and prints versions so you can confirm it’s all working.
- **03_clone_pens.sh** — clones/pulls repositories into `~/Desktop/pens/<project>` based on a YAML config.
- **pens_repos.yml** — pre-filled with your project → repo mapping under the `national-pen` workspace.

## Quick Start

```bash
chmod +x 01_bootstrap_macos.sh 02_verify_and_start.sh 03_clone_pens.sh

./01_bootstrap_macos.sh
exec zsh -l
./02_verify_and_start.sh

# Clone repos (uses ./pens_repos.yml by default)
./03_clone_pens.sh
```

If you run `03_clone_pens.sh` from another directory, you can point to a config or change destination:

```bash
CONFIG_FILE="$HOME/Desktop/pens_repos.yml" DEST_DIR="$HOME/Work/pens" ./03_clone_pens.sh
```

## SSO Helpers

Aliases like `aws_devops`, `aws_abc`, etc. will open the SSO role page **in Chrome** and then invoke `stskeygen` (installed from `cimpress-mcp/stskeygen-installers`).

## Notes

- Docker daemon is provided by **Colima** (no Docker Desktop). Start it with `dstart` or run `./02_verify_and_start.sh`.
- If zsh warns about insecure completion directories, we fix permissions automatically in the bootstrap script.
- Node LTS is **22** by default; **20** is also installed for compatibility: use `nvm use 20` when needed.
