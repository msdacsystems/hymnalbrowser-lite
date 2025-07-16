/**
 * * System class for HBL
 *  ---------------------
 *  Main System class. Handles all process and system management.
 * 
 *  (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 */
class System {
  static DEV_MODE := false
  static STATE_CRASH := false
  static STATE_INITIALIZED := false
  static AHK_ID := ""                                                                     ;; To be set by UI.MAIN.GUI's HWND
  static AHK_PID := "ahk_pid " System.GetPID()
  static AHK_EXE := "ahk_exe " SW.EXE_NAME
  static AHK_TITLE := "^Hymnal Browser Lite$"

  /**
   * Initializes the system.
   * This is where the system starts.
   */
  static Exec() {
    global _STARTUP := A_TickCount
    System.PerformApplicationMode()
    /**
     * @type {KLogger}
     */
    global Console := KLogger(SW.FILE_LOG, SW.GenerateMetadata())
    global CF := Config()

    /*  Log system launch */
    Console.SetVerbose(System.DEV_MODE ? 1 : CF.MAIN.VERBOSE_LOG)
    Console.SetMaxLines(SW.LOG_MAX_LINES)
    Console.SetStdOut(System.DEV_MODE ? 1 : 0)
    Console.Info("Application has started" (A_IsAdmin ? " in Administrator mode" : ''))
    Console.Info("File Location: '" A_ScriptFullPath "'")
    Console.Info(
      Format("System Info: Windows {1} {2}; User: {3} {4}",
        A_OSVersion, GetOSBit(1), A_ComputerName, A_UserName)
    )
    Console.Info(System.DEV_MODE ? "APPLICATION IS RUNNING ON DEVELOPER MODE" : '')
    Console.Info("System: Process ID: " System.GetPID())
    Console.Info("System: Verbose logging is " (System.DEV_MODE ? 'ALWAYS ON (Dev Mode)' : (CF.MAIN.VERBOSE_LOG ? 'ON' : 'OFF')))
    Console.Info("System: Initializing core")

    A_TrayMenu.Delete()                                                                 ;; Remove items in tray menu
    A_TrayMenu.Add("Exit", Events.System.Exit)

    Errors.Setup()
    System.VerifyDirectories(false)
    System.VerifyRequisites()

    ;; Load and delete the environment file after loading
    /**
     * @type {Environments}
     */
    global ENV := Environments.Load(SW.FILE_ENV, !System.DEV_MODE)
    /**
     * @type {HymnalDB}
     */
    global HYMNAL := HymnalDB.ScanHymnal()
    /**
     * @type {Session}
     */
    global SES := Session.Setup()
    /**
     * @type {Stats}
     */
    global STS := Stats.Setup()
    UI.Setup()
    BackgroundThread.Setup()

    ;; Release all deferred logs that were postponed during initialization
    Console.DumpPostponedLogs()

    Console.Info(Format("Initialization completed. ({1} ms)", Round(A_TickCount - _STARTUP)))
    global APP_STARTUP_TIME := A_TickCount
    System.STATE_INITIALIZED := true

    Args := AppArgs.Parse()
    if (Args.Query) {
      ;; Simulate a launch request
      ;; TODO: Implement a dedicated launch request
      Result := HymnSearchService.Query(Args.Query)
      if (!Result) {
        Console.Error(Format("Search term '{1}' not found", Args.Query))
        Events.System.Exit(1, "Search term not found")
      }
      SES.ProcessSearchResult(Result)
      Launcher.Launch(Args.StartInSlideshow ? "/S" : "/C")
      Events.System.Exit(0, "Hymn launched from command line")
      return
    }

    /**
     * @type {Updater}
     */
    global UPT := Updater.Setup()


    UI.Show(CF.WINDOW.XPOS, CF.WINDOW.YPOS)                                             ;; Show at last saved coordinates
  }

  /**
   * Checks every directory. Creates new one if not present.
   */
  static VerifyDirectories(postponeLog := 0) {
    Missing := 0
    Resolved := 0

    for dir in SW.DIRS {
      if !IsFolderExists(dir) {
        Missing++
        Console.Warn(Format(
          "System: Directory '{1}' was not found. "
          "Creating new one.", dir), postponeLog
        )
        try DirCreate(dir)
        catch Error as e {
          Console.Error("System: Cannot create the directory: " dir, postponeLog)
          continue
        }
        Resolved++
      }
    }

    if Missing {
      Console.Info(Format(
        "System: {1} item(s) were missing; resolved {2} of {3}.",
        Missing, Resolved, Missing),
        postponeLog
      )
    } else {
      Console.Info("System: Directory verification sucessfully.", postponeLog)
    }

  }

  /**
   * Checks whether a presentation software exists.
   *     
   * Microsoft Office PowerPoint is the first software to be checked.
   * If that fails, the default software that runs '.pptx' files will be executed.
   */
  static VerifyRequisites() {
    try {
      SW.FILE_POWERPOINT := RegRead(
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows"
        "\CurrentVersion\App Paths\powerpnt.exe", ''
      )
      SW.FILE_PRESENTER := SW.FILE_POWERPOINT
      Console.Info(Format(
        "System: Using Microsoft Office {1}-bit from `"{2}`"",
        (InStr(SW.FILE_POWERPOINT, ("x86")) ? "32" : "64"),                           ;; Determine if the PowerPoint version is 32-bit or 64-bit
        SW.FILE_POWERPOINT)
      )
    } catch Error {
      SW.FILE_PRESENTER := ''
      Console.Warn("System: Microsoft Office PowerPoint is not installed or detected")
      Console.Info("System: Presentation files will be executed without PowerPoint")
      Console.Info("System: Presenter type setting will be ignored")
    }
  }

  /**
   * Configures the system based on the application's mode (development or production).
   * 
   * - In production mode (`System.DEV_MODE = 0`), installs required binaries and secrets to the temporary directory:
   *     - Copies `7z.exe` and `7z.dll` from the `bin` folder.
   *     - Copies `secrets.env` to the temp directory.
   * - In development mode (`System.DEV_MODE = 1`), sets up a script reload hook for easier development workflow.
   * 
   * This method should be called during application startup to ensure the environment is correctly set up
   * according to whether the script is compiled or running in development.
   */
  static PerformApplicationMode() {
    System.DEV_MODE := (!A_IsCompiled ? 1 : 0)
    switch System.DEV_MODE {
      case 0:
        FileInstall("bin\7z.exe", A_Temp "\7z.exe", true)
        FileInstall("bin\7z.dll", A_Temp "\7z.dll", true)
        FileInstall("secrets.env", A_Temp "\secrets.env", true)
      case 1:
        Misc.HookReloadScript(1, , Events.System.Reload)
    }
  }

  static GetPID() => DllCall("GetCurrentProcessId")
  static GetWinMonitor() => Window.GetCurrentMonitor(System.AHK_PID)
  static IsActive() => (WinActive(System.AHK_PID) ? 1 : 0)
  static HasCrashed() => System.STATE_CRASH
  static IsOnModal() => (WinExist(System.AHK_PID) && WinExist("ahk_class #32770") ? 1 : 0)
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
      PostMessage(0xA1, 2, , , System.AHK_PID)
    } catch Error as e {
      Console.Error("System: Unable to move window. " e.Message)
    }
  }

  /**
   * Fixes Ctrl+Backspace behavior in Edit controls for the given GUI window.
   * Hooks WM_KEYDOWN and simulates Ctrl+Shift+Left, then Delete to remove the previous word.
   * @param {Integer} hwnd - The HWND of the GUI window.
   */
  static FixCtrlBackspace(hwnd) {
    static WM_KEYDOWN := 0x0100
    static VK_BACK := 0x08

    callback := (wParam, lParam, msg, hEdit) {
      ; Only process if the message is for an Edit control in our GUI
      if !DllCall("IsChild", "Ptr", hwnd, "Ptr", hEdit)
        return

      if (wParam = VK_BACK && GetKeyState("Control", "P")) {
        ; Simulate Ctrl+Shift+Left, then Delete
        ControlSend("^+{Left}{Delete}", , "ahk_id " hEdit)
        return 0
      }
    }

    OnMessage(WM_KEYDOWN, callback)
  }
}
