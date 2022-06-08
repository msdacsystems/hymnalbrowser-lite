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
            Extracts the target file from the database and launches them
        */
        ST := A_TickCount
        UI.BTN.LaunchSetMode("Launching")
        
        (!IsFolderExists(SW.DIR_TEMP) ? DirCreate(SW.DIR_TEMP):0)                           ;; Check for temp directory
        
        System.SetActive()                                                                  ;; Weird. Prevents windows sound from playing when a hotkey (Return/Enter) was pressed.
        ZIP := TarZip(CF.__FILE_HYMNALDB)
        ZIP.Extract(SES.HYMN_PATH, SW.DIR_TEMP)
        
        try {
            FileMove(PathJoin(SW.DIR_TEMP, SES.HYMN_PATH), SW.DIR_TEMP)
        } catch Error {
            _LOG.Verbose('"' SES.FILENAME "`" already exists in temp folder")
        }
        
        SetTimer(ObjBindMethod(System.FileManagement, "RemoveTempSubdirs"), -2000)
        SetTimer(ObjBindMethod(System.FileManagement, "RemoveOldest"), -3000)

        try {
            if !SW.FILE_PRESENTER {
                _LOG.Verbose("Launcher: Running presentation without PowerPoint")
                Run(PathJoin(SW.DIR_TEMP, SES.FILENAME))                                    ;; Run the file despite of PowerPoint's absence
            } else {
                Run(Format('{1} {2} "{3}"',                                                 ;; Run the actual presentation file
                    SW.FILE_POWERPOINT,                                                     ;; MS Office PowerPoint exe
                    (!CF.LAUNCH.TYPE ? '/C':'/S'),                                          ;; C - Open, S - Start in slideshow (Only works in powerpoint; made for powerpoint); Default is '/C'
                    PathJoin(SW.DIR_TEMP, SES.FILENAME))                                            
                )
            }
            _LOG.Info(Format("Launcher: Launched Hymn #{1} `"{2}`" ({3} ms)",
                    SES.CURR_NUM, SES.CURR_TTL, Round(A_TickCount-ST)))
            
            SES.LAUNCH_COUNT += 1
                    
            (CF.LAUNCH.FOCUS_BACK ? System.SetActive():0)                                   ;; Focus back to main window if configuration is set to true, also selects all the text
        } catch Error as e {
            _LOG.Error("Launcher: Error occured while launching Hymn #"
                        SES.CURR_NUM "; " e.Message)
        }

    }
}