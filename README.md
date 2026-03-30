# lazy-git-tools

I made these because I'm lazy and I can never remember commandline parameters. 

Cross-platform git helper scripts: pull, push, commit, submodules, branch, create repo, and GitHub login. Install once per system, use from any terminal.

## Scripts

### GitHub
| Command | Description |
|---------|-------------|
| `git-create` | Turn this folder into a repo: prompts for name, org, public/private, then creates on GitHub and adds remote |
| `git-switch-org` | List your GitHub orgs (or “none” = your user); transfer this repo there, update remote, commit & push |
| `git-switch-private` | Set this GitHub repo to private |
| `git-switch-public` | Set this GitHub repo to public |
| `git-login` | Log in to Git via browser (GitHub device flow) |

### Repo
| Command | Description |
|---------|-------------|
| `git-clone` *url* [*dir*] | Clone a repo by URL; optional *dir*; inits submodules |
| `git-pull` | Update to latest commit and init/update submodules in this repo |
| `git-push` | Push changes (including submodules) |
| `git-commit` [*msg*] | Commit latest changes (default: `"Update"`) |
| `git-commit-push` [*msg*] | Commit and push in one command (default: `"Update"`) |
| `git-branch` *name* | Create and switch to a new branch with *name* |
| `git-switch` | List branches; pick one to switch to |
| `git-pr` | Open GitHub PR page for the current branch |
| `git-create-ignore` *type* | Add .gitignore for *type*: unity, godot, node, python, arduino, pico, esp32, dotnet |
| `git-add-license` *type* | Add LICENSE file: CC, unlicense, gpl, mit, or none |
| `git-download` | **Forced** update: overwrite local files (resets/cleans; includes submodules) |
| `git-upload` [*msg*] | **Forced** commit & push: overwrite remote history (includes submodules) |

### Submodules
`git-*-all-submodules` run from repo root. `git-*-submodule` (no “all”) run from inside the submodule folder and act on that one only.
| Command | Description |
|---------|-------------|
| `git-pull-all-submodules` | Pull/update all submodules (init, then pull each) |
| `git-commit-all-submodules` [*msg*] | Commit in all submodules, then in this repo (default: `"Update"`) |
| `git-push-all-submodules` | Push this repo and all submodules |
| `git-add-submodule` *url* [*name*] | Add a repo as submodule in the **current folder** (not repo root) |
| `git-remove-submodule` *path* | Remove a submodule and clean up |
| `git-pull-submodule` | Pull only the **current** submodule |
| `git-push-submodule` | Push only the **current** submodule |
| `git-commit-submodule` [*msg*] | Commit only in the **current** submodule (default: `"Update"`) |



### Other
| Command | Description |
|---------|-------------|
| `git-help` | List all lazy git-tools commands |

## Setup

Run the script for your platform (installs Git if missing, then installs the scripts globally):

- **Linux (Arch):** `./setup-arch.sh`
- **Linux (Debian/Ubuntu):** `./setup-debian.sh`
- **macOS:** `./setup-mac.sh`
- **Windows (PowerShell):** `.\setup-windows.ps1`

After setup, the commands are available from any terminal.
