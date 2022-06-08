/*
    Interface for Main Menu
    ------------------------

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class UIMainMenu {
    static _NAME := "MAIN"

    static Setup() {
        return UIMainMenu()
    }

    __New() {
        this.GUI := Gui(
            Format("+LastFound -Caption {1}AlwaysOnTop",
            (CF.WINDOW.ALWAYS_ON_TOP ? '+':'-')),
            SW.TITLE
        )
        this.GUI.SetFont('Q5 S' SW.GLB_FONT_SIZE, SW.GLB_FONT_NAME)
        this.TITLE := this.GUI.AddText("C004B74 SECTION W130 H18", SW.NAME)
        this.TITLE.SetFont('S' SW.GLB_FONT_SIZE+1, "Segoe UI Bold Italic")
        this.VERSION := this.GUI.AddText("X143 Y11 C555555", SW.VERSION_STRING)
        this.VERSION.SetFont('S' 7, SW.GLB_FONT_NAME)
        this.STATUS := this.GUI.AddText("YS+0 C818181", "")
        this.HYMN := this.GUI.AddText("XS +BackgroundTrans W300", "")
        this.DETAILS := this.GUI.AddText(Format("XP1 C{1} +BackgroundTrans", SW.TEXT_DISABLED), "")
        ; this.GUI.BackColor := 0xBBBBBB
        ; WinSetTransColor("f0f0f0", this.GUI)
        ; ControlSetStyle("+BackgroundTrans", this.HYMN) 

        this.MOVING := false                                                                ;; Moving window indicator. See System.MoveMain and BackgroundThread.WindowListener
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
    HymnText() {
        return this.HYMN.Text
    }

    SetMoving(mode) {
        this.MOVING := (mode ? 1:0)
    }

    WasMoved() {
        /*  Returns the state of window if it's moving or not */
        try {
            WinGetClientPos(&X, &Y,,, System.AHK_TITLE)
            if X != CF.WINDOW.XPOS && Y != CF.WINDOW.YPOS {
                return 1
            }
        } catch Error as e {
            _LOG.Error("UI: " e.Message)
        }
        return 0
    }
}