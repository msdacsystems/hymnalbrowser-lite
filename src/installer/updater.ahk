/**
 * * Package Updater
 * ---------------------
 * This script addresses the limitation where the old version cannot be moved while it is running.
 * As a workaround, the main application invokes this script to handle file operations
 * after the main app has closed.
 * 
 * * This script should be compiled because it needs to accept arguments
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 */
__NAME := "Hymnal Browser Lite Updater"

#NoTrayIcon
#SingleInstance Force

/*  System Props */
;@Ahk2Exe-ExeName Hymnal Browser Lite Updater.exe
;@Ahk2Exe-SetName Hymnal Browser Lite Updater
;@Ahk2Exe-SetDescription Hymnal Browser Lite Updater
;@Ahk2Exe-SetInternalName Hymnal Browser Lite Updater
;@Ahk2Exe-SetOrigFilename Hymnal Browser Lite Updater
;@Ahk2Exe-SetProductName Hymnal Browser Lite Updater
;@Ahk2Exe-SetCompanyName MSDAC Systems
;@Ahk2Exe-SetCopyright © 2022-2025 MSDAC Systems
;@Ahk2Exe-SetLegalTrademarks © 2022-2025 MSDAC Systems
;@Ahk2Exe-SetMainIcon ../../res/app_icon.ico
;@Ahk2Exe-SetFileVersion 1.0.1.0
;@Ahk2Exe-SetLanguage 0x3409
;@Ahk2Exe-SetVersion 1.0.1.0

class Updater {
  static MANUAL_DOWNLOAD_URL := "https://knv.li/hbl-latest"
  static Run() {
    return Updater()
  }

  __New() {
    if A_Args.Length != 8 {                                                             ;; Do not proceed if args are not exactly 7
      MsgBox("Unauthorized execution", "Updater", "T1 0x10")
      ExitApp(1)
    }
    this.APP_NAME := "Hymnal Browser Lite"
    this.ExeFilename := this.APP_NAME ".exe"
    this.OldExeFile := A_Args[1]
    this.NewExeFile := A_Args[2]
    this.OldDatabase := A_Args[3]
    this.NewDatabase := A_Args[4]
    this.DirExe := A_Args[5]
    this.DirDocs := A_Args[6]
    this.PackageName := A_Args[7]
    this.Version := A_Args[8]
    this.UI := Updater.UIUpdater()
    A_TrayMenu.Delete()
    Sleep(1000)
    this.ProcessMove()
  }

  /**
   * Performs the move and deletion of the old version.
   * Also runs the new version.
   */
  ProcessMove(bypass := false) {
    this.UI.Show()
    MaxTries := 10

    while (MaxTries > 0 && FileExist(this.OldExeFile)) {
      try FileDelete(this.OldExeFile)
      if !FileExist(this.OldExeFile)
        break
      MaxTries--
      Sleep(100)
    }

    MaxDeleteTries := 50
    DeleteTries := 0
    while DeleteTries < MaxDeleteTries {
      try FileMove(this.NewDatabase, this.DirDocs, true)
      try FileDelete(this.PackageName)
      if !FileExist(this.PackageName) {
        break
      }
      DeleteTries++
      Sleep(50)
    }

    try {
      FileMove(this.NewExeFile, this.DirExe, true)
    } catch Error as e {
      this.UI.Hide()
      MsgBox(
        Format("Update failed while moving the new executable.`nError: {1}`n`nIf the issue persists, please install it manually using the link below:`n{2}", e.Message, Updater.MANUAL_DOWNLOAD_URL),
        this.APP_NAME, "0x10"
      )
      ExitApp(1)
    }
    Sleep(400)

    newAppFile := this.DirExe '\' this.ExeFilename
    this.UI.Hide()
    if FileExist(newAppFile) {
      MsgBox(Format(
        "Update to {1} was successful.",
        this.Version), __NAME, "0x40040"
      )
      try {
        Run(newAppFile)
        ExitApp(0)
      } catch Error {
        ExitApp(1)
      }
    } else {
      MsgBox(
        Format("Could not obtain privilege to the target folder. Update failed.`n`nIf the issue persists, please install it manually using the link below:`n{1}", Updater.MANUAL_DOWNLOAD_URL),
        this.APP_NAME
      )
      ExitApp(1)
    }
  }

  class UIUpdater {
    __New() {
      this.UI := Gui("+AlwaysOnTop -Caption +LastFound")
      this.UI.AddText("", "Updating Hymnal Browser Lite...")
      this.PROGRESS := this.UI.AddProgress("XP -Smooth 0x8 W300")
      SetTimer(ObjBindMethod(this, "Push"), 25)
    }
    Show() => this.UI.Show()
    Hide() => this.UI.Hide()
    Push(args*) => this.PROGRESS.Value := 1
  }
}

Updater.Run()