/*
    ----------------------------------
    MSDAC Systems Hymnal Browser Lite
    ----------------------------------
    A general hymn browser for Seventh-day Adventist Church, lightweight version.

    Coding style:
        - Classes, Functions, and Methods are in PascalCase
        - Parameters are in camelCase
        - Code ruler is 90

    Code dependencies:
        - KConfig
        - AHK2ExtLib (KV)

    Pre-requisites:
        - Hymnal Database (.sda) file
        - Microsoft Office PowerPoint or any .pptx-compatible software.
    
    Known issues:
        - [Process] Window activation in UICompleter doesn't seem to work
        if there's a similar application name present in processes.
        
    Limitations:
        - Since this application is written in AHKv2, interface design is limited
        to what's available resources.

    Notable Changes:
        v0.2.0 (2022-06-??) - [Empty]
        v0.1.0 (2022-06-06) - Initial Build

    ------------------------------- Code architecture -----------------------------------




    -------------------------------------------------------------------------------------
    (c) 2022 Ken Verdadero, Reynald Ycong
    Made with AutoHotKey v2 Beta 3

    Orig. 2022-04-22 prototype
    Rev 1. 2022-06-03 restructuring classes
    Rev 2. 2022-06-06 initial build
*/


/* External libraries */
#Include ..\lib\ext\Basic.ah2
#Include ..\lib\ext\Path.ah2
#Include ..\lib\ext\Maps.ah2
#Include ..\lib\ext\Misc.ah2
#Include ..\lib\TarZip.ah2
#Include ..\lib\KConfig.ah2
#Include ..\lib\KLogger.ah2

/*  External classes */
#Include src\system.ah2
#Include src\software.ah2 
#Include src\ui.ah2
#Include src\config.ah2
#Include src\hymnal.ah2
#Include src\background.ah2
#Include src\launcher.ah2
#Include src\session.ah2

/*  Interface classes */
#Include src\interface\events.ah2
#Include src\interface\mainmenu.ah2
#Include src\interface\searchbar.ah2
#Include src\interface\buttons.ah2
#Include src\interface\completer.ah2
#Include src\interface\contextMenu.ah2
#Include src\interface\settings.ah2

#SingleInstance Force                                                                       ;; One (1) Hymnal Browser is only allowed.
#NoTrayIcon

/*  System Props */
;@Ahk2Exe-ExeName Hymnal Browser Lite
;@Ahk2Exe-SetMainIcon res/app_icon.ico
;@Ahk2Exe-SetCompanyName MSDAC Systems
;@Ahk2Exe-SetCopyright (c) 2022 MSDAC Systems`, Verdadero`, Ycong
;@Ahk2Exe-SetDescription Hymnal Browser Lite
;@Ahk2Exe-SetFileVersion 0.1.1.0
;@Ahk2Exe-SetInternalName Hymnal Browser Lite
;@Ahk2Exe-SetLanguage 0x3409
;@Ahk2Exe-SetLegalTrademarks (c) 2022 MSDAC Systems
;@Ahk2Exe-SetName Hymnal Browser Lite
;@Ahk2Exe-SetOrigFilename Hymnal Browser Lite
;@Ahk2Exe-SetProductName 0.1.1.0
;@Ahk2Exe-SetVersion 0.1.1.0

/* AHK Settings */
A_MaxHotkeysPerInterval := 5000
Thread("Interrupt", 0)

Misc.HookReloadScript(1)                                                                    ;; NOTE: REMOVE OR COMMENT BEFORE COMPILING
System.Exec()
