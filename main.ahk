/*
    -------------------------------------
    * MSDAC Systems Hymnal Browser Lite *
    -------------------------------------
    A hymn browser and launcher for Seventh-day Adventist Church, lightweight version.

    * This file is the main executable file to run the whole application.

    Coding Guidelines:
        - Use PascalCase for Classes, Functions, and Methods.
        - Use camelCase for Parameters and External Class names.
        - Avoid parentheses in `if` statement expressions unless necessary.
        - Maintain a code ruler width of 90 characters for readability.
        - Follow a type-prefix naming convention for variables, where the type of the variable
          precedes its name (e.g., TYPE_NAME_NAME -> DIR_Docs_Program).

    The rest of documentation can be found in DOCUMENTATION.md

    -------------------------------------------------------------------------------------
    (c) 2022-2025 MSDAC Systems

    Authors:
        Ken Verdadero - @verdaderoken, Github
        Reynald Ycong - @4raiven, Github

    Written in AutoHotKey v2 Beta 4

    Rev 3. 2022-06-10 updated to AHKv2 Beta 4
    Rev 2. 2022-06-06 initial build
    Rev 1. 2022-06-03 restructuring classes
    Original 2022-04-22 prototype
*/

__VERSION := "0.4.1"

/* AHK Settings */
#SingleInstance Force
#MaxThreads 100
SetTitleMatchMode("RegEx")
A_MaxHotkeysPerInterval := 5000
try TraySetIcon("res/app_icon.ico")

/* External libraries */
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/Basic.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/GUIx.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/Maps.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/Misc.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/Object.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/Path.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/Types.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/ext/Window.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/Env.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/JSON.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/7Zip.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/KConfig.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/KLogger.ah2
#Include %A_MyDocuments%/AutoHotkey/Lib/GitHub.ah2

/*  External classes */
#Include src/software.ahk
#Include src/system/system.ahk
#Include src/system/errors.ahk
#Include src/system/fileManagement.ahk
#Include src/system/background.ahk
#Include src/system/events.ahk
#Include src/system/updater.ahk
#Include src/system/utils.ahk
#Include src/ui.ahk
#Include src/config.ahk
#Include src/hymnal.ahk
#Include src/launcher.ahk
#Include src/session.ahk
#Include src/stats.ahk

/*  Interface classes */
#Include src/interface/mainmenu.ahk
#Include src/interface/searchbar.ahk
#Include src/interface/buttons.ahk
#Include src/interface/completer.ahk
#Include src/interface/contextMenu.ahk
#Include src/interface/settings.ahk

/*  System Props */
;@Ahk2Exe-ExeName Hymnal Browser Lite
;@Ahk2Exe-SetName Hymnal Browser Lite
;@Ahk2Exe-SetDescription Hymnal Browser Lite
;@Ahk2Exe-SetInternalName Hymnal Browser Lite
;@Ahk2Exe-SetOrigFilename Hymnal Browser Lite
;@Ahk2Exe-SetProductName Hymnal Browser Lite
;@Ahk2Exe-SetCompanyName MSDAC Systems
;@Ahk2Exe-SetCopyright (c) 2024 MSDAC Systems`, Verdadero`, Ycong
;@Ahk2Exe-SetLegalTrademarks (c) 2024 MSDAC Systems
;@Ahk2Exe-SetMainIcon res/app_icon.ico
;@Ahk2Exe-SetFileVersion 0.3.3
;@Ahk2Exe-SetLanguage 0x3409
;@Ahk2Exe-SetVersion 0.3.3

System.Exec()