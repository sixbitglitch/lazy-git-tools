# Commit and push in one command (default message: Update)
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
Set-Location $root
$msg = if ($args.Count -gt 0) { $args[0] } else { "Update" }
git add -A
git commit -m $msg 2>$null
git push --recurse-submodules=on-demand
