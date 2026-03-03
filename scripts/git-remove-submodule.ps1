# Remove a submodule (unregister and delete from working tree)
# Usage: git-remove-submodule <path>
param([Parameter(Mandatory=$true, Position=0)][string]$Path)
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
Set-Location $root
git submodule deinit -f $Path
git rm -f $Path
$modulesPath = Join-Path $root ".git/modules/$Path"
if (Test-Path $modulesPath) { Remove-Item -Recurse -Force $modulesPath }
Write-Host "Removed submodule: $Path"
