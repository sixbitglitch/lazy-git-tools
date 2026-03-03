# Switch this repo to a different GitHub organisation (transfer on GitHub, update remote, commit & push)
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

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
Set-Location $root

$origin = git remote get-url origin 2>$null
if (-not $origin) {
  Write-Error "No remote 'origin' found."
  exit 1
}
if ($origin -match "github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$") {
  $currentOwner = $Matches[1]
  $repoName = $Matches[2] -replace '\.git$', ''
} else {
  Write-Error "Could not parse owner/repo from origin ($origin)."
  exit 1
}

$headers = @{
  Authorization = "token $token"
  Accept        = "application/vnd.github.v3+json"
}
$myLogin = $null
try {
  $user = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers
  $myLogin = $user.login
} catch { }
if (-not $myLogin) {
  Write-Error "Could not get current user from GitHub."
  exit 1
}

$orgs = @()
try {
  $orgsList = Invoke-RestMethod -Uri "https://api.github.com/user/orgs" -Headers $headers
  $orgs = @($orgsList | ForEach-Object { $_.login })
} catch { }

Write-Host "Current repo: $currentOwner/$repoName"
Write-Host "Select new owner (repo will be transferred there):"
Write-Host "  0) none (my user account: $myLogin)"
$i = 1
foreach ($o in $orgs) {
  $mark = if ($o -eq $currentOwner) { " (current)" } else { "" }
  Write-Host "  $i) $o$mark"
  $i++
}
$choice = Read-Host
if ([string]::IsNullOrWhiteSpace($choice) -or $choice.Trim() -eq "0") {
  $newOwner = $myLogin
} else {
  $choiceNum = 0
  if (-not [int]::TryParse($choice.Trim(), [ref]$choiceNum) -or $choiceNum -lt 1 -or $choiceNum -gt $orgs.Count) {
    Write-Error "Invalid choice."
    exit 1
  }
  $newOwner = $orgs[$choiceNum - 1]
}
if ($newOwner -eq $currentOwner) {
  Write-Host "Already under $currentOwner. Nothing to do."
  exit 0
}

Write-Host "Transferring $currentOwner/$repoName to $newOwner..."
$body = @{ new_owner = $newOwner } | ConvertTo-Json
try {
  Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$currentOwner/$repoName/transfer" -Headers $headers -Body $body -ContentType "application/json" | Out-Null
} catch {
  $err = $_.ErrorDetails.Message
  if ($err) {
    $o = $err | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($o.message) { $err = $o.message }
  }
  Write-Error "GitHub API error: $err"
  exit 1
}

# Transfer can be async or require org acceptance; wait for repo to appear at new location
Write-Host "Waiting for repo at $newOwner/$repoName..."
$max = 20; $i = 0; $code = 0
while ($i -lt $max) {
  try {
    $r = Invoke-WebRequest -Uri "https://api.github.com/repos/$newOwner/$repoName" -Headers $headers -Method Get -UseBasicParsing -ErrorAction Stop
    $code = $r.StatusCode
  } catch { if ($_.Exception.Response) { $code = $_.Exception.Response.StatusCode.value__ } }
  if ($code -eq 200) { break }
  Start-Sleep -Seconds 3
  $i++
}
if ($code -ne 200) {
  Write-Host "Repo not yet available at $newOwner/$repoName. If the org must accept the transfer, do that in GitHub, then run: git push" -ForegroundColor Yellow
}

git remote set-url origin "https://github.com/${newOwner}/${repoName}.git"
Write-Host "Remote updated to $newOwner/$repoName."

git add -A 2>$null
git commit -m "Switch organisation to $newOwner" 2>$null
git push 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Push failed. If the transfer is still pending or required acceptance, complete it on GitHub then run: git push" -ForegroundColor Yellow
  exit 1
}
Write-Host "Done."
