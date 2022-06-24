/*
    Updater for HBL
    --------------------
    Handles latest release version checking, update, download, and installation
    of a newer version of the application.
    
    - Pre-releases are not included in checking
    - Uses installer bin to perform operations even after system exit.
    - Code 12 is used to let the system know it's being updated.    
    
    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-18
*/


class Updater {
    __New() {
        this.VERSION := ''                                                                  ;; Version of the latest release
        this.URL := ''                                                                      ;; URL of the latest release
        this.PKG_NAME := PathJoin(A_Temp, 'update-hbl.zip')                                 ;; Downloaded package name
        this.PKG_SIZE := 0                                                                  ;; Package size
        this.DOWNLOADING := false                                                           ;; Download indicator
    }

    static Setup() {
        _LOG.Info("Updater: Setting up auto updater")
        OBJ := Updater()
        OBJ.CleanOldTemp()
        OBJ.CheckForUpdates()
        return OBJ
    }

    CleanOldTemp() {
        /*
            Cleans the old temp files.

            This is useful after updating where installer is not handled
            and it should be deleted.
        */
        if System.DEV_MODE {
            _LOG.Info("Updater: Ignored cleaning of old temp")
            return
        }
        TEMPFILES := [this.PKG_NAME, SW.FILE_PKG_UPT]
        for file in TEMPFILES {
            if !FileExist(file) {
                continue
            }
            try {
                FileDelete(file)
                _LOG.Info("Updater: Cleaned '" file "'")
            } catch Error {
                _LOG.Error("Updater: Cannot delete temporary file: '" file "'")
            }
        }
    }

    IsDownloading() => (this.DOWNLOADING ? 1:0)

    CheckForUpdates() {
        /*  Checks the repo for latest release. Invoked from System.Exec() */
        _LOG.Info("Updater: Checking for updates")
        try this.URL := GetReleaseAssetURL(SW.GITHUB_REPO)
        catch Error {
            _LOG.Warn("Cannot retrieve update status")
            return
        }
        VERSION := StrSplit(
            StrSplit(StrSplit(this.URL, '/')[-1],
            'Hymnal-Browser-Lite-')[-1], '.'
        )
        VERSION.RemoveAt(-1)
        VERSION := Join(VERSION, '.')
        this.VERSION := VERSION
        
        switch VerCompare(VERSION, SW.VERSION_TAG) {
            case -1:
                _LOG.Info("Updater: Application is newer than release version " VERSION)
            case 0:
                _LOG.Info("Updater: Application is up-to-date.")
            case 1:
                _LOG.Info("Updater: New update available: " VERSION)
                _LOG.Verbose(Format('Updater: AssetURL: "{1}"', this.URL))
                this.GetUpdateSize()
                UI.Hide()
                this.AskNewUpdate()
        }
    }

    AskNewUpdate() {
        /*
            Prompts the user to update
        */
        RESP := MsgBox(Format(
            "A newer version is available. Update now? ({1} MB)`n`n"
            "Your version: {2}`nNewer version: {3}",
            Round(this.PKG_SIZE/(1024*1024)), SW.VERSION_TAG, this.VERSION),
            SW.TITLE, "0x40024"
        )
        switch RESP {
            case "Yes": this.RequestDownload()
            case "No":
                _LOG.Info("Updater: Update was declined")
                UI.Show(CF.WINDOW.XPOS, CF.WINDOW.YPOS)
        }
    }

    GetUpdateSize() {
        REQ := ComObject("WinHttp.WinHttpRequest.5.1")                                      ;; Create request for download
        REQ.Open("HEAD", this.URL)
        REQ.Send()
        this.DL_TMS := A_TickCount                                                          ;; Mark download start timestamp
        this.PKG_SIZE := REQ.GetResponseHeader("Content-Length")                            ;; Update package size in bytes
    }
    
    RequestDownload() {
        _LOG.Verbose("Updater: Package size: " this.PKG_SIZE " bytes")

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

    UpdateGUI() {
        /*  
            Refreshes the download status of the update package

            TODO: SetTimer doesn't quit after downloading. Should be fixed.
        */
        if !this.DOWNLOADING {
            return
        }
        PKG_SZ := Round(this.PKG_SIZE/(1024*1024))                                          ;; MB-converted package size
        try CSZ := FileOpen(this.PKG_NAME, 'r').Length/(1024*1024)                          ;; Current Size of the file
        this.LBL_PERCENTAGE.Text := Format("{1}%", Round((CSZ/PKG_SZ)*100))
        this.LBL_SIZE.Text := Format("{1}/{2} MB", Round(CSZ), Round(PKG_SZ))
        this.PROGRESS.Value := Trim(this.LBL_PERCENTAGE.Text, '%')
    }

    InstallPackage() {
        /*
            Installs the package after downloading it.

            The installation is made possible by using a 3rd file that performs
            the move and delete operations for the old version and the newer one.

            The application will pass 7 arguments where the data is read by the installer.
                1. Path of the old application
                2. Path of the newly downloaded application (usually in temp folder)
                3. Path of the old database
                4. Path of the new database (usually in temp folder)
                5. Directory of the current application
                6. Directory of the application's folder in Documents
                7. Package name of the asset
                8. Version of the updated app

            The process deletes the old version and replacing it with the new asset
            The downloaded package will be also deleted after downloading.

            After all file operations are done, the installer will launch the updated file.
        */
        _LOG.Info(Format(
            "Updater: Download completed in {1} second(s)",
            Round((A_TickCount-this.DL_TMS)/1000, 1))
        )

        _LOG.Info(Format('Updater: Installing new package from "{1}"', this.PKG_NAME))
        ZIP := SevenZip(this.PKG_NAME,, SW.BIN_ZIP, SW.FILE_ZIPDLL)                         ;; Create a ZIP object
        DB := CF.GetDefaults(true, true).HYMNAL.PACKAGE                                     ;; Hymnal database
        try {
            RES1 := ZIP.Extract(SW.NAME '/' SW.EXE_NAME, A_Temp, true)                      ;; Extract base .exe file, overwrites existing
            RES2 := ZIP.Extract(SW.NAME '/' DB, A_Temp, true)                               ;; Extract hymnal, overwrites existing
        } catch Error as e {
            _LOG.Error("Updater: " e.Message)
        }
        
        switch (RES1 + RES2) {
            case 0: _LOG.Info("Updater: Extraction successful")
            case 1: _LOG.Warn(Format("Updater: Failed to extract package. Status: {1} {2}",
                    RES1, RES2))
        }

        if !System.DEV_MODE {
            FileInstall("bin\Hymnal Browser Lite Updater.exe", SW.FILE_PKG_UPT, true)       ;; Extract the package installer
        }
        
        COMMAND := Format(
            '"{1}" "{2}" "{3}" "{4}" "{5}" "{6}" "{7}" "{8}" "{9}"',
            SW.FILE_PKG_UPT,                                                                ;; Installer file
            (System.DEV_MODE ? PathJoin(A_ScriptDir, SW.EXE_NAME):A_ScriptFullPath),        ;; Arg 1 - Target EXE
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