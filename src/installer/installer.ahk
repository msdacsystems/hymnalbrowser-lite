/*
    * HBL Installer
    ---------------------
    Application installer for Hymnal Browser Lite

    (c) 2022 MSDAC Systems
    Author: Ken Verdadero
    Written: 2022-06-21
*/

#SingleInstance Force
#Include ../../../lib/ext/Misc.ah2

/*  System Props */
;@Ahk2Exe-ExeName Hymnal Browser Lite Installer.exe
;@Ahk2Exe-SetName Hymnal Browser Lite Installer
;@Ahk2Exe-SetDescription Hymnal Browser Lite Installer
;@Ahk2Exe-SetInternalName Hymnal Browser Lite Installer
;@Ahk2Exe-SetOrigFilename Hymnal Browser Lite Installer
;@Ahk2Exe-SetProductName Hymnal Browser Lite Installer
;@Ahk2Exe-SetCompanyName MSDAC Systems
;@Ahk2Exe-SetCopyright (c) 2022 MSDAC Systems`, Verdadero`, Ycong
;@Ahk2Exe-SetLegalTrademarks (c) 2022 MSDAC Systems
;@Ahk2Exe-SetMainIcon ../../res/app_icon.ico
;@Ahk2Exe-SetFileVersion 1.0.0.0
;@Ahk2Exe-SetLanguage 0x3409
;@Ahk2Exe-SetVersion 1.0.0.0

Misc.HookReloadScript()

INST := Installer.Run()


class Installer {
    /*
        Core installer
    */
    static APP_NAME := "Hymnal Browser Lite Installer"
    static APP := "Hymnal Browser Lite"
    static COPYRIGHT := "Hymnal Browser Lite © 2022 MSDAC Systems"
    static DESC := Format(
        "A hymn browser and launcher for Seventh-day Adventist Church, lightweight version.`n"
        "`nInstall path: ",
        this.APP)
    static CONTACTS := "GitHub: "
    static AGREEMENT := (
        "By installing this application, you agree to let the application "
        "collect necessary data for analytics and software improvements."
    )
    static INSTALL_PATH := "C:\Program Files\MSDAC Systems\Hymnal Browser Lite"

    static Run() {
        return Installer()
    }

    __New() {
        this.UI := UI()
        this.UI.Show()
    }

    Install() {
        this.UI.Install()
        ; FileInstall()
    }

    Cancel() {
        ExitApp(0)
    }
}


class UI {
    /*
        Handles GUI elements and behaviors
    */
    static SZ := [500, 350]                                                                 ;; Interface size of the installer
    static BTN_WIDTH := 75
    static IMAGE_BG := "..\..\res\installer_bg.png"

    __New() {
        this.InitGUI()
        this._InitOptions()
    }

    InitGUI() {
        /*  Initializes GUI elements/controls */
        this.GUI := Gui("+LastFound -MaximizeBox -Resize", Installer.APP_NAME)
        this.GUI.AddPicture("X0 Y0", UI.IMAGE_BG)
        this.TITLE := this.GUI.AddText("X160 Y20 H75 W300 +BackgroundTrans", Installer.APP_NAME)
        this.DESC := this.GUI.AddText("XP W300 H100 +BackgroundTrans", Installer.DESC)
        this.INST_PATH := this.GUI.AddEdit("YP+75 +Disabled", Installer.INSTALL_PATH)
        this.CHK_DESKTOP := this.GUI.AddCheckbox("YP+30 W300 H30", "Create a desktop shortcut")
        this.AGREEMENT := this.GUI.AddText("YP+50 W280 +BackgroundTrans ", Installer.AGREEMENT)

        this.COPYRIGHT := this.GUI.AddText(
            Format("X25 Y{1} W280 +BackgroundTrans", UI.SZ[2] - 30), Installer.COPYRIGHT
        )
        this.BTN_INSTALL := this.GUI.AddButton(Format("X{1} Y{2} W{3}",
            UI.SZ[1] - 180, UI.SZ[2] - 50, UI.BTN_WIDTH), "Install"
        )
        this.BTN_CANCEL := this.GUI.AddButton(Format("X{1} Y{2} W{3}",
            UI.SZ[1] - 100, UI.SZ[2] - 50, UI.BTN_WIDTH), "Cancel"
        )

        this.BTN_INSTALL.OnEvent("Click", ObjBindMethod(this, "EventHandler", "Install"))
        this.BTN_CANCEL.OnEvent("Click", ObjBindMethod(this, "EventHandler", "Cancel"))
        this.GUI.OnEvent("Close", ExitApp)
    }

    EventHandler(event, obj, state) {
        switch event {
            case "Install": INST.Install()
            case "Cancel": INST.Cancel()
        }
    }

    _InitOptions() {
        /*  Initializes all control options */
        this.INST_PATH.SetFont("S9", "Segoe UI")
        this.TITLE.SetFont("S18 c008dc9", "Segoe UI Bold")
        this.AGREEMENT.SetFont("S7 C808080", "Segoe UI")
        this.COPYRIGHT.SetFont("S7 C808080", "Segoe UI")
        ControlSetChecked(1, this.CHK_DESKTOP)

        COMMON := [this.DESC, this.BTN_INSTALL, this.BTN_CANCEL, this.CHK_DESKTOP]
        for obj in COMMON {
            obj.SetFont("S10", "Segoe UI")
        }

    }

    Install() {
        this.Hide()
        PROGRESS := Gui("+LastFound -Caption", Installer.APP_NAME)
        PROGRESS.AddText("", "Installing")
        PROGRESS.AddProgress("W150", "Test")
        PROGRESS.Show()
    }

    Show() => this.GUI.Show(Format("W{1} H{2}", UI.SZ[1], UI.SZ[2]))
    Hide() => this.GUI.Hide()
}