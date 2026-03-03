# Create a GitHub repo from the current folder and add it as remote
$ErrorActionPreference = "Stop"

function Get-GitHubToken {
  if ($env:GITHUB_TOKEN) { return $env:GITHUB_TOKEN }
  $credPath = Join-Path $env:USERPROFILE ".git-credentials"
  if (Test-Path $credPath) {
    $line = Get-Content $credPath | Where-Object { $_ -match "github\.com" } | Select-Object -First 1
    if ($line -match "https://([^:]+):x-oauth-basic@github\.com") { return $Matches[1] }
  }
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    try { return (gh auth token 2>$null) } catch { }
  }
  return $null
}

$token = Get-GitHubToken
if (-not $token) {
  Write-Error "No GitHub token found. Run git-login or set GITHUB_TOKEN."
  exit 1
}

$repoName = (Read-Host "Repo name (e.g. my-project)").Trim()
if (-not $repoName) {
  Write-Error "Repo name is required."
  exit 1
}

# Fetch organisations and list as menu
$headers = @{
  Authorization = "token $token"
  Accept        = "application/vnd.github.v3+json"
}
$orgsList = @()
try {
  $orgs = Invoke-RestMethod -Uri "https://api.github.com/user/orgs" -Headers $headers
  $orgsList = @($orgs | ForEach-Object { $_.login })
} catch { }

Write-Host "Organisation (number, or Enter for 0 - none):"
Write-Host "  0) none"
$i = 1
foreach ($o in $orgsList) {
  Write-Host "  $i) $o"
  $i++
}
$orgChoice = Read-Host
if ([string]::IsNullOrWhiteSpace($orgChoice)) { $orgChoice = "0" }
$orgChoice = $orgChoice.Trim()
if ($orgChoice -eq "0") {
  $orgName = $null
} else {
  $idxNum = 0
  if ([int]::TryParse($orgChoice, [ref]$idxNum) -and $idxNum -ge 1 -and $idxNum -le $orgsList.Count) {
    $orgName = $orgsList[$idxNum - 1]
  } else {
    $orgName = $null
  }
}

$visibility = (Read-Host "Public or private? (public/private) [default: private]").Trim().ToLower()
if ($visibility -ne "private" -and $visibility -ne "public") { $visibility = "private" }
$private = ($visibility -eq "private")

$headers = @{
  Authorization = "token $token"
  Accept        = "application/vnd.github.v3+json"
}
$body = @{ name = $repoName; private = $private } | ConvertTo-Json

if ($orgName) {
  $url = "https://api.github.com/orgs/$orgName/repos"
} else {
  $url = "https://api.github.com/user/repos"
}

try {
  $r = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ContentType "application/json"
} catch {
  $err = $_.ErrorDetails.Message
  if ($err) {
    $o = $err | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($o.message) { $err = $o.message }
  }
  Write-Error "GitHub API error: $err"
  exit 1
}

$owner = $r.owner.login
# Use HTTPS URL; credential helper (from git-login) will supply token on push
$remoteUrl = "https://github.com/${owner}/${repoName}.git"

$dir = Get-Location
$isRepo = try { git rev-parse --is-inside-work-tree 2>$null } catch { $false }
if (-not $isRepo) {
  git init
  Write-Host "Initialized git in $dir"
}

try {
  git remote get-url origin 2>$null
  git remote set-url origin $remoteUrl
  Write-Host "Set origin to GitHub repo."
} catch {
  git remote add origin $remoteUrl
  Write-Host "Added remote origin."
}

git branch -M main 2>$null

# So first git-push sets upstream automatically
git config push.autoSetupRemote true

Write-Host ""
Write-Host "Repo created: $($r.clone_url)"
Write-Host "Push your code: git add -A && git commit -m `"Initial commit`" && git push -u origin main"
