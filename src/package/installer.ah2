/*
    * Package Installer
    ---------------------
    Update installer for HBL.

    This was created due to the limitation that we cannot move the old version while
    that is still running. This is the solution to that problem where the main app will
    call this file and let it handle file operations while the app is closed.

    * Should be compiled because it needs to accept arguments

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
*/
#NoTrayIcon
#SingleInstance Force

/*  System Props */
;@Ahk2Exe-ExeName Hymnal Browser Lite Updater.exe
;@Ahk2Exe-SetMainIcon ../../res/app_icon.ico
;@Ahk2Exe-SetCompanyName MSDAC Systems
;@Ahk2Exe-SetCopyright (c) 2022 MSDAC Systems`, Verdadero`, Ycong
;@Ahk2Exe-SetDescription Hymnal Browser Lite Updater
;@Ahk2Exe-SetFileVersion 1.0.0.0
;@Ahk2Exe-SetInternalName Hymnal Browser Lite Updater
;@Ahk2Exe-SetLanguage 0x3409
;@Ahk2Exe-SetLegalTrademarks (c) 2022 MSDAC Systems
;@Ahk2Exe-SetName Hymnal Browser Lite Updater
;@Ahk2Exe-SetOrigFilename Hymnal Browser Lite Updater
;@Ahk2Exe-SetProductName Hymnal Browser Lite Updater
;@Ahk2Exe-SetVersion 1.0.0.0

class Package {
    static Run() {
        return Package()
    }

    __New() {
        if A_Args.Length != 7 {                                                              ;; Do not proceed if args are not exactly 7
            MsgBox("Unauthorized execution", "Updater", "T1 0x10")
            ExitApp(1)
        }
        this.OLD_EXE := A_Args[1]
        this.NEW_EXE := A_Args[2]
        this.OLD_DB := A_Args[3]
        this.NEW_DB := A_Args[4]
        this.DIR_EXE := A_Args[5]
        this.DIR_DOCS := A_Args[6]
        this.PKG_NAME := A_Args[7]
        A_TrayMenu.Delete()
        this.ProcessMove()
    }

    ProcessMove() {
        /*
            Performs the move and deletion of the old version.
            Also runs the new version with an arg of CODE_NEW_UPDATE. (See system codes)
        */
        try {
            while FileExist(this.OLD_EXE) {
                try FileDelete(this.OLD_EXE)
                catch Error {
                    continue
                }
            }
            MOVE_COMPLETE := false
            try FileMove(this.NEW_DB, this.DIR_DOCS, true)                                  ;; For hymn database
            loop {
                if !FileExist(this.OLD_EXE) {   
                    try FileMove(this.NEW_EXE, this.DIR_EXE, true)
                    catch Error as e {
                        continue
                    }
                    MOVE_COMPLETE := true
                }
            } until MOVE_COMPLETE

            loop { 
                try FileDelete(this.PKG_NAME)
            } until !FileExist(this.PKG_NAME)

            if FileExist(this.OLD_EXE) {
                Run(this.OLD_EXE ' "CODE_NEW_UPDATE"')
                ExitApp(0)
            } else {
                ExitApp(1)
            }
        } catch Error as e {
            MsgBox(e.Message ' ' e.Extra ' ' e.What)
        }
    }
}

Package.Run()