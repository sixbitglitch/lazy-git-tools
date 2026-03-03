# Clone a repo by URL (optional: into directory)
$ErrorActionPreference = "Stop"
if (-not $args[0]) {
  Write-Error "Usage: git-clone <url> [directory]"
  Write-Host "  Clone a repository. If directory is omitted, uses repo name from URL."
  exit 1
}
$url = $args[0]
$dir = $args[1]
if ($dir) {
  git clone $url $dir
  Set-Location $dir
  git submodule update --init --recursive
} else {
  git clone $url
  $cloneDir = [System.IO.Path]::GetFileNameWithoutExtension($url.TrimEnd('/').Split('/')[-1])
  if ($cloneDir -like "*.git") { $cloneDir = $cloneDir -replace '\.git$','' }
  Set-Location $cloneDir
  git submodule update --init --recursive
}
