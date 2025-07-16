# PowerShell script to package Hymnal Browser Lite.exe and dist/template into a distribution archive.

# Paths
$root = $PSScriptRoot
$7zPath = Join-Path $root '..\bin\7z.exe'
$exePath = Join-Path $root '..\Hymnal Browser Lite.exe'
$templatePath = Join-Path $root '..\dist\template'
$versionFile = Join-Path $root '..\src\version.ahk'
$distDir = Join-Path $root '..\dist'

# Get version
$versionContent = Get-Content $versionFile -Raw
if ($versionContent -match '__VERSION\s*:=\s*"(.*?)"') {
    $VERSION = $matches[1]
} else {
    Write-Error "Version not found in $versionFile"
    exit 1
}

$outputArchive = Join-Path $distDir "Hymnal-Browser-Lite-v$VERSION.zip"

# Check dependencies
if (!(Test-Path $7zPath)) { Write-Error "7z.exe not found at $7zPath"; exit 1 }
if (!(Test-Path $exePath)) { Write-Error "Hymnal Browser Lite.exe not found at $exePath"; exit 1 }
if (!(Test-Path $templatePath)) { Write-Error "Template folder not found at $templatePath"; exit 1 }

# Confirm overwrite
if (Test-Path $outputArchive) {
    $response = Read-Host "Archive $outputArchive already exists. Overwrite? (y/n)"
    if ($response -notin @('y','Y')) {
        Write-Host "Aborted by user."
        exit 0
    } else {
        try {
            Remove-Item $outputArchive -Force -ErrorAction Stop
        } catch {
            while ($true) {
                Write-Warning "Could not delete $outputArchive. It may be open or locked by another process. Please close the file if it is open in another application (e.g., Explorer, zip viewer, etc.)."
                Read-Host "After closing the file, press Enter to retry. (Ctrl+C to abort)"
                try {
                    Remove-Item $outputArchive -Force -ErrorAction Stop
                    break
                } catch {
                    # Loop again
                }
            }
        }
    }
}

# Copy exe into template subfolder before archiving
$targetExeDir = Join-Path $templatePath 'Hymnal Browser Lite'
$targetExePath = Join-Path $targetExeDir 'Hymnal Browser Lite.exe'

if (Test-Path $targetExePath) { Remove-Item $targetExePath -Force }
New-Item -ItemType Directory -Force -Path $targetExeDir | Out-Null
Copy-Item $exePath $targetExePath -Force

# Archive everything in template (contents only)
$templateContents = Join-Path $templatePath '*'
& $7zPath a -t7z -mx=9 -m0=lzma2 -md=64m -mfb=64 -ms=16g $outputArchive $templateContents

# Clean up copied exe
Remove-Item $targetExePath -Force

if ($LASTEXITCODE -eq 0) {
    Write-Host "Archive created successfully: $outputArchive"
} else {
    Write-Error "Failed to create archive."
}
