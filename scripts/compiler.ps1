# Run this script to compile the application.

& Ahk2Exe.exe /in "main.ahk" /compress 1 | Out-Null

Start-Process "Hymnal Browser Lite.exe"