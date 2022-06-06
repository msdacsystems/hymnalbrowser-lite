/*
    Presentation Launcher for HBL
    ----------------------------
    Extracts the presentation from the database and launches the file.

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-06
*/


Class Launcher {
    static Launch() {
        ST := A_TickCount
        UI.BTN.LaunchSetEnabled(0)
        UI.BTN.LAUNCH.Text := "Launching"
        
        System.VerifyDirectories()
        System.SetActive()                                                                  ;; Weird. Prevents windows sound from playing when a hotkey (Return/Enter) was pressed.
        ZIP := TarZip(SW.FILE_HYMNALDB)
        ZIP.Extract(SES.HYMN_PATH, SW.DIR_TEMP)
        
        try {
            FileMove(PathJoin(SW.DIR_TEMP, SES.HYMN_PATH), SW.DIR_TEMP)
        } catch Error {
            (SW.VERBOSE_LOG ? _LOG.Verbose('"' SES.FILENAME "`" already exists in temp folder"):0)
        }
        
        SetTimer(ObjBindMethod(System.FileManagement, "RemoveTempSubdirs"), -2000)
        SetTimer(ObjBindMethod(System.FileManagement, "RemoveOldest"), -3000)
        Run(PathJoin(SW.DIR_TEMP, SES.FILENAME))                                            ;; Run the actual presentation file

        _LOG.Info(Format("Launcher: Launched Hymn #{1} {2} ({3} ms)",
                SES.CURR_NUM, SES.CURR_TTL, Round(A_TickCount-ST)))
        UI.BTN.LAUNCH.Text := "Launched"
    }
}