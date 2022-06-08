/*
    System class for HBL
    ---------------------
    Main System class. Handles all process and system management.

    Sub classes:
        - Errors
        - FileManagement
        - BackgroundThread

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
*/

Class System {
    static WIN_ACTIVE := false ;; Maybe unused???
    static STATE_CRASH := false
    static AHK_PID := "ahk_pid " System.GetPID()
    static AHK_EXE := "ahk_exe Hymnal Browser Lite.exe"
    static AHK_TITLE := "^Hymnal Browser Lite$"

    static Errors := Errors                                                                 ;; Binds 'Errors' class within System class
    static FileManagement := FileManagement                                                 ;; Binds 'FileManagement' class within System class
    static Background := BackgroundThread                                                   ;; Binds 'BackgroundThread' class within System class

    static Exec() {
        /*
            Executes the main program
        */
        global _STARTUP := A_TickCount
        global SW := Software                                                               ;; Software alias
        global _LOG := KLogger(SW.FILE_LOG, SW.GenerateMetadata(), SW.LOG_CLEAR_OLD)
        global CF := Config.Setup()
        A_TrayMenu.Delete()
        _LOG.SetVerbose(CF.MAIN.VERBOSE_LOG)
        System.Errors.Setup()
        _LOG.Info("Application has started" (A_IsAdmin ? " in Administrator mode":''))
        _LOG.Info(
            Format("System Info: Windows {1} {2}; User: {3} {4}",
            A_OSVersion, GetOSBit(1), A_ComputerName, A_UserName)
        )
        _LOG.Info(!A_IsCompiled ? "APPLICATION IS RUNNING ON DEVELOPER MODE":'')
        _LOG.Info("System: Process ID: " System.GetPID())
        _LOG.Info("System: Verbose logging is " (CF.MAIN.VERBOSE_LOG ? 'ON':'OFF'))
        _LOG.Info("System: Initializing core")
        System.VerifyDirectories(0)
        System.VerifyRequisites()
        global HYMNAL := HymnalDB.ScanHymnal()
        UI.Setup()
        System.Background.Setup()
        global SES := Session.Setup()
        _LOG.DumpPostphonedLogs()                                                           ;; Releases all deferred logs that wasn't supposed to dump early
        
        UI.Show(CF.WINDOW.XPOS, CF.WINDOW.YPOS)                                             ;; Show at last saved coordinates

        _LOG.Info(Format("Initialization completed in {1} s.", 
            Round((A_TickCount-_STARTUP)/1000, 3)
            ))
        global _RUNTIME := A_TickCount
    }

    static VerifyDirectories(postphoneLog:=0) {
        /* 
            Checks every directory. Creates new one if not present.
        */
        MISSING := 0
        RESOLVED := 0
        DIRS := [                                                                           ;; Parent folders must be in forepart of the array
            SW.DIR_PARENT,
            SW.DIR_DOCS_PARENT,
            SW.DIR_PROGRAM,
            SW.DIR_DOCS_PROGRAM,
            ; SW.DIR_TEMP,                                                                  ;; Not necessarily needed
        ]
        
        for dir in DIRS {
            if !IsFolderExists(dir) {
                MISSING++
                _LOG.Warn(Format("System: Directory '{1}' was not found. "
                "Creating new one.", dir), postphoneLog)
                try DirCreate(dir)
                catch Error as e {
                    _LOG.Error("System: Cannot create the directory: " dir, postphoneLog)
                    continue
                }
                RESOLVED++
            }
        }

        if MISSING {
            _LOG.Info(Format("System: {1} item(s) were missing; resolved {2} of {3}.",
                            MISSING, RESOLVED, MISSING), postphoneLog)
        } else {
            _LOG.Info("System: Directory verification sucessfully.", postphoneLog)
        }

    }

    static VerifyRequisites() {
        /*
            Checks whether a presentation software exists.

            Microsoft Office PowerPoint is the first software to be checked.
            If that fails, the default software that runs '.pptx' files will be executed.
        */
        try {
            SW.FILE_POWERPOINT := RegRead(
                "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows"
                "\CurrentVersion\App Paths\powerpnt.exe", ''
            )
            SW.FILE_PRESENTER := SW.FILE_POWERPOINT
            _LOG.Info(Format(
                "System: Using Microsoft Office {1}-bit from `"{2}`"",
                (InStr(SW.FILE_POWERPOINT, ("x86")) ? "32":"64"),                           ;; Determine if the PowerPoint version is 32-bit or 64-bit
                SW.FILE_POWERPOINT)
            )
        } catch Error {
            SW.FILE_PRESENTER := ''
            _LOG.Warn("System: Microsoft Office PowerPoint is not installed or detected")
            _LOG.Info("System: Presentation files will be executed without PowerPoint")
            _LOG.Info("System: Presentation type setting is disabled")
            ; Errors.Presentation("NotInstalled")                                           ;; Disabled for fallback software tests
        }
    }

    static CloseEvent(exitCode:=0, message:='Application exited due to an error') {
        /* When the user closed the software */
        try RT := Round((A_TickCount-_RUNTIME)/1000, 3)                                     ;; Running time of the software
        catch Error {
            RT := Round((A_TickCount-_STARTUP)/1000, 3)
        }

        FileManagement.CloseTemp()

        try {
            if SES.LAUNCH_COUNT {
                _LOG.Info(
                    Format("System: Launched {1} file(s) at end of session",
                            SES.LAUNCH_COUNT)
                )
            }
        }

        if !exitCode or exitCode == 2 {
            _LOG.info("System: The user has closed the program")
            _LOG.info("System: Application exited. Running time: " RT " second(s)")
        } else {
            _LOG.error(Format(
                "System: Exit code {1}; Reason: {2}; Running time: {3} second(s)",
                exitCode, message, RT)
            )
        }

        _LOG.Close()                                                                        ;; Close the log
        ExitApp(exitCode)
    }

    static GetPID() {
        return DllCall("GetCurrentProcessId")
    }
    static SetActive() {
        WinActivate(WinExist("HBL Completer") ? System.AHK_TITLE: System.AHK_PID)
        UI.ACTIVE := true
    }
    static IsActive() {
        return (WinActive(System.AHK_PID)? 1:0)
    }
    static HasCrashed() {
        return System.STATE_CRASH
    }
    static IsOnModal() {
        return (WinActive("ahk_class #32770")? 1:0)
    }
    static IsFocused() {
        MouseGetPos(&X, &Y, &W, &C)
        if WinExist(System.AHK_PID) && WinExist(System.AHK_TITLE) == W {                    ;; Main window and Completer have the same PID that's why the AHK_TITLE
            return 1                                                                        ;; should confirm if the main window is focused.
        }
        return 0
    }
    static MoveMain() {                                                                     ;; Sends window move message to the application
        try {
            PostMessage(0xA1, 2,,, System.AHK_PID)
        } catch Error as e {
            _LOG.Error("System: Unable to move window. " e.Message)
        }
    }
}