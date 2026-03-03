# Install git-tools globally on Windows (PowerShell)
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Install to user's local bin; add to PATH if not already
$InstallDir = Join-Path $env:LOCALAPPDATA "bin"
$ScriptsDir = Join-Path $ScriptDir "scripts"

# Ensure Git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "Git not found. Install from https://git-scm.com/download/win or run: winget install Git.Git"
  exit 1
}

# Default new repos to branch "main" (suppresses master/main hint)
git config --global init.defaultBranch main

# Create install directory
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# Copy PowerShell scripts and create .cmd wrappers so they work from cmd.exe too
$ps1Files = Get-ChildItem -Path $ScriptsDir -Filter "git-*.ps1"
foreach ($f in $ps1Files) {
  $name = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $destPs1 = Join-Path $InstallDir ($name + ".ps1")
  Copy-Item $f.FullName -Destination $destPs1 -Force
  # Wrapper .cmd so 'git-pull' works from cmd and PowerShell (when .ps1 isn't in PATHEXT)
  $cmdPath = Join-Path $InstallDir ($name + ".cmd")
  Set-Content -Path $cmdPath -Value "@powershell -NoProfile -ExecutionPolicy Bypass -File `"$destPs1`" %*"
  Write-Host "  $name"
}

# Add to user PATH if not present
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$InstallDir*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$InstallDir", "User")
  $env:Path = "$env:Path;$InstallDir"
  Write-Host "Added $InstallDir to user PATH. You may need to restart the terminal."
}

Write-Host "Done. Run git-pull, git-push, git-commit, etc. from any terminal."
