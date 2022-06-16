/*
    Interface for Main Menu
    ------------------------

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class UIMainMenu {
    static _NAME := "MAIN"

    __New() {
        this.GUI := Gui(
            Format("+LastFound -Caption {1}AlwaysOnTop",
            (CF.WINDOW.ALWAYS_ON_TOP ? '+':'-')),
            SW.TITLE
        )
        this.GUI.SetFont('Q5 S' SW.GLB_FONT_SIZE, SW.GLB_FONT_NAME)
        this.TITLE := this.GUI.AddText(Format("C{1} SECTION W130 H18", SW.CL_PRIMARY), SW.NAME)
        this.TITLE.SetFont('S' SW.GLB_FONT_SIZE+1, "Segoe UI Bold Italic")
        this.VERSION := this.GUI.AddText("X143 Y11 C555555", SW.VERSION_STRING (System.DEV_MODE ? ' (Developer mode)':''))
        this.VERSION.SetFont('S' 7, SW.GLB_FONT_NAME)
        this.STATUS := this.GUI.AddText("YS+0 C818181", "")
        this.HYMN := this.GUI.AddText("XS +BackgroundTrans W300", "")
        this.DETAILS := this.GUI.AddText(Format("XP1 C{1} +BackgroundTrans", SW.TEXT_DISABLED), "")

        this.MOVING := false                                                                ;; Moving window indicator. See System.MoveMain and BackgroundThread.WindowListener
        System.AHK_ID := this.GUI.Hwnd
    }

    SetHymnText(text) => this.HYMN.Text := text
    ClearHymnText() => this.HYMN.Text := ''
    HymnText() => this.HYMN.Text
    SetMoving(mode) => this.MOVING := (mode ? 1:0)

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

    WasMoved() {
        /*  Returns the state of window if it's moving or not */
        try {
            WinGetClientPos(&X, &Y,,, System.AHK_ID)
            if X != CF.WINDOW.XPOS && Y != CF.WINDOW.YPOS {
                return 1
            }
        } catch Error as e {
            _LOG.Error("UI: " e.Message)
        }
        return 0
    }
}