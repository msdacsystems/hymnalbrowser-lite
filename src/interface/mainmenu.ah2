/*
    Interface for Main Menu
    ------------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class UIMainMenu {
    static _NAME := "MAIN"

    static Setup() {
        return UIMainMenu()
    }

    __New() {
        this.GUI := Gui("+LastFound -Caption +AlwaysOnTop", SW.TITLE)          ;; Note: temporarily set to +AlwaysOnTop for development
        this.GUI.SetFont('Q5 S' SW.GLB_FONT_SIZE, SW.GLB_FONT_NAME)
        this.TITLE := this.GUI.AddText("C004B74 SECTION W130 H18", SW.NAME)
        this.TITLE.SetFont('S' SW.GLB_FONT_SIZE+1, "Segoe UI Bold Italic")
        this.VERSION := this.GUI.AddText("X143 Y11 C555555", SW.VERSION_STRING)
        this.VERSION.SetFont('S' 7, SW.GLB_FONT_NAME)
        this.STATUS := this.GUI.AddText("YS+0 C818181", "")
        this.HYMN := this.GUI.AddText("XS +BackgroundTrans W220", "")
        this.DETAILS := this.GUI.AddText("YP C818181", "")
        ; this.GUI.BackColor := 0xBBBBBB
        ; WinSetTransColor("f0f0f0", this.GUI)
        ; ControlSetStyle("+BackgroundTrans", this.HYMN) 
        OnMessage(0x0201, ObjBindMethod(this, "LeftMousePressEvent"))
        OnMessage(0x0204, ObjBindMethod(this, "RightMousePressEvent"))
    }

    LeftMousePressEvent(args*) {
        MouseGetPos(&X, &Y, &W, &C)
        if WinExist(System.AHK_PID) == W {
            (SW.VERBOSE_LOG && !UI.ACTIVE ? _LOG.Verbose('Window is activated'):0)
            System.moveMain()                                                               ;; Allows the user to click-hold on the window to move
            UI.SetActive()
        }
    }

    RightMousePressEvent(args*) {
        
    }

    ShowStatus(message, timeout:=2) {
        /* 
            Displays the status for few seconds
        */
        this.STATUS.Text := message
        if timeout > 0 {
            SetTimer(_Timeout, -1, -100)                                                      ;; Note: Priority was set to -10 to continue threads
        }

        _Timeout() {
            Sleep(timeout*1000)
            this.STATUS.Text := ''
        }
    }

    SetHymnText(text) {
        this.HYMN.Text := text
    }

    ClearHymnText() {
        /*  Clears the text from hymn label */
        this.HYMN.Text := ''
    }
}