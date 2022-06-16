/*
    * System class for HBL
    ---------------------
    Main System class. Handles all process and system management.

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
*/

class System {
    static DEV_MODE := false
    static STATE_CRASH := false
    static AHK_ID := ""                                                                     ;; To be set by UI.MAIN.GUI's HWND
    static AHK_PID := "ahk_pid " System.GetPID()
    static AHK_EXE := "ahk_exe " SW.EXE_NAME
    static AHK_TITLE := "^Hymnal Browser Lite$"

    static Exec() {
        /*
            Executes the main program
        */
        global _STARTUP := A_TickCount
        System.CheckDevMode()
        global _LOG := KLogger(SW.FILE_LOG, SW.GenerateMetadata())
        global CF := Config()

        /*  Log system launch */
        _LOG.SetVerbose(System.DEV_MODE ? 1:CF.MAIN.VERBOSE_LOG)
        _LOG.SetMaxLines(SW.LOG_MAX_LINES)
        _LOG.Info("Application has started" (A_IsAdmin ? " in Administrator mode":''))
        _LOG.Info(
            Format("System Info: Windows {1} {2}; User: {3} {4}",
            A_OSVersion, GetOSBit(1), A_ComputerName, A_UserName)
        )
        _LOG.Info(System.DEV_MODE ? "APPLICATION IS RUNNING ON DEVELOPER MODE":'')
        _LOG.Info("System: Process ID: " System.GetPID())
        _LOG.Info("System: Verbose logging is " (CF.MAIN.VERBOSE_LOG ? 'ON':'OFF'))
        _LOG.Info("System: Initializing core")

        A_TrayMenu.Delete()                                                                 ;; Remove items in tray menu
        A_TrayMenu.Add("Exit", Events.System.Exit)

        Errors.Setup()
        System.VerifyDirectories(false)
        System.VerifyRequisites()
        global ENV := Environments.Load(SW.FILE_ENV, !System.DEV_MODE)                      ;; Load and delete the environment file after loading
        global HYMNAL := HymnalDB.ScanHymnal()                                              ;; Contains map of hymnal data
        global SES := Session.Setup()
        UI.Setup()                                                                          ;; Initiate User Interface setup
        BackgroundThread.Setup()
        _LOG.DumpPostponedLogs()                                                           ;; Releases all deferred logs that wasn't supposed to dump early
        
        UI.Show(CF.WINDOW.XPOS, CF.WINDOW.YPOS)                                             ;; Show at last saved coordinates

        _LOG.Info(Format("Initialization completed. ({1} ms)", Round(A_TickCount-_STARTUP)))
        global _RUNTIME := A_TickCount
    }

    static VerifyDirectories(postponeLog:=0) {
        /* 
            Checks every directory. Creates new one if not present.
        */
        MISSING := 0
        RESOLVED := 0
        
        for dir in SW.DIRS {
            if !IsFolderExists(dir) {
                MISSING++
                _LOG.Warn(Format(
                    "System: Directory '{1}' was not found. "
                    "Creating new one.", dir), postponeLog
                )
                try DirCreate(dir)
                catch Error as e {
                    _LOG.Error("System: Cannot create the directory: " dir, postponeLog)
                    continue
                }
                RESOLVED++
            }
        }

        if MISSING {
            _LOG.Info(Format(
                "System: {1} item(s) were missing; resolved {2} of {3}.",
                MISSING, RESOLVED, MISSING),
                postponeLog
            )
        } else {
            _LOG.Info("System: Directory verification sucessfully.", postponeLog)
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
            _LOG.Info("System: Presenter type setting will be ignored")
        }
    }

    static CheckDevMode() {
        /*
            Modifies system whenever the application detected a dev mode.
        */
        System.DEV_MODE := (!A_IsCompiled ? 1:0)

        switch System.DEV_MODE {
            case 0:
                FileInstall("bin\7z.exe", A_Temp "\7z.exe", true)
                FileInstall("bin\7z.dll", A_Temp "\7z.dll", true)
                FileInstall("secrets.env", A_Temp "\secrets.env", true)
            case 1:
                Misc.HookReloadScript(1,, Events.System.Reload)
        }
    }

    static GetPID() => DllCall("GetCurrentProcessId")
    static GetWinMonitor() =>  Window.GetCurrentMonitor(System.AHK_PID)
    static IsActive() => WinActive(System.AHK_PID)? 1:0
    static HasCrashed() => System.STATE_CRASH
    static IsOnModal() => WinActive("ahk_class #32770")? 1:0
    static SetActive() {
        WinActivate(System.AHK_ID)
        UI.ACTIVE := true
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