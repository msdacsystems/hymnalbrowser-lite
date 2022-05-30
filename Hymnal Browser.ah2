;; MSDAC Systems Hymnal Browser Lite
;; 
;; (c) 2022 Ken Verdadero, Reynald Ycong

/*
    ----------------------------------
    MSDAC Systems Hymnal Browser Lite
    ----------------------------------
    A general hymn browser for Seventh-day Adventist Church

    (c) 2022 Ken Verdadero 
    Made with AutoHotKey v2 Beta 3
    Orig. 2022-04-22
*/

#Include ..\lib\KVLib.ah2
#Include ext\software.ah2
#Include ext\interface.ah2
#Include ext\hymnal.ah2
#Include ext\system.ah2
#Include ext\core.ah2
#SingleInstance Force
#NoTrayIcon
InstallMouseHook 


UI := Interface()
Interface.ConnectEvents()

Completer.setup()

SendMessage(0x80, 1, DllCall("LoadImage", "uint", 0, "str", SW.FILE_ICON, "uint", 1, "int", 128, "int", 128, "uint", 0x10))
TraySetIcon(SW.FILE_ICON)

UI.MAIN.Show()

SetTimer(EntryListener, 50)
SetTimer(CompleterListener, 50)


EntryListener() {
    Entry.Listener()
}

CompleterListener() {
    Completer.Listener()
}
; GUI_MAIN.GetClientPos(&X, &Y, &W, &H)
; GUI_MAIN.Move(X, Y, SW.SIZE[1], SW.SIZE[2])
; MonitorGetWorkArea(MonitorGetPrimary(), &L, &T, &R, &B)
; Sleep(3000)
; GUI_MAIN.Move(R/2-(W/2), B/2-(H/2), SW.DEF_SIZE[1], SW.DEF_SIZE[2])
; ToolRep(L, T, R, B)
; WinMove(R/2-(SW.DEF_SIZE[1]/2), B/2-(SW.DEF_SIZE[2]-2), SW.DEF_SIZE[1], SW.DEF_SIZE[2], SW.TITLE)


; hIcon32 := 
; ToolRep(hIcon32)