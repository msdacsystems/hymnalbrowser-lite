/**
 * * Updater for HBL
 * --------------------
 * Handles latest release version checking, update, download, and installation
 * of a newer version of the application.
 * 
 * - Pre-releases are not included in checking
 * - Uses installer bin to perform operations even after system exit.
 * - Code 12 is used to let the system know it's being updated.
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2022-06-18
 */
class Updater {
  __New() {
    this.VERSION := ''                                                                  ;; Version of the latest release
    this.URL := ''                                                                      ;; URL of the latest release
    this.PKG_NAME := PathJoin(A_Temp, 'update-hbl.zip')                                 ;; Downloaded package name
    this.PKG_SIZE := 0                                                                  ;; Package size
    this.DOWNLOADING := false                                                           ;; Download indicator
  }

  /**
   * Sets up the updater.
   * @returns {Updater} 
   */
  static Setup() {
    Console.Info("Updater: Setting up auto updater")
    OBJ := Updater()
    OBJ.CleanOldTemp()
    OBJ.CheckForUpdates()
    return OBJ
  }

  /**
   * Cleans the old temp files.
   *     
   * This is useful after updating where installer is not handled
   * and it should be deleted.
   */
  CleanOldTemp() {
    if System.DEV_MODE {
      Console.Info("Updater: Ignored cleaning of old temp due to dev mode")
      return
    }
    TEMPFILES := [
      this.PKG_NAME,
      SW.FILE_PKG_UPT
    ]
    for file in TEMPFILES {
      if !FileExist(file) {
        continue
      }
      try {
        FileDelete(file)
        Console.Info("Updater: Cleaned '" file "'")
      } catch Error {
        Console.Error("Updater: Cannot delete temporary file: '" file "'")
      }
    }
  }

  /**
   * Checks if the updater is currently downloading an update.
   */
  IsDownloading() => (this.DOWNLOADING ? 1 : 0)

  /**
   * Parses the version string from a given URL.
   */
  ParseVersionFromURL(url) {
    versionParts := StrSplit(
      StrSplit(StrSplit(url, '/')[-1], 'Hymnal-Browser-Lite-')[-1], '.'
    )
    versionParts.RemoveAt(-1)
    return StrLower(Join(versionParts, '.'))
  }

  /**
   * Returns true if a new update is available.
   * Checks the latest release version from the repo and compares it to the current version.
   */
  HasNewUpdate() {
    try {
      url := GetReleaseAssetURL(SW.GITHUB_REPO)
    } catch Error {
      Console.Error("HasNewUpdate: Cannot retrieve update status")
      return false
    }
    latestVersion := this.ParseVersionFromURL(url)
    return VerCompare(latestVersion, SW.VERSION_TAG) = 1
  }

  /**
   * Checks the repo for the latest release. Invoked from `System.Exec()` or manual request.
   * @param {bool} force  When true, ignore the configuration setting and always perform the check.
   */
  CheckForUpdates(force := false) {
    if !force && !CF.MAIN.CHECK_UPDATES {
      Console.Info("Updater: Skipped checking for updates (disabled in config)")
      return
    }
    Console.Info("Updater: Checking for updates")
    try {
      this.URL := GetReleaseAssetURL(SW.GITHUB_REPO)
      this.VERSION := this.ParseVersionFromURL(this.URL)
    } catch Error {
      Console.Error("Updater: Cannot retrieve update status")
      return
    }

    updateStatus := VerCompare(this.VERSION, SW.VERSION_TAG)
    switch updateStatus {
      case -1:
        Console.Info("Updater: Application is newer than release version " this.VERSION)
        if force {
          MsgBox("You are running a newer version than the latest release. No update needed.", SW.TITLE)
        }
      case 0:
        Console.Info("Updater: Application is up-to-date.")
        if force {
          MsgBox("You are already running the latest version.", SW.TITLE)
        }
      case 1:
        Console.Info("Updater: New update available: " this.VERSION)
        Console.Verbose(Format('Updater: AssetURL: "{1}"', this.URL))
        this.GetUpdateSize()
        UI.Hide()
        this.AskNewUpdate()
    }
  }

  /**
   * Prompts the user to update
   */
  AskNewUpdate() {
    RESP := MsgBox(Format(
      "A newer version is available. Update now? ({1} MB)`n`n"
      "Your version: {2}`nNewer version: {3}`n`n",
      Round(this.PKG_SIZE / (1024 * 1024)), SW.VERSION_TAG, this.VERSION),
      SW.TITLE, "0x40024"
    )
    switch RESP {
      case "Yes": this.RequestDownload()
      case "No":
        Console.Info("Updater: Update was declined")
        UI.Show(CF.WINDOW.XPOS, CF.WINDOW.YPOS)
    }
  }

  /**
   * Returns the size of the update package.
   */
  GetUpdateSize() {
    REQ := ComObject("WinHttp.WinHttpRequest.5.1")                                      ;; Create request for download
    REQ.Open("HEAD", this.URL)
    REQ.Send()
    this.DL_TMS := A_TickCount                                                          ;; Mark download start timestamp
    this.PKG_SIZE := REQ.GetResponseHeader("Content-Length")                            ;; Update package size in bytes
  }

  /**
   * Requests the download of the update package.
   * 
   * This method will create a GUI to show the download progress
   * and will download the package from the URL.
   */
  RequestDownload() {
    Console.Verbose("Updater: Package size: " this.PKG_SIZE " bytes")

    this.GUI := Gui("+AlwaysOnTop +LastFound -Caption", SW.TITLE ' Updater')            ;; Initiate the GUI
    this.GUI.AddText("", "Downloading package: ")
    this.PROGRESS := this.GUI.AddProgress("YP")
    this.LBL_PERCENTAGE := this.GUI.AddText("YP W28")
    this.LBL_SIZE := this.GUI.AddText("YP W50")
    this.GUI.Show()
    SetTimer(ObjBindMethod(this, "UpdateGUI"), 50)
    this.DOWNLOADING := true
    Download(this.URL, this.PKG_NAME)                                                   ;; Download the actual latest release from GitHub
    this.DOWNLOADING := false
    SetTimer(ObjBindMethod(this, "UpdateGUI"), 0)
    this.GUI.Destroy()
    this.InstallPackage()
  }

  /**
   * Refreshes the download status of the update package
   *     
   * TODO: SetTimer doesn't quit after downloading. Should be fixed.
   */
  UpdateGUI() {
    if !this.DOWNLOADING {
      return
    }
    PKG_SZ := Round(this.PKG_SIZE / (1024 * 1024))                                          ;; MB-converted package size
    try {
      CSZ := FileOpen(this.PKG_NAME, 'r').Length / (1024 * 1024)                          ;; Current Size of the file
      this.LBL_PERCENTAGE.Text := Format("{1}%", Round((CSZ / PKG_SZ) * 100))
      this.LBL_SIZE.Text := Format("{1}/{2} MB", Round(CSZ), Round(PKG_SZ))
      this.PROGRESS.Value := Trim(this.LBL_PERCENTAGE.Text, '%')
    }
  }

  /**
   * Installs the package after downloading it.
   *     
   * The installation is made possible by using a 3rd file that performs
   * the move and delete operations for the old version and the newer one.
   *     
   * The application will pass 8 arguments where the data is read by the installer.
   *    1. Path of the old application
   *    2. Path of the newly downloaded application (usually in temp folder)
   *    3. Path of the old database
   *    4. Path of the new database (usually in temp folder)
   *    5. Directory of the current application
   *    6. Directory of the application's folder in Documents
   *    7. Package name of the asset
   *    8. Version of the updated app
   *     
   * The process deletes the old version and replacing it with the new asset
   * The downloaded package will be also deleted after downloading.
   *     
   * After all file operations are done, the installer will launch the updated file.
   * The updated file then cleans up the installer file.
   */
  InstallPackage() {
    Console.Info(Format(
      "Updater: Download completed in {1} second(s)",
      Round((A_TickCount - this.DL_TMS) / 1000, 1))
    )

    Console.Info(Format('Updater: Installing new package from "{1}"', this.PKG_NAME))
    ZIP := SevenZip(this.PKG_NAME, , SW.BIN_ZIP, SW.FILE_ZIPDLL)                         ;; Create a ZIP object
    DB := CF.GetDefaults(true, true).HYMNAL.PACKAGE                                     ;; Hymnal database
    try {
      RES1 := ZIP.Extract(SW.NAME '/' SW.EXE_NAME, A_Temp, true)                      ;; Extract base .exe file, overwrites existing
      RES2 := ZIP.Extract(SW.NAME '/' DB, A_Temp, true)                               ;; Extract hymnal, overwrites existing
    } catch Error as e {
      Console.Error("Updater: " e.Message)
    }

    switch (RES1 + RES2) {
      case 0: Console.Info("Updater: Extraction successful")
      case 1: Console.Warn(Format("Updater: Failed to extract package. Status: {1} {2}",
        RES1, RES2))
    }

    if !System.DEV_MODE {
      FileInstall("bin\Hymnal Browser Lite Updater.exe", SW.FILE_PKG_UPT, true)       ;; Extract the package installer
    }

    COMMAND := Format(
      '"{1}" "{2}" "{3}" "{4}" "{5}" "{6}" "{7}" "{8}" "{9}"',
      SW.FILE_PKG_UPT,                                                                ;; Installer file
      (System.DEV_MODE ? PathJoin(A_ScriptDir, SW.EXE_NAME) : A_ScriptFullPath),        ;; Arg 1 - Target EXE
      PathJoin(A_Temp, SW.EXE_NAME),                                                  ;; Arg 2 - New EXE
      CF.__FILE_HYMNALDB,                                                             ;; Arg 3 - Target DB
      PathJoin(A_Temp, DB),                                                           ;; Arg 4 - New DB
      A_ScriptDir,                                                                    ;; Arg 5 - Directory of Target EXE
      SW.DIR_DOCS_PROGRAM,                                                            ;; Arg 6 - Directory of App Docs
      this.PKG_NAME,                                                                  ;; Arg 7 - Asset package name
      this.VERSION                                                                    ;; Arg 8 - App Version
    )

    Run(COMMAND)                                                                        ;; Forwards the operation to installer
    Events.System.Exit(12)                                                              ;; Exit the system with code 12 to let the installer remove this old one.
  }
}
