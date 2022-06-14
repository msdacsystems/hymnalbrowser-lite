/*
    Errors
    -------
    System error class handler.

    Error list:
        - BaseError
        - HymnsDB

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-04
*/

class Errors {
    static Setup() {
        /*  Sets up the error binding to log instead of system message box */
        (SW.ERROR_HANDLING ? OnError(ObjBindMethod(this, "BaseError")):0)
    }
    static BaseError(exc, mode) {
        System.STATE_CRASH := true                                                          ;; Initiate system crash
        _LOG.Crit(Format(
            "Errors: {1} | {2}.{3} {4} {5}",
            exc.Message, StrUpper(SplitExt(PathSplit(exc.File)[-1])[1]), exc.Line,
            exc.What, exc.Extra)
        )
        try UI.Hide()
        Errors.Notify(
            "The application has encountered an error and needs to terminate."
            " See " PathSplit(SW.FILE_LOG)[2] " for details."
        )
        try FileManagement.CloseTemp()
        Events.SystemExit(13)
    }

    static Notify(message, tray:=false) {
        /* Notifies the user about the error */
        MsgBox("Error: " message, SW.NAME, "Icon! 0x40000")
    }

    static HymnsDB(errorType) {
        switch errorType {
            case "AbsentPackage":
                Errors.Notify(
                    "Hymnal package '" CF.HYMNAL.PACKAGE "' cannot be found.`n"
                    "Reinstalling the app may fix the problem."
                )
                System.CloseEvent(1, "Hymnal database cannot be found.")
        }
    }

    static Launcher(errorType) {
        switch errorType {
            case "AbsentBinary":
                Errors.Notify(
                    Format("Cannot present {1} due to extraction failure.", SES.CURR_HYMN)
                )
                Events.SystemExit(3, "7z Binary cannot be found in " SW.BIN_ZIP)
        }
    }
}