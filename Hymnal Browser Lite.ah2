/*
    -------------------------------------
    * MSDAC Systems Hymnal Browser Lite *
    -------------------------------------
    A general hymn browser for Seventh-day Adventist Church, lightweight version.

    * This file is the main executable file to run the whole application.

    Coding style:
        - Classes, Functions, and Methods are in PascalCase
        - Parameters, External Class names are in camelCase
        - If statement expressions do not contain parentheses unless required
        - Code ruler is 90 units
        - Variable naming has type-value in which the type of the variable should precede
        the actual name of the variable (e.g: TYPE_NAME_NAME -> DIR_DOCS_PROGRAM)

    Code dependencies:
        - AHK2ExtLib (https://github.com/verdaderoken/AHK2ExtLib)
        - KConfig

    Prerequisites:
        - Hymnal Database (.sda) file
        - Microsoft Office PowerPoint or any .pptx-compatible software.
    
    Known issues:
        - None so far.    
    
    Limitations:
        - Since this application is written in AHKv2, interface design is limited
        to what's available resources.
        - Although efforts have been made to maximize user interface, the primary
        goal is focused towards better functionality and reliability.

    * ------------------------------- Code architecture -------------------------------- *

    Notes:
        - Classes are broken down into different files to keep the code organized
        and maintainable.


    -------------------------------------------------------------------------------------
    (c) 2022 MSDAC Systems

    Authors:
        Ken Verdadero - @verdaderoken, Github
        Reynald Ycong - @4raiven, Github
    
    Written in AutoHotKey v2 Beta 4

    Orig. 2022-04-22 prototype
    Rev 1. 2022-06-03 restructuring classes
    Rev 2. 2022-06-06 initial build
    Rev 3. 2022-06-10 updated to AHKv2 Beta 4
*/

__VERSION := "0.2.3.0"

/* AHK Settings */
#SingleInstance Force                                                                     
#MaxThreads 100
SetTitleMatchMode("RegEx")
A_MaxHotkeysPerInterval := 5000
TraySetIcon(A_IconFile)

/* External libraries */
#Include ..\lib\ext\Basic.ah2
#Include ..\lib\ext\GUIx.ah2
#Include ..\lib\ext\Maps.ah2
#Include ..\lib\ext\Misc.ah2
#Include ..\lib\ext\Object.ah2
#Include ..\lib\ext\Path.ah2
#Include ..\lib\ext\Types.ah2
#Include ..\lib\ext\Window.ah2
#Include ..\lib\Env.ah2
#Include ..\lib\7Zip.ah2
#Include ..\lib\JSON.ah2
#Include ..\lib\KConfig.ah2
#Include ..\lib\KLogger.ah2

/*  External classes */
#Include src\system\system.ah2
#Include src\system\errors.ah2                                                                 ;; Sub class of system
#Include src\system\fileManagement.ah2                                                               
#Include src\system\background.ah2
#Include src\system\events.ah2
#Include src\software.ah2 
#Include src\ui.ah2
#Include src\config.ah2
#Include src\hymnal.ah2
#Include src\launcher.ah2
#Include src\session.ah2

/*  Interface classes */
#Include src\interface\mainmenu.ah2
#Include src\interface\searchbar.ah2
#Include src\interface\buttons.ah2
#Include src\interface\completer.ah2
#Include src\interface\contextMenu.ah2
#Include src\interface\settings.ah2

/*  System Props */
;@Ahk2Exe-ExeName Hymnal Browser Lite
;@Ahk2Exe-SetMainIcon res/app_icon.ico
;@Ahk2Exe-SetCompanyName MSDAC Systems
;@Ahk2Exe-SetCopyright (c) 2022 MSDAC Systems`, Verdadero`, Ycong
;@Ahk2Exe-SetDescription Hymnal Browser Lite
;@Ahk2Exe-SetFileVersion 0.2.3.0
;@Ahk2Exe-SetInternalName Hymnal Browser Lite
;@Ahk2Exe-SetLanguage 0x3409
;@Ahk2Exe-SetLegalTrademarks (c) 2022 MSDAC Systems
;@Ahk2Exe-SetName Hymnal Browser Lite
;@Ahk2Exe-SetOrigFilename Hymnal Browser Lite
;@Ahk2Exe-SetProductName 0.2.3.0
;@Ahk2Exe-SetVersion 0.2.3.0

System.Exec()