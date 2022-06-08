/*
    Software
    ---------
    Manifest file about the Hymnal Browser Lite.

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
*/

Class Software {
    /*
        Although named as 'Software', the references are aliased to 'SW'.
    */

    /*  Core metadata */
    static PARENT := "MSDAC Systems"
    static COPYRIGHT := "© 2022 MSDAC Systems"
    static AUTHORS := ["Ken Verdadero", "Reynald Ycong"]
    static NAME := "Hymnal Browser Lite"
    static TITLE := this.NAME
    static PARENT_NAME := this.PARENT ' ' this.NAME
    static EXE_NAME := "Hymnal Browser Lite.exe"
    static VERSION := "0.2.0.0"
    static VERSION_LABEL := "Beta"
    static VERSION_STRING := Format("v{1} {2}",
        Join(ArrayTrunc(StrSplit(this.VERSION, '.'), 1, 3), '.'), this.VERSION_LABEL
    )
    static NAME_VERSION := Format("{1} v{2}", this.NAME, this.VERSION)
    static FULLNAME_VERSION := Format("{1} {2} v{3}", this.PARENT, this.NAME, this.VERSION)
    static FULLNAME_VERSION_LABEL := Format(
        "{1} {2} v{3} {4}",
        this.PARENT, this.NAME, this.VERSION, this.VERSION_LABEL
    )
    
    /*  Directories */
    static DIR_PARENT := PathJoin(A_AppDataCommon, this.PARENT)
    static DIR_PROGRAM := PathJoin(this.DIR_PARENT, this.NAME)
    static DIR_DOCS_PARENT := PathJoin(A_MyDocuments, this.PARENT)
    static DIR_DOCS_PROGRAM := PathJoin(this.DIR_DOCS_PARENT, this.NAME)
    static DIR_TEMP := PathJoin(this.DIR_PROGRAM, "temp")
    static DIRS_HYMNAL_PACKAGE := [A_ScriptDir, this.DIR_PROGRAM, this.DIR_DOCS_PROGRAM]    ;; Scope of directories to be scanned for HymnalDB; In order of priority
    
    /*  Individual Files */
    static FILE_ICON := "res\app_icon.ico"
    static FILE_CONFIG := PathJoin(this.DIR_PROGRAM, "settings.cfg")
    static FILE_HYMNALDB := PathJoin(this.DIR_PROGRAM, "hymns.sda")
    static FILE_POWERPOINT := ''                                                            ;; Placeholder; to be filled by System.VerifyRequisites.
    static FILE_PRESENTER := ''                                                             ;; Placeholder; to be filled by System.VerifyRequisites.
    static FILE_LOG := (
        (A_IsCompiled ? PathJoin(this.DIR_PROGRAM, "app.log"):
        PathJoin(A_ScriptDir, "dev.log"))
    )
    
    /*  Application settings */
    static LOG_CLEAR_OLD := true
    static ERROR_HANDLING := true                                                           ;; Defines how errors are handled; 0 - by default, 1 - by the software
    static CPLTR_LIS_RATE := 50                                                             ;; Time interval of completer thread before updating the indexes
    static CPLTR_MAX_ITEMS := 6                                                             ;; Max number of items that are allowed to fit in ListBox (search completer)
    
    /*  GUI Settings */
    static SIZE := [300, 85]                                                                ;; Main GUI Size (W,H)
    static GLB_FONT_SIZE := 9                                                               ;; Global font size
    static GLB_FONT_NAME := "Segoe UI"                                                      ;; Global font name
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
        return meta
    }
}