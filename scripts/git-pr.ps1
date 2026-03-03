# Open GitHub PR page for the current branch
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
Set-Location $root
$origin = git remote get-url origin 2>$null
if (-not $origin) { Write-Error "No remote 'origin' found."; exit 1 }
if ($origin -notmatch "github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$") {
  Write-Error "Could not parse owner/repo from origin (not a GitHub repo?)."
  exit 1
}
$owner = $Matches[1]
$repo = $Matches[2] -replace '\.git$', ''
$branch = git branch --show-current 2>$null
$url = "https://github.com/$owner/$repo/pull/new/$branch"
Write-Host "Opening $url"
try { Start-Process $url } catch { Write-Host "Open in browser: $url" }
