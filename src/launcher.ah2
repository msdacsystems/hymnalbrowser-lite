/*
    Presentation Launcher for HBL
    ----------------------------
    Extracts the presentation from the database and launches the file.

    (c) 2022 Ken Verdadero, Reynald Ycong
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
        ZIP := TarZip(SW.FILE_HYMNALDB)
        ZIP.Extract(SES.HYMN_PATH, SW.DIR_TEMP)
        
        try {
            FileMove(PathJoin(SW.DIR_TEMP, SES.HYMN_PATH), SW.DIR_TEMP)
        } catch Error {
            _LOG.Verbose('"' SES.FILENAME "`" already exists in temp folder")
        }
        
        SetTimer(ObjBindMethod(System.FileManagement, "RemoveTempSubdirs"), -2000)
        SetTimer(ObjBindMethod(System.FileManagement, "RemoveOldest"), -3000)
        Run(PathJoin(SW.DIR_TEMP, SES.FILENAME))                                            ;; Run the actual presentation file

        _LOG.Info(Format("Launcher: Launched Hymn #{1} {2} ({3} ms)",
                SES.CURR_NUM, SES.CURR_TTL, Round(A_TickCount-ST)))
        Sleep(500)                                                                          ;; Time allowance before concluding the launch
        UI.BTN.LaunchSetMode("Launched")
    }
}