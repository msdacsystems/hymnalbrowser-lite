/*
    Settings GUI for HBL
    --------------------

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-05
*/

Class UISettings {
    static _NAME := "SETTINGS"

    __New() {
        this.WIDTH := 280
        this.HEIGHT := 170
        this.OBJ := Gui("+AlwaysOnTop +ToolWindow", "Settings")
        this.OBJ.SetFont('Q5 S' SW.GLB_FONT_SIZE, SW.GLB_FONT_NAME)
        ; this.OBJ.BackColor := 0xFFFFFF
        this.OBJ.AddGroupBox(Format("SECTION W{1} R1", this.WIDTH-20), "General")
        this.CHK_AOT := GUIx.CheckBox.Extend(this.OBJ.AddCheckbox("XP15 YP20", "Always on top"))
        this.OBJ.AddGroupBox(Format("XS SECTION W{1} R2", this.WIDTH-20), "Presentation")
        this.CHK_FOCUS_BACK := GUIx.CheckBox.Extend(this.OBJ.AddCheckbox("XP15 YP20", "Focus back after launching"))
        this.CHK_SLIDESHOW := GUIx.CheckBox.Extend(this.OBJ.AddCheckbox("XP", "Start in slideshow"))
        ; this.BTN_RESET := GUIx.Button.Extend(this.OBJ.AddButton(Format("X{1} Y{2}", this.WIDTH-200, this.HEIGHT-38), "Reset to defaults"))
        this.BTN_OK := GUIx.Button.Extend(this.OBJ.AddButton(Format("X{1} Y{2} W75", this.WIDTH-90, this.HEIGHT-38), "OK"))
        this.OBJ.AddText(
            Format("Y{1} X17 C{2}", this.HEIGHT-30, SW.TEXT_DISABLED), SW.VERSION_STRING
        )

        this.SetStates()
    }

    Show() => this.OBJ.Show(Format("W{1} H{2}", this.WIDTH, this.HEIGHT))
    Hide() => this.OBJ.Hide()

    Listener() {
        if GetKeyState("Esc", 'P') {
            this.Hide()
        }
    }

    SetStates() {
        /*  Sets initial states of the elements according to config */
        this.CHK_AOT.SetChecked(CF.WINDOW.ALWAYS_ON_TOP ? 1:0)
        this.CHK_FOCUS_BACK.SetChecked(CF.LAUNCH.FOCUS_BACK ? 1:0)
        this.CHK_SLIDESHOW.SetChecked(CF.LAUNCH.TYPE && SW.FILE_PRESENTER ? 1:0)
        this.CHK_SLIDESHOW.SetEnabled(SW.FILE_PRESENTER ? 1:0)

        ; this.BTN_RESET.SetEnabled(0)                                                        ;; Temporarily disabled due to under development
    }
    
    IsOpened() =>  (WinExist("ahk_id " this.OBJ.Hwnd) ? 1:0)
}