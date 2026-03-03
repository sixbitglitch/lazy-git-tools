# Add a .gitignore template by project type. Usage: git-create-ignore <unity|godot|node|python|arduino|pico|esp32|dotnet>
param([Parameter(Mandatory=$true, Position=0)][string]$IgnoreType)
$ErrorActionPreference = "Stop"
$valid = @("unity","godot","node","python","arduino","pico","esp32","dotnet")
$type = $IgnoreType.Trim().ToLower()
if ($type -notin $valid) {
  Write-Error "Unknown type: $IgnoreType. Use one of: $($valid -join ', ')"
  exit 1
}

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { $root = Get-Location }
Set-Location $root
$ignoreFile = ".gitignore"
$marker = "# lazy-git-tools: $type"
$commonMarker = "# lazy-git-tools: common"
if (Test-Path $ignoreFile) {
  $content = Get-Content $ignoreFile -Raw
  if ($content -and $content.Contains($marker)) {
    Write-Host ".gitignore already has $type rules. Skipping."
    exit 0
  }
}

# Ensure common OS/temp/thumbnail ignores are present (once)
$commonBlock = @"
# lazy-git-tools: common
.DS_Store
.DS_Store?
._*
Thumbs.db
ehthumbs.db
Desktop.ini
*.swp
*.swo
*~
.Spotlight-V100
.Trashes
"@
$needsCommon = -not (Test-Path $ignoreFile) -or -not (Get-Content $ignoreFile -Raw).Contains($commonMarker)
if ($needsCommon) {
  $lines = @()
  if (Test-Path $ignoreFile) { $existing = Get-Content $ignoreFile; if ($existing) { $lines += "" } }
  $lines + $commonBlock.Trim().Split("`n") | Add-Content -Path $ignoreFile
}

$templates = @{
  unity = @"
/[Ll]ibrary/
/[Tt]emp/
/[Oo]bj/
/[Bb]uild/
/[Bb]uilds/
/[Ll]ogs/
/[Uu]ser[Ss]ettings/
/[Mm]emoryCaptures/
/[Rr]ecordings/
*.log
*.blend1
*.blend1.meta
.vs/
.gradle/
ExportedObj/
.consulo/
*.csproj
*.unityproj
*.sln
*.suo
*.tmp
*.user
*.userprefs
*.pidb
*.booproj
*.svd
*.pdb
*.mdb
*.opendb
*.VC.db
*.pidb.meta
*.pdb.meta
*.mdb.meta
sysinfo.txt
mono_crash.*
*.apk
*.aab
*.unitypackage
*.unitypackage.meta
*.app
crashlytics-build.properties
*.DotSettings.user
"@
  godot = @"
.godot/
.import/
.mono/
*.translation
export_presets.cfg
mono_crash.*.json
"@
  node = @"
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
node_modules/
jspm_packages/
.npm
.eslintcache
.stylelintcache
.env
.env.*
!.env.example
.cache
.parcel-cache
.next
out
.nuxt
dist
.output
*.tsbuildinfo
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions
"@
  python = @"
__pycache__/
*.py[cod]
*`$py.class
*.so
.Python
build/
develop-eggs/
dist/
eggs/
.eggs/
*.egg-info/
*.egg
.env
.venv
env/
venv/
ENV/
.pytest_cache/
.mypy_cache/
.ruff_cache/
"@
  arduino = @"
build/
*.elf
*.hex
*.bin
*.map
.vscode/
"@
  pico = @"
build/
*.elf
*.hex
*.bin
*.uf2
*.map
.vscode/
"@
  esp32 = @"
build/
sdkconfig.old
managed_components/
*.elf
*.bin
*.map
.vscode/
"@
  dotnet = @"
[Dd]ebug/
[Rr]elease/
x64/
x86/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/
.vs/
*.user
*.suo
*.userosscache
*.sln.docstates
*.nupkg
*.snupkg
project.lock.json
project.fragment.lock.json
artifacts/
"@
}

$lines = @()
if (Test-Path $ignoreFile) {
  $existing = Get-Content $ignoreFile
  if ($existing) { $lines += "" }
}
$lines += $marker
$lines += $templates[$type].Trim().Split("`n")
$lines | Add-Content -Path $ignoreFile
Write-Host "Added $type .gitignore rules to $ignoreFile"
