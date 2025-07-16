# Compiles the updater script for Hymnal Browser Lite using Ahk2Exe.

& Ahk2Exe.exe `
  /in "src/installer/updater.ahk" `
  /compress 1 `
  /out "../../bin/Hymnal Browser Lite Updater.exe" `

Start-Sleep -Seconds 1
Add-Type -AssemblyName PresentationFramework

if (Test-Path "bin/Hymnal Browser Lite Updater.exe") {
  Write-Host 'Compilation successful: "bin/Hymnal Browser Lite Updater.exe" created.'
} else {
  Write-Host 'Compilation failed: "bin/Hymnal Browser Lite Updater.exe" not found.'
}
