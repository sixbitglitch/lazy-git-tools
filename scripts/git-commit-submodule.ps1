# Commit only in the submodule you're currently in (not all submodules)
# Usage: git-commit-submodule [message]
param([Parameter(Position=0)][string]$Message = "Update")
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
if (-not (Test-Path "$root/.git" -PathType Leaf)) {
  Write-Error "Not inside a submodule. Run this from a submodule directory."
  exit 1
}
Set-Location $root
git add -A
git commit -m $Message 2>$null
if (-not $?) { exit 0 }
