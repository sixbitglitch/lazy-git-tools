# git-tools

Cross-platform git helper scripts: pull, push, commit, submodules, branch, create repo, and GitHub login. Install once per system, use from any terminal.

## Scripts

Run submodule commands (`git-*-submodule`) from inside the submodule directory; they act on that folder only.

| Command | Description |
|---------|-------------|
| `git-pull` | Update to latest commit and init/update submodules in this repo |
| `git-push` | Push changes (including submodules) |
| `git-commit` [*msg*] | Commit latest changes (default: `"Update"`) |
| `git-branch` *name* | Create and switch to a new branch |
| `git-commit-submodules` [*msg*] | Commit in **all** submodules, then in this repo (default: `"Update"`) |
| `git-import-submodule` *url* [*name*] | Add a repo as submodule in the **current folder** (not repo root) |
| `git-remove-submodule` *path* | Remove a submodule and clean up |
| `git-pull-submodule` | Pull only the **current** submodule |
| `git-push-submodule` | Push only the **current** submodule |
| `git-commit-submodule` [*msg*] | Commit only in the **current** submodule (default: `"Update"`) |
| `git-create` | Turn this folder into a repo: prompts for name, org, public/private, then creates on GitHub and adds remote |
| `git-login` | Log in to Git via browser (GitHub device flow) |

## Setup

Run the script for your platform (installs Git if missing, then installs the scripts globally):

- **Linux (Arch):** `./setup-arch.sh`
- **Linux (Debian/Ubuntu):** `./setup-debian.sh`
- **macOS:** `./setup-mac.sh`
- **Windows (PowerShell):** `.\setup-windows.ps1`

After setup, the commands are available from any terminal.
