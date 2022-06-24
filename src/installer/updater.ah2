/*
    * Package Updater
    ---------------------
    This was created due to the limitation that we cannot move the old version while
    that is still running. This is the solution to that problem where the main app will
    call this file and let it handle file operations while the app is closed.

    * Should be compiled because it needs to accept arguments

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
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
;@Ahk2Exe-SetCopyright (c) 2022 MSDAC Systems`, Verdadero`, Ycong
;@Ahk2Exe-SetLegalTrademarks (c) 2022 MSDAC Systems
;@Ahk2Exe-SetMainIcon ../../res/app_icon.ico
;@Ahk2Exe-SetFileVersion 1.0.0.0
;@Ahk2Exe-SetLanguage 0x3409
;@Ahk2Exe-SetVersion 1.0.0.0

class Updater {
    static Run() {
        return Updater()
    }

    __New() {
        if A_Args.Length != 8 {                                                             ;; Do not proceed if args are not exactly 7
            MsgBox("Unauthorized execution", "Updater", "T1 0x10")
            ExitApp(1)
        }
        this.APP_NAME := "Hymnal Browser Lite"
        this.EXE_NAME := this.APP_NAME ".exe"
        this.OLD_EXE := A_Args[1]
        this.NEW_EXE := A_Args[2]
        this.OLD_DB := A_Args[3]
        this.NEW_DB := A_Args[4]
        this.DIR_EXE := A_Args[5]
        this.DIR_DOCS := A_Args[6]
        this.PKG_NAME := A_Args[7]
        this.VERSION := A_Args[8]
        this.UI := Updater.UIUpdater()
        A_TrayMenu.Delete()
        this.ProcessMove()
    }

    ProcessMove(bypass:=false) {
        /*
            Performs the move and deletion of the old version.
            Also runs the new version.
        */
        this.UI.Show()

        while FileExist(this.OLD_EXE) {
            try FileDelete(this.OLD_EXE)
        }
        
        loop { 
            try FileMove(this.NEW_DB, this.DIR_DOCS, true)
            try FileDelete(this.PKG_NAME)
        } until !FileExist(this.PKG_NAME)

        try {
            FileMove(this.NEW_EXE, this.DIR_EXE, true)
        } catch Error as e {
            this.UI.Hide()
            MsgBox("Update failed.", this.APP_NAME)
            ExitApp(1)
        }
        Sleep(400)

        NEW_EXE := this.DIR_EXE '\' this.EXE_NAME
        if FileExist(NEW_EXE) {
            ; DIFF := DateDiff(A_Now, FileGetTime(NEW_EXE, "C"), "Seconds")                 ;; Difference
            this.UI.Hide()
            MsgBox(Format(
                "Update to {1} was successful.",
                this.VERSION), __NAME, "0x40040"
            )
            try Run(NEW_EXE)
            catch Error as e {
                ExitApp(1)
            }
            ; PROCESS := "ahk_exe " this.EXE_NAME
            ; WinWaitActive(PROCESS)
            ExitApp(0)
        } else {
            this.UI.Hide()
            MsgBox("Could not obtain privilege to the target folder. "
                "Update failed.", this.APP_NAME
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




