/**
 * * Presentation Launcher for HBL
 * ----------------------------
 * Extracts the presentation from the database and launches the file.
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 *  Written 2022-06-06
 */
class Launcher {
  /**
   * Ensures that the temporary folder exists.
   */
  static EnsureTempFolderExists() {
    if !IsFolderExists(SW.DIR_TEMP)
      DirCreate(SW.DIR_TEMP)
  }

  /**
   * Handles extraction errors.
   */
  static HandleExtractError(e) {
    switch e.Extra {
      case 'Binary': Errors.Launcher("AbsentBinary")
      case 'Library': Errors.Launcher("AbsentLibrary")
      default: Errors.BaseError(e)
    }
  }

  /**
   * Notifies user if extracted file is missing.
   */
  static NotifyMissingFile() {
    Console.Error("Extracted file cannot be found")
    Errors.Notify(Format(
      "'{1}' was not found.`nRestarting the application may fix the problem.", SES.CURR_HYMN)
    )
  }

  /**
   * Runs the presentation file.
   */
  static RunPresentation(ExtractedFilePath, LaunchTypeOverride := false) {
    if SW.FILE_PRESENTER {
      ; Determine launch type: LaunchTypeOverride takes precedence if set
      launchType := LaunchTypeOverride
      if !launchType {
        launchType := (!CF.LAUNCH.TYPE ? '/C' : '/S')
      }
      Run(Format('{1} {2} "{3}"',
        SW.FILE_POWERPOINT,
        launchType,
        ExtractedFilePath)
      )
    } else {
      Console.Verbose("Launcher: Running presentation without PowerPoint")
      Run(ExtractedFilePath)
    }
  }

  /**
   * Extracts the target file from the database and launches it.
   * 
   * * The target file depends on the current session data.
   */
  static Launch(LaunchTypeOverride := false) {
    ST := A_TickCount
    UI.BTN.LaunchSetMode("Launching")
    Launcher.EnsureTempFolderExists()
    System.SetActive()

    try {
      Result := HYMN_ZIP.Extract(SES.HYMN_PATH, SW.DIR_TEMP)
    } catch Error as e {
      Launcher.HandleExtractError(e)
      return
    }

    ExtractedFilePath := PathJoin(SW.DIR_TEMP, SES.FILENAME)

    if !FileExist(ExtractedFilePath) {
      Launcher.NotifyMissingFile()
      return
    }

    if Result == 2 {
      Console.Verbose('Launcher: Hymn "' SES.FILENAME '" already exists in temp folder')
    }

    SetTimer(FileManagement.RemoveOldest.Bind(this), -3000)

    try {
      Launcher.RunPresentation(ExtractedFilePath, LaunchTypeOverride)

      Console.Info(Format('Launcher: Launched Hymn "{1} {2}" ({3} ms)',
        SES.CURR_NUM, SES.CURR_TTL, Round(A_TickCount - ST))
      )
      SES.COUNT_LAUNCH += 1
      STS.RecordLaunch(SES.CURR_NUM)
      UI.BTN.LaunchSetMode("Launched")

      if CF.LAUNCH.FOCUS_BACK {
        UI.SetActive()
        System.SetActive()
      }
    } catch Error as e {
      Console.Error("Launcher: Error occured while launching Hymn #" SES.CURR_NUM "; " e.Message)
    }
  }
}
