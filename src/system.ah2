/*
    System class for HBL
    ---------------------
    Handles all process and system management.

    (c) 2022 Ken Verdadero, Reynald Ycong
*/

Class System {
    static WIN_ACTIVE := 0
    static AHK_PID := "ahk_pid " System.GetPID()
    static AHK_EXE := "ahk_exe Hymnal Browser Lite.exe"

    static Exec() {
        /*
            Executes the main program
        */
        global _STARTUP := A_TickCount
        global SW := Software                                                               ;; Software alias
        global VRB := SW.VERBOSE_LOG
        global _LOG := KLogger(SW.FILE_LOG, SW.GenerateMetadata(), SW.LOG_CLEAR_OLD)
        _LOG.SetVerbose(VRB)
        System.Errors.Setup()
        _LOG.Info("Application has started" (A_IsAdmin ? " in Administrator mode":''))
        _LOG.Info(
            Format("System Info: Windows {1} {2}; User: {3} {4}",
            A_OSVersion, GetOSBit(1), A_ComputerName, A_UserName)
        )
        _LOG.Info(!A_IsCompiled ? "APPLICATION IS RUNNING ON DEVELOPER MODE":'')
        _LOG.Info("Process ID: " System.GetPID())
        _LOG.Info("Verbose logging is " (VRB ? 'ON':'OFF'))
        _LOG.Info("Initializing core")
        System.VerifyDirectories()
        Config.Setup()
        global HYMNAL := HymnalDB.ScanHymnal()
        UI.Setup()
        BackgroundThread.Setup()
        global SES := Session.Setup()
        
        _LOG.Info(Format("Initialization completed in {1} s.", 
            Round((A_TickCount-_STARTUP)/1000, 3)
            ))
        UI.MAIN.GUI.show()

    }

    static VerifyDirectories() {
        /* 
            Checks every directory. Creates new one if not present.
        */
        MISSING := 0
        RESOLVED := 0
        DIRS := [
            SW.DIR_PARENT,
            SW.DIR_PROGRAM,
            ; SW.DIR_TEMP,                                                                  ;; Not necessarily needed
        ]
        
        for dir in DIRS {
            if !IsFolderExists(dir) {
                MISSING++
                _LOG.Warn(Format("System: Directory '{1}' was not found. "
                "Creating new one.", dir))
                try DirCreate(dir)
                RESOLVED++
            }
        }

        if MISSING {
            _LOG.Info(Format("System: {1} item(s) were missing; resolved {2} of {3}.",
                            MISSING, RESOLVED, MISSING))
        } else {
            _LOG.Info("System: Directory verification sucessfully.")
        }

    }

    static CloseEvent(exitCode:=0, message:='Application exited due to an error') {
        /* When the user closed the software */
        RT := Round((A_TickCount-_STARTUP)/1000, 3)                                         ;; Running time of the software
        if !exitCode or exitCode == 2 {
            _LOG.info("System: The user has closed the program")
            _LOG.info("System: Application exited. Running time: " RT " second(s)")
        } else {
            _LOG.error(Format(
                "System: Exit code {1}; Reason: {2}; Running time: {3} second(s)",
                exitCode, message, RT)
            )
        }
        _LOG.Close()
        ExitApp(exitCode)
    }

    static GetPID() {
        return DllCall("GetCurrentProcessId")
    }

    static SetActive() {
        WinActivate(System.AHK_PID)
    }
    static IsActive() {
        return (WinActive(System.AHK_PID)? 1:0)
    }
    static IsFocused() {
        MouseGetPos(&X, &Y, &W, &C)
        return (WinExist(System.AHK_PID) == W ? 1:0)
    }
    static MoveMain() {
        /*
            Allows the window to be moved.
            This is triggered by the title control object
        */
        try PostMessage(0xA1, 2,,, System.AHK_PID)
    }

    
    class Errors {
        /*
            System error class handler

            Errors:
                - HymnsDB
        */
        static Setup() {
            /*  Sets up the error binding to log */
            OnError(ObjBindMethod(System.Errors, "BaseError"))
        }
        static BaseError(exception, mode) {
            _LOG.Crit(Format('Errors: ' exception.Message))
            System.Errors.Notify(
                "The application has encountered an error and needs to terminate."
                " See " PathSplit(SW.FILE_LOG)[2] " for details."
            )
            System.CloseEvent(13)
        }
        static Notify(message, tray:=false) {
            /* Notifies the user about the error */
            MsgBox("Error: " message, SW.NAME, "Icon! 0x40000")
        }
        static HymnsDB(errorType) {
            if errorType == "AbsentFile" {
                System.Errors.Notify(
                    "Hymnal database cannot be found.`n"
                    "Please contact the developers."
                )
                System.CloseEvent(1, "Hymnal database cannot be found.")
            }
        }
    }

    class FileManagement {
        /*
            Covers file control for the application
        */

        static RemoveTempSubdirs(args*) {
            /* Deletes the temp subfolders: EN, TL, US after launching a presentation */
            MAX_TRIES := 13
            SUBDIRS := [
                SW.DIR_TEMP "/EN",
                SW.DIR_TEMP "/TL",
                SW.DIR_TEMP "/US"
            ]
            while (DirExist(SUBDIRS[1]) or DirExist(SUBDIRS[2]) or DirExist(SUBDIRS[3])) {
                if !MAX_TRIES
                    break
                Sleep(10)
                _LOG.Verbose("System: Deleting temp subfolders (Tries: " 14-MAX_TRIES ")")
                for dir in SUBDIRS {
                    try DirDelete(dir, 1)
                }
                MAX_TRIES--
            }
            _LOG.Verbose("System: Temp subfolders were successfully deleted.")
        }

        static GetTempAttrib() {
            /*
                Returns two arrays that has data.

                FN - Filenames
                TM - Timestamps            
            */
            FN := []
            TM := []
            loop files, PathJoin(SW.DIR_TEMP, "*.pptx") {
                if SubStr(A_LoopFileName, 1, 2) == '~$'                                     ;; Ignore currently opened presentations
                    continue
                FN.Push(A_LoopFileFullPath)
                TM.Push(FileGetTime(A_LoopFileFullPath, "C"))
            }
            OUT := Object()
            OUT.DefineProp("FN", {value: FN})
            OUT.DefineProp("TM", {value: TM})
            return OUT
        }

        static RemoveOldest(args*) {
            /*
                Removes all items that are old by analyzing their creation date.
                Only retains items the size of SW.TEMP_MAX_RECENT.
            */

            while System.FileManagement.GetTempAttrib().FN.Length > SW.TEMP_MAX_RECENT {    ;; Loop until the .pptx files are equal to the max recent temp
                TA := System.FileManagement.GetTempAttrib()
                IDX := ArrayMinIndex(TA.TM)
                try {
                    FileDelete(TA.FN[IDX])                                                  ;; Delete the oldest file from array using ArrayMinIndex
                    _LOG.Verbose(
                        Format("System: Deleted older temp file `"{1}`"", TA.FN[IDX])
                    )
                    TA.FN.RemoveAt(IDX)
                }
            }
        }
    }
}