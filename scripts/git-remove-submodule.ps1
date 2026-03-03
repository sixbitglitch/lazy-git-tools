# Remove a submodule (unregister and delete from working tree)
# Usage: git-remove-submodule <path>   (e.g. raretx, ./raretx, or libraries/raretx)
param([Parameter(Mandatory=$true, Position=0)][string]$Path)
$ErrorActionPreference = "Stop"
$path = $Path.Trim() -replace '^\.\/', '' -replace '\/$', ''
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
$prefix = git rev-parse --show-prefix 2>$null
if ($prefix -and $path -notmatch '/') { $path = $prefix + $path }
Set-Location $root
git submodule deinit -f $path
git rm -f $path
$modulesPath = Join-Path $root ".git/modules/$path"
if (Test-Path $modulesPath) { Remove-Item -Recurse -Force $modulesPath }
Write-Host "Removed submodule: $path"
