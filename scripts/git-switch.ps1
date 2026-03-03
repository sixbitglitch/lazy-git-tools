# List branches and switch to the one you select
$ErrorActionPreference = "Stop"
$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { Write-Error "Not a git repository"; exit 1 }
Set-Location $root
$current = git branch --show-current 2>$null
$branchOutput = git branch --list --no-color 2>$null
$branches = @($branchOutput | ForEach-Object { $_ -replace '^[\*\s]+', '' } | Where-Object { $_.Trim() })
if ($branches.Count -eq 0) {
  Write-Error "No branches found."
  exit 1
}
Write-Host "Select branch to switch to:"
$i = 1
foreach ($b in $branches) {
  $mark = if ($b -eq $current) { " (current)" } else { "" }
  Write-Host "  $i) $b$mark"
  $i++
}
$choice = Read-Host
$choiceNum = 0
if (-not [int]::TryParse($choice.Trim(), [ref]$choiceNum) -or $choiceNum -lt 1 -or $choiceNum -gt $branches.Count) {
  Write-Error "Invalid choice."
  exit 1
}
$target = $branches[$choiceNum - 1]
if ($target -eq $current) {
  Write-Host "Already on $current."
  exit 0
}
git checkout $target
Write-Host "Switched to $target."
