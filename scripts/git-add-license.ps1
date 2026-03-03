# Add a LICENSE file by type. Usage: git-add-license <CC|unlicense|gpl|mit|none>
param([Parameter(Mandatory=$true, Position=0)][string]$LicenseType)
$ErrorActionPreference = "Stop"
$valid = @("cc","unlicense","gpl","mit","none")
$type = $LicenseType.Trim().ToLower()
if ($type -notin $valid) {
  Write-Error "Unknown type: $LicenseType. Use one of: $($valid -join ', ')"
  exit 1
}

$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { $root = Get-Location }
Set-Location $root
$licenseFile = "LICENSE"
if (Test-Path $licenseFile) {
  Write-Error "LICENSE already exists. Remove it first to replace."
  exit 1
}

$year = Get-Date -Format "yyyy"
$name = git config user.name 2>$null
if (-not $name) { $name = "Copyright Holder" }

switch ($type) {
  "none" {
    @"
No License

Copyright (c) $name. All rights reserved.

No license is granted. You may not use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of this software or
documentation without explicit permission from the copyright holder.
"@ | Set-Content -Path $licenseFile
  }
  "unlicense" {
    @"
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
"@ | Set-Content -Path $licenseFile
  }
  "mit" {
    @"
MIT License

Copyright (c) $year $name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@ | Set-Content -Path $licenseFile
  }
  "cc" {
    @"
CC0 1.0 Universal - Public Domain Dedication

The person who associated a work with this deed has dedicated the work to
the public domain by waiving all of his or her rights to the work worldwide
under copyright law, including all related and neighboring rights, to the
extent allowed by law.

You can copy, modify, distribute and perform the work, even for commercial
purposes, all without asking permission.

In no way are the patent or trademark rights of any person affected by CC0,
nor are the rights that other persons may have in the work or in how the
work is used, such as publicity or privacy rights.

Unless expressly stated otherwise, the person who associated a work with
this deed makes no warranties about the work, and disclaims liability for
all uses of the work, to the fullest extent permitted by applicable law.

https://creativecommons.org/publicdomain/zero/1.0/
"@ | Set-Content -Path $licenseFile
  }
  "gpl" {
    try {
      Invoke-WebRequest -Uri "https://www.gnu.org/licenses/gpl-3.0.txt" -UseBasicParsing -OutFile $licenseFile | Out-Null
      if (-not (Test-Path $licenseFile) -or (Get-Item $licenseFile).Length -eq 0) {
        throw "Empty or missing file"
      }
    } catch {
      Write-Error "Could not fetch GPL-3.0. Create LICENSE manually from https://www.gnu.org/licenses/gpl-3.0.txt"
      exit 1
    }
  }
}
Write-Host "Created $licenseFile ($type)."
