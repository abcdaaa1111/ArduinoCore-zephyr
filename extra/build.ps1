# Copyright (c) Arduino s.r.l. and/or its affiliated companies
# SPDX-License-Identifier: Apache-2.0
#
# PowerShell equivalent of extra/build.sh
#
# Usage:
#   .\extra\build.ps1 <arduino_board>
#   .\extra\build.ps1 <zephyr_board> [<west_args>...]
#
# Examples:
#   .\extra\build.ps1 portentah7
#   .\extra\build.ps1 sf32lb52devkitlcd
#   .\extra\build.ps1 "arduino_portenta_h7@1.0.0//m7"
#   .\extra\build.ps1 portentah7 --debug

param(
    [Parameter(Position = 0)]
    [string]$BoardArg,
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helper: read a single field from boards.txt for a given board prefix.
# ---------------------------------------------------------------------------
function Get-BoardField([string]$board, [string]$field) {
    $escaped = [regex]::Escape($board) + '\.' + [regex]::Escape($field) + '='
    $line = Get-Content boards.txt |
        Where-Object { $_ -notmatch '^\s*#' -and $_ -match $escaped } |
        Select-Object -First 1
    if ($line) { return ($line -split '=', 2)[1].Trim() }
    return $null
}

# ---------------------------------------------------------------------------
# Show help / board list
# ---------------------------------------------------------------------------
if (-not $BoardArg -or $BoardArg -eq '-h' -or $BoardArg -eq '--help') {
    Write-Host "Usage:"
    Write-Host "  .\extra\build.ps1 <arduino_board>"
    Write-Host "  .\extra\build.ps1 <zephyr_board> [<west_args>]"
    Write-Host ""
    Write-Host "Available targets (from boards.txt):"
    $boards = Get-Content boards.txt |
        Where-Object { $_ -notmatch '^\s*#' -and $_ -match '\.build\.variant=' } |
        ForEach-Object { ($_ -split '\.build\.variant=')[0] }
    foreach ($b in $boards) {
        $t = Get-BoardField $b 'build.zephyr_target'
        $a = Get-BoardField $b 'build.zephyr_args'
        Write-Host ("  {0,-30} {1} {2}" -f $b, $t, $a)
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Resolve ZEPHYR_SDK_INSTALL_DIR (mirrors the SDK auto-detection in build.sh)
# ---------------------------------------------------------------------------
if (-not $env:ZEPHYR_SDK_INSTALL_DIR) {
    $sdkPath = (west sdk list 2>$null |
        Select-String 'path' | Select-Object -Last 1) -replace '.*:\s*', ''
    $sdkPath = $sdkPath.Trim()
    if (-not $sdkPath) {
        Write-Error "ZEPHYR_SDK_INSTALL_DIR not set and no SDK found via 'west sdk list'"
        exit 1
    }
    $env:ZEPHYR_SDK_INSTALL_DIR = $sdkPath
    Write-Host "Using SDK: $sdkPath"
}

# ---------------------------------------------------------------------------
# Resolve ZEPHYR_BASE
# ---------------------------------------------------------------------------
# if (-not $env:ZEPHYR_BASE) {
#     $topdir = (west topdir).Trim()
#     $env:ZEPHYR_BASE = "$topdir/zephyr"
# }
if (-not $env:ZEPHYR_BASE) {
    $topdir = (west topdir).Trim()
    $zephyrBase = (west config zephyr.base 2>$null).Trim()
    if (-not $zephyrBase) { $zephyrBase = 'zephyr' }
    $env:ZEPHYR_BASE = "$topdir/$zephyrBase"
}

# ---------------------------------------------------------------------------
# Ensure cores/arduino/api is a real directory junction, not a git text-symlink.
# Git on Windows stores symlinks as plain text files; this fixes that.
# ---------------------------------------------------------------------------
$apiLink = Join-Path $PSScriptRoot "..\cores\arduino\api"
$apiLink = (Resolve-Path -LiteralPath (Split-Path $apiLink -Parent)).Path + "\api"
$topdir  = (west topdir 2>$null).Trim()
if (-not $topdir) { $topdir = Split-Path $PSScriptRoot -Parent | Split-Path -Parent }
$apiTarget = Join-Path $topdir "modules\lib\Arduino-Zephyr-API\zephyr\blobs\ArduinoCore-API\api"
if (Test-Path $apiTarget -PathType Container) {
    $existing = Get-Item $apiLink -Force -ErrorAction SilentlyContinue
    $needJunction = $false
    if (-not $existing) {
        $needJunction = $true
    } elseif (-not $existing.PSIsContainer) {
        # It's the git text-file symlink — remove and replace
        Remove-Item -Force $apiLink
        $needJunction = $true
    } elseif ($existing.LinkType -ne 'Junction') {
        # Real directory but not a junction — leave it alone
    }
    if ($needJunction) {
        cmd /c "mklink /J `"$apiLink`" `"$apiTarget`"" | Out-Null
        Write-Host "Created junction: cores/arduino/api -> $apiTarget"
    }
} else {
    Write-Warning "ArduinoCore-API blob not found at: $apiTarget"
    Write-Warning "Run 'west blobs fetch arduinocore-zephyr' or install the blobs manually."
}

# ---------------------------------------------------------------------------
# Look up the arduino board name in boards.txt
# ---------------------------------------------------------------------------
$target  = Get-BoardField $BoardArg 'build.zephyr_target'
$variant = Get-BoardField $BoardArg 'build.variant'
$bldArgs = Get-BoardField $BoardArg 'build.zephyr_args'

if ($target) {
    Write-Host "Arduino board: $BoardArg  ->  target: $target"
} else {
    # Treat as a raw Zephyr board target; remaining args forwarded as-is
    $target  = $BoardArg
    $bldArgs = ($ExtraArgs -join ' ')
    $variant = $null
    $ExtraArgs = @()   # already consumed
}

# --debug flag: append extra conf file
if ($ExtraArgs -contains '--debug') {
    $bldArgs = "$bldArgs -- -DEXTRA_CONF_FILE=../extra/debug.conf".Trim()
}

Write-Host ""
Write-Host "Build target : $target"
Write-Host "Build args   : $bldArgs"

# ---------------------------------------------------------------------------
# Get the NORMALIZED_BOARD_TARGET (variant name) via cmake when not known
# ---------------------------------------------------------------------------
if (-not $variant) {
    $cmakeOut = cmake "-DBOARD=$target" -P extra/get_variant_name.cmake 2>&1
    $variant  = ($cmakeOut | Select-String 'VARIANT=') -replace '.*VARIANT=', ''
    $variant  = $variant.Trim()
}

if (-not $variant) {
    Write-Error "Failed to get variant name from '$target'"
    exit 1
}
Write-Host "Build variant: $variant"

# ---------------------------------------------------------------------------
# Build the loader
# ---------------------------------------------------------------------------
$BUILD_DIR   = "build/$variant"
$VARIANT_DIR = "variants/$variant"

if (Test-Path $BUILD_DIR) { Remove-Item -Recurse -Force $BUILD_DIR }

$westCmd = "west build -p auto -d `"$BUILD_DIR`" -b `"$target`" loader -t llext-edk"
if ($bldArgs) { $westCmd = "$westCmd $bldArgs" }

Write-Host ""
Write-Host "Running: $westCmd"
Invoke-Expression $westCmd
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# ---------------------------------------------------------------------------
# Extract the generated EDK tarball into build dir, then copy to variant dir
# ---------------------------------------------------------------------------
New-Item -ItemType Directory -Force -Path $VARIANT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path "firmwares"  | Out-Null

$edkTar = "$BUILD_DIR/zephyr/llext-edk.tar.Z"
if (-not (Test-Path $edkTar)) {
    Write-Error "EDK tarball not found: $edkTar"
    exit 1
}

Push-Location $BUILD_DIR
if (Test-Path llext-edk) { Remove-Item -Recurse -Force llext-edk }
# Try system tar first; if it needs an external zstd helper, fall back to CMake's tar.
tar xf zephyr/llext-edk.tar.Z
if ($LASTEXITCODE -ne 0) {
    Write-Warning "tar extraction failed, retrying with 'cmake -E tar'"
    cmake -E tar xf zephyr/llext-edk.tar.Z
    if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }
}
Pop-Location

# Mirror: rsync -a --delete ${BUILD_DIR}/llext-edk ${VARIANT_DIR}/
$dstEdk = "$VARIANT_DIR/llext-edk"
if (Test-Path $dstEdk) { Remove-Item -Recurse -Force $dstEdk }
Copy-Item -Recurse "$BUILD_DIR/llext-edk" $VARIANT_DIR

# ---------------------------------------------------------------------------
# Strip inline C-style comments from EDK headers
# (equivalent to the perl one-liner in build.sh)
# Prefer perl when available (Git for Windows ships it); fall back to .NET regex.
# ---------------------------------------------------------------------------
$includeDir = "$VARIANT_DIR/llext-edk/include"
if (Test-Path $includeDir) {
    $perlExe = Get-Command perl -ErrorAction SilentlyContinue
    if ($perlExe) {
        $linePreproc   = '^\s*#\s*(if|else|elif|endif)'
        $lineComment   = '^\s*/\*'
        $lineCont      = '\\$'
        $cComment      = '\s*/\*.*?\*/'
        $headers = (Get-ChildItem -Recurse -File $includeDir | ForEach-Object { $_.FullName }) -join ' '
        perl -i -pe "s/${cComment}//gs unless /${linePreproc}/ || (/${lineComment}/ && !/${lineCont}/)" (Get-ChildItem -Recurse -File $includeDir | ForEach-Object { $_.FullName })
    } else {
        Write-Warning "perl not found; using .NET regex to strip inline C comments (best-effort)"
        $reInline = [regex]::new('/\*.*?\*/', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        foreach ($hdr in (Get-ChildItem -Recurse -File $includeDir)) {
            $lines  = Get-Content -Raw $hdr.FullName
            $result = ($lines -split "`n") | ForEach-Object {
                if ($_ -match '^\s*#\s*(if|else|elif|endif)' -or
                    ($_ -match '^\s*/\*' -and $_ -notmatch '\\$')) {
                    $_
                } else {
                    $reInline.Replace($_, '')
                }
            }
            [System.IO.File]::WriteAllText($hdr.FullName, ($result -join "`n"))
        }
    }
    Write-Host "Cleaned inline comments in $includeDir"
}

# ---------------------------------------------------------------------------
# Copy firmware artifacts (elf / bin / hex)
# ---------------------------------------------------------------------------
foreach ($ext in @('elf', 'bin', 'hex')) {
    $dst = "firmwares/zephyr-$variant.$ext"
    if (Test-Path $dst) { Remove-Item $dst }
    $src = "$BUILD_DIR/zephyr/zephyr.$ext"
    if (Test-Path $src) { Copy-Item $src $dst; Write-Host "Copied $dst" }
}

foreach ($extra in @('dts', 'config')) {
    $dst = "firmwares/zephyr-$variant.$extra"
    $src = "$BUILD_DIR/zephyr/zephyr.$extra"
    if (Test-Path $dst) { Remove-Item $dst }
    if (Test-Path $src) { Copy-Item $src $dst; Write-Host "Copied $dst" }
}

# ---------------------------------------------------------------------------
# Generate exported symbol scripts (provides.ld)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Generating exported symbol scripts"

$elf = "$BUILD_DIR/zephyr/zephyr.elf"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText(
    (Resolve-Path $VARIANT_DIR).Path + "\syms-dynamic.ld",
    (python extra/gen_provides.py $elf -L | Out-String),
    $utf8NoBom)

[System.IO.File]::WriteAllText(
    (Resolve-Path $VARIANT_DIR).Path + "\syms-static.ld",
    (python extra/gen_provides.py $elf -LF `
        "+kheap_llext_heap" `
        "+kheap__system_heap" `
        "*sketch_base_addr=_sketch_start" `
        "*sketch_max_size=_sketch_max_size" `
        "*loader_max_size=_loader_max_size" `
        "malloc=__wrap_malloc" `
        "free=__wrap_free" `
        "realloc=__wrap_realloc" `
        "calloc=__wrap_calloc" `
        "random=__wrap_random" | Out-String),
    $utf8NoBom)

# ---------------------------------------------------------------------------
# Generate arduino board files
# ---------------------------------------------------------------------------
cmake -P extra/gen_arduino_files.cmake $variant
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Build complete."
Write-Host "  Firmware : firmwares/zephyr-$variant.*"
Write-Host "  Variant  : $VARIANT_DIR"

Write-Host ""
Write-Host "Post-processing: stripping C-style comments from variant EDK headers..."
$includeDir = "$VARIANT_DIR/llext-edk/include"
if (Test-Path $includeDir) {
    $perlExe = Get-Command perl -ErrorAction SilentlyContinue
    if ($perlExe) {
        Get-ChildItem -Recurse -File $includeDir -Include "*.h" | ForEach-Object {
            perl -i -pe 's|/\*.*?\*/||gs' $_.FullName
        }
        Write-Host "Stripped comments (perl) in $includeDir"
    } else {
        $reInline = [regex]::new('/\*.*?\*/', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $count = 0
        foreach ($hdr in (Get-ChildItem -Recurse -File $includeDir -Include "*.h")) {
            $content = Get-Content -Raw $hdr.FullName
            if ($content -match '/\*') {
                $cleaned = $reInline.Replace($content, '')
                [System.IO.File]::WriteAllText($hdr.FullName, $cleaned)
                $count++
            }
        }
        Write-Host "Stripped comments (.NET regex) in $count files"
    }
} else {
    Write-Warning "Include dir not found, skipping comment strip: $includeDir"
}
