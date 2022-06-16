/*
    Presentation Launcher for HBL
    ----------------------------
    Extracts the presentation from the database and launches the file.

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-06
*/


Class Launcher {
    static Launch() {
        /*
            Extracts the target file from the database and launches them.
        */
        ST := A_TickCount
        UI.BTN.LaunchSetMode("Launching")
        
        (!IsFolderExists(SW.DIR_TEMP) ? DirCreate(SW.DIR_TEMP):0)                           ;; Check for temp directory
        
        System.SetActive()                                                                  ;; Weird. Prevents windows sound from playing when a hotkey (Return/Enter) was pressed.
        try {
            RESULT := HYMN_ZIP.Extract(SES.HYMN_PATH, SW.DIR_TEMP)
        } catch Error as e {
            switch e.Extra {
                case 'Binary': Errors.Launcher("AbsentBinary")                              ;; Call system error if the binary is missing
                case 'Library': Errors.Launcher("AbsentLibrary")                            ;; Call system error if the 7z library is missing
                default: Errors.BaseError(e)
            }
            return
        }

        if RESULT {
            _LOG.Verbose(
                'Launcher: Hymn "' SES.FILENAME
                '" already exists in temp folder'
            )
        }
        
        SetTimer(ObjBindMethod(FileManagement, "RemoveTempSubdirs"), -2000)
        SetTimer(ObjBindMethod(FileManagement, "RemoveOldest"), -3000)

        if !FileExist(PathJoin(SW.DIR_TEMP, SES.FILENAME)) {                                ;; If the extracted file was not found, notify the user about the error
            _LOG.Error("Extracted file cannot be found")
            Errors.Notify(Format(
                "'{1}' was not found.`n"
                "Restarting the application may fix the problem.", SES.CURR_HYMN)
            )
            return
        }

        try {
            if SW.FILE_PRESENTER {
                Run(Format('{1} {2} "{3}"',                                                 ;; Run the actual presentation file
                    SW.FILE_POWERPOINT,                                                     ;; MS Office PowerPoint exe
                    (!CF.LAUNCH.TYPE ? '/C':'/S'),                                          ;; C - Open, S - Start in slideshow (Only works in powerpoint; made for powerpoint); Default is '/C'
                    PathJoin(SW.DIR_TEMP, SES.FILENAME))                                            
                )
            } else {
                _LOG.Verbose("Launcher: Running presentation without PowerPoint")
                Run(PathJoin(SW.DIR_TEMP, SES.FILENAME))                                    ;; Run the file despite of PowerPoint's absence. If the .pptx's association is unset, the 'Open With' dialog with likely to show up
            }

            _LOG.Info(Format('Launcher: Launched Hymn "{1} {2}" ({3} ms)',
                    SES.CURR_NUM, SES.CURR_TTL, Round(A_TickCount-ST))
            )
            SES.COUNT_LAUNCH += 1
            
            if CF.LAUNCH.FOCUS_BACK {                                                       ;; Focus back to main window if configuration is set to true, also selects all the text
                UI.SetActive()
                System.SetActive()
            }
        } catch Error as e {
            _LOG.Error("Launcher: Error occured while launching Hymn #"
                        SES.CURR_NUM "; " e.Message)
        }

    }
}