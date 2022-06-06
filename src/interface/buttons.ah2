/*
    Interface for Buttons
    -----------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class UIButtons {
    static _NAME := "BTN"

    static Setup() {
        return UIButtons()
    }

    __New() {
        this.CLEAR := UI.MAIN.GUI.AddButton("YP H25 W25", "❌")
        this.LAUNCH := UI.MAIN.GUI.AddButton("YP W100", "Launch")
        UI.MAIN.BG := UI.MAIN.GUI.AddPicture("X0 Y0 +0x4000000", SW.FILE_BG)
    }

    LaunchSetEnabled(mode:=1) {
        ControlSetEnabled(mode, UI.BTN.LAUNCH)
    }
}