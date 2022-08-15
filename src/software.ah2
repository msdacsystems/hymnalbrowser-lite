/*
    Software
    ---------
    Manifest file about the Hymnal Browser Lite.

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
*/

class SW extends Software {                                                                 ;; This is a shorter class name of Software. Made for aliasing purposes
}

Class Software {
    /*  Core metadata */
    static PARENT := "MSDAC Systems"
    static AUTHORS := ["Ken Verdadero", "Reynald Ycong"]
    static NAME := "Hymnal Browser Lite"
    static TITLE := this.NAME
    static COPYRIGHT := "© 2022 MSDAC Systems"
    static COPYRIGHT_NAME := this.NAME " © 2022 MSDAC Systems"
    static PARENT_NAME := this.PARENT ' ' this.NAME
    static EXE_NAME := this.NAME '.exe'
    static VERSION := __VERSION
    static VERSION_SHORT := 'v' Join(ArrayTrunc(StrSplit(this.VERSION, '.'), 1, 3), '.')
    static VERSION_LABEL := "Beta"
    static VERSION_STRING := Format("v{1} {2}",
        Join(ArrayTrunc(StrSplit(this.VERSION, '.'), 1, 3), '.'), this.VERSION_LABEL
    )
    static VERSION_TAG := Format("v{1}{2}",
        this.VERSION, (this.VERSION_LABEL != "Release" ? '-' StrLower(this.VERSION_LABEL):''))
    static NAME_VERSION := Format("{1} v{2}", this.NAME, this.VERSION)
    static FULLNAME_VERSION := Format("{1} {2} v{3}", this.PARENT, this.NAME, this.VERSION)
    static FULLNAME_VERSION_LABEL := Format(
        "{1} v{2} {3}",
        this.PARENT_NAME, this.VERSION, this.VERSION_LABEL
    )
    static GITHUB_REPO := 'msdacsystems/hymnalbrowser-lite'

    /*  Directories */
    static DIR_PARENT := PathJoin(A_AppDataCommon, this.PARENT)
    static DIR_PROGRAM := PathJoin(this.DIR_PARENT, this.NAME)
    static DIR_DOCS_PARENT := PathJoin(A_MyDocuments, this.PARENT)
    static DIR_DOCS_PROGRAM := PathJoin(this.DIR_DOCS_PARENT, this.NAME)
    static DIR_TEMP := PathJoin(this.DIR_PROGRAM, "temp")
    static DIRS_HYMNAL_PACKAGE := [A_ScriptDir, this.DIR_PROGRAM, this.DIR_DOCS_PROGRAM]    ;; Scope of directories to be scanned for HymnalDB; In order of priority
    static DIRS := [                                                                           ;; Parent folders must be in forepart of the array
                this.DIR_PARENT,
                this.DIR_DOCS_PARENT,
                this.DIR_PROGRAM,
                this.DIR_DOCS_PROGRAM,
                ; SW.DIR_TEMP,                                                                  ;; Not necessarily needed
    ]
    
    /*  Individual Files */
    static BIN_ZIP := A_IsCompiled ? PathJoin(A_Temp, '7z.exe'): 'bin\7z.exe'               ;; Binary file of 7z
    static FILE_ZIPDLL := (A_IsCompiled ? PathJoin(A_Temp, '7z.dll'):'bin\7z.dll')
    static FILE_ENV := (A_IsCompiled ? PathJoin(A_Temp, 'secrets.env'):'secrets.env')
    static FILE_PKG_UPT := (A_IsCompiled ? PathJoin(A_Temp, 'Hymnal Browser Lite Updater.exe'):'bin\Hymnal Browser Lite Updater.exe')
    static FILE_ICON := "res\app_icon.ico"
    static FILE_CONFIG := PathJoin(this.DIR_PROGRAM, "settings.cfg")
    static FILE_POWERPOINT := ''                                                            ;; Placeholder; to be filled by System.VerifyRequisites.
    static FILE_PRESENTER := ''                                                             ;; Placeholder; to be filled by System.VerifyRequisites.
    static FILE_LOG := (A_IsCompiled ? PathJoin(this.DIR_PROGRAM, "app.log"):"dev.log")
    
    /*  Application settings */
    static LOG_MAX_LINES := 1000                                                            ;; Maximum lines allowed to be stored in application log
    static ERROR_HANDLING := true                                                           ;; Defines how errors are handled; 0 - by default, 1 - by the software
    static CPLTR_LIS_RATE := 50                                                             ;; Time interval of completer thread before updating the indexes
    static CPLTR_MAX_ITEMS := 6                                                             ;; Max number of items that are allowed to fit in ListBox (search completer)
    static BG_REF_RATE := 50                                                                ;; Refresh rate of a standard background thread. This does not affect a custom thread method.
    
    /*  GUI Settings */
    static SIZE := [300, 85]                                                                ;; Main GUI Size (W,H)
    static GLB_FONT_SIZE := 9                                                               ;; Global font size
    static GLB_FONT_NAME := "Segoe UI"                                                      ;; Global font name
    static CL_PRIMARY := "008dc9"
    static CL_SECONDARY := "0079c5"
    static TEXT_DISABLED := "505050"
    static TEXT := "000000"

    static GenerateMetadata() {
        /*
            Generates an object-type of metadata.
            This is forwarded to KLogger.
        */
        meta := Object()
        meta.DefineProp("SOFTWARE", {value: Software.FULLNAME_VERSION_LABEL})
        meta.DefineProp("AUTHORS", {value: Software.AUTHORS})
        meta.DefineProp("DEV_MODE", {value: System.DEV_MODE})
        return meta
    }
}