# Update all submodules in this repo: commit in each, then commit here
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
Set-Location $root
$msg = if ($args.Count -gt 0) { $args[0] } else { "Update" }
if (Test-Path .gitmodules) {
  git submodule foreach "git add -A; git commit -m '$msg'"
}
git add -A
git commit -m $msg
