# Add a git repo as a submodule in the current folder (not repo root)
# Usage: git-import-submodule <repository-url> [name]
param(
  [Parameter(Mandatory=$true, Position=0)]
  [string]$Url,
  [Parameter(Position=1)]
  [string]$Name
)
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
if (-not $Name) {
  $Name = [System.IO.Path]::GetFileNameWithoutExtension($Url -replace '\.git$', '')
}
# Path from repo root to cwd (e.g. "libs\" or "" at root)
$prefix = git rev-parse --show-prefix 2>$null
if ($prefix) { $path = $prefix + $Name } else { $path = $Name }
Set-Location $root
git submodule add $Url $path
