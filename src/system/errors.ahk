/*
    Errors
    -------
    System error class handler.

    Error list:
        - BaseError
        - HymnsDB
        - Launcher

    (c) 2022 MSDAC Systems
    Author: Ken Verdadero
    Written 2022-06-04
*/

class Errors {
    static Setup() {
        /*  Sets up the error binding to log instead of system message box */
        (SW.ERROR_HANDLING ? OnError(ObjBindMethod(this, "BaseError")) : 0)
    }
    static BaseError(exc, mode := '') {
        System.STATE_CRASH := true                                                          ;; Initiate system crash
        _LOG.Crit(Format(
            "Errors: {1} ` {2}.{3} {4} {5}",
            exc.Message, StrUpper(SplitExt(PathSplit(exc.File)[-1])[1]), exc.Line,
            exc.What, exc.Extra)
        )
        try UI.Hide()
        Errors.Notify(
            "The application has encountered an error and needs to terminate."
            " See " PathSplit(SW.FILE_LOG)[2] " for details."
        )
        try FileManagement.CloseTemp()
        Events.System.Exit(13)
    }

    static Notify(message, tray := false, timeout := 0, mode := "Error") {
        /* Notifies the user about the error or warning */
        if (mode = "Warning") {
            MsgBox("Warning: " message, SW.NAME, "Icon! 0x30 T" timeout)  ;; Warning icon
        } else {
            MsgBox("Error: " message, SW.NAME, "Icon! 0x40000 T" timeout) ;; Error icon
        }
    }

    static Alert(message, title := SW.NAME, timeout := 0) {
        /*  Prompts the user with an alert message box */
        return MsgBox(message, title, "Icon! 0x40000 T" timeout)
    }

    static PromptYesNo(message, title := SW.NAME, timeout := 0) {
        /*  Prompts the user with a Yes/No message box */
        return MsgBox(message, title, "Icon! 0x40024 T" timeout)
    }

    static HymnsDB(errorType) {
        switch errorType {
            case "AbsentPackage":
                Errors.Notify(
                    "Hymnal package '" CF.HYMNAL.PACKAGE "' cannot be found.`n"
                    "Reinstalling the app may fix the problem."
                )
                Events.System.Exit(1, "Hymnal database cannot be found.")
        }
    }

    static Launcher(errorType) {
        switch errorType {
            case "AbsentBinary":                                                            ;; 7z.exe was not found
                Errors.Notify(
                    Format(
                        "Cannot present '{1}' due to extraction failure.`n"
                        "The application will restart now.", SES.CURR_HYMN
                    ), , 3
                )
                _LOG.Error(Format('7z Binary cannot be found in "{1}"', SW.BIN_ZIP))
                Events.System.Reload()
            case "AbsentLibrary":                                                           ;; 7z.dll was not found
                Errors.Notify(
                    "Internal library was corrupted.`n"
                    "The application will restart now.", , 3
                )
                _LOG.Error(Format('7z Library cannot be found in "{1}"', SW.FILE_ZIPDLL))
                Events.System.Reload()
        }
    }

    static Stats(errorType, message := "") {
        switch errorType {
            case "Corrupted":
                _LOG.Error("Stats: Corrupted stats file: " . message)

                choice := Errors.PromptYesNo(
                    "There was an error loading hymnal statistics. Continue anyway?`n",
                    SW.NAME
                )
                _LOG.Debug(choice)

                if choice == "Yes" {
                    Stats.CleanStatsFile()
                    Errors.Alert(
                        "The application will restart now."
                    )
                    Events.System.Reload()
                    return
                }
                Errors.Alert(
                    "Backup your stats file and reinstall the app.`nClick OK to open the stats folder.`nThe application will now exit.",
                )
                OpenFolder(SW.FILE_STATS)
                Events.System.Exit(1, "Corrupted stats file.")

            case "CleanupFailed":
                _LOG.Error("Stats: Failed to delete stats file: " . message)
                Errors.Notify("There was an error deleting the stats file, please delete it manually.")
        }
    }
}