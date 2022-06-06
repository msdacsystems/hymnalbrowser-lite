/*
    Software
    ---------
    Metadata about the Hymnal Browser Lite

    (c) 2022 Ken Verdadero, Reynald Ycong
*/

Class Software {
    /*
        Although named as 'Software', the references are aliased to 'SW'.
    */
    static PARENT := "MSDAC Systems"
    static COPYRIGHT := "© 2022 MSDAC Systems"
    static AUTHORS := ["Ken Verdadero", "Reynald Ycong"]
    static NAME := "Hymnal Browser Lite"
    static EXE_NAME := "Hymnal Browser Lite.exe"
    static VERSION := "0.1.1.0"
    static VERSION_LABEL := "Alpha"
    static VERSION_STRING := ('v' Join(ArrayTrunc(StrSplit(this.VERSION, '.'), 1, 3), '.')
                            ' ' this.VERSION_LABEL)
    static NAME_VERSION := this.NAME " v" this.VERSION
    static FULLNAME_VERSION := this.PARENT " " this.NAME " v" this.VERSION
    static FULLNAME_VERSION_LABEL := this.PARENT " " this.NAME " v" this.VERSION " " this.VERSION_LABEL
    static TITLE := this.NAME
    static SIZE := [300, 85]                                                                ;; Main GUI Size (W,H)
    static FILE_ICON := "res\app_icon.ico"
    static FILE_BG := "res\bg.png"
    static VERBOSE_LOG := true                                                              ;; Extra details when logging

    static DIR_PARENT := PathJoin(A_AppDataCommon, this.PARENT)
    static DIR_PROGRAM := PathJoin(this.DIR_PARENT, this.NAME)
    static DIR_TEMP := PathJoin(this.DIR_PROGRAM, "temp")
    static FILE_CONFIG := PathJoin(this.DIR_PROGRAM, "settings.cfg")
    static FILE_LOG := (
        (A_IsCompiled ? PathJoin(this.DIR_PROGRAM, "app.log"):
                        PathJoin(A_ScriptDir, "dev.log"))
    )
    static FILE_HYMNALDB := PathJoin(this.DIR_PROGRAM, "hymns.sda")
    static LOG_CLEAR_OLD := true

    static TEMP_MAX_RECENT := 10

    static GLB_FONT_SIZE := 9                                                               ;; Global font size
    static GLB_FONT_NAME := "Segoe UI"                                                      ;; Global font name
    static TEXT_DISABLED := "505050"
    static TEXT := "000000"

    static CPLTR_LIS_RATE := 20                                                             ;; Time interval of completer thread before updating the indexes
    static CPLTR_MAX_ITEMS := 6                                                             ;; Max number of items that are allowed to fit in ListBox (search completer)

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