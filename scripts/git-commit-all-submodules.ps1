# Commit in all submodules (recursive, deepest first), then in this repo (default message: Update)
# Recursive: every nested submodule. Order: end of tree first, then work back to root.
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
Set-Location $root
$msg = if ($args.Count -gt 0) { $args[0] } else { "Update" }
if (Test-Path .gitmodules) {
  $paths = (git submodule foreach --recursive --quiet 'echo "$(git rev-parse --show-toplevel)"') -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  [Array]::Reverse($paths)
  foreach ($dir in $paths) {
    $rel = $dir
    if ($dir.StartsWith($root)) { $rel = $dir.Substring($root.Length).TrimStart('/', '\') }
    if (-not $rel) { $rel = "." }
    Write-Host "Entering '$rel'"
    Push-Location $dir
    if ((git rev-parse --abbrev-ref HEAD 2>$null) -eq "HEAD") {
      git checkout -B main 2>$null
      if (-not $?) { git checkout -B master 2>$null }
    }
    git add -A
    git commit -m $msg 2>$null
    Pop-Location
  }
}
Write-Host "Entering '.'"
git add -A
git commit -m $msg 2>$null
