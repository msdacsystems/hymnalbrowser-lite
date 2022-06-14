/*
    Interface for Buttons
    -----------------------

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class UIButtons {
    static _NAME := "BTN"

    __New() {
        ICON_CLEAR := LoadPicture("shell32.dll", 'Icon-240 w' SysGet(2), &ImgType)
        this.CLEAR := UI.MAIN.GUI.AddButton("0x40 0x300 0xC00 YP H25 W27")
        this.LAUNCH := UI.MAIN.GUI.AddButton("0x300 0xC00 YP W100", " Launch")
        SendMessage(0xF7, 1, ICON_CLEAR, this.CLEAR)                                        ;; Sets an icon to the clear button
    }

    Listener() {
        if !UI.SEARCH.HasText() {
            this.LaunchSetMode("InsertHymn")
        }
        if !StrLen(UI.MAIN.HymnText()) && this.LaunchIsEnabled() {                          ;; Disable the launch button as soon as the hymn text is found to be none
            this.LaunchSetMode("NotAvailable")
        }
    }

    LaunchSetEnabled(mode:=1) {
        ControlSetEnabled(mode, this.LAUNCH)
        SES.LAUNCH_READY := mode
    }
    LaunchIsEnabled() => ControlGetEnabled(this.LAUNCH)
    LaunchSetText(text) => this.LAUNCH.Text := text

    LaunchSetMode(mode, args*) {
        switch mode {
            case "InsertHymn":
                this.LaunchSetEnabled(0)
                this.LaunchSetText("Insert Hymn")
                UI.MAIN.ClearHymnText()
                UI.MAIN.DETAILS.Text := ""
                (UI.CPLTR.ACTIVE ? UI.CPLTR.Close():0)

            case "Ready":
                this.LaunchSetText("Launch")
                
            case "NotAvailable":
                this.LaunchSetEnabled(0)
                this.LaunchSetText("Not Available")
                UI.MAIN.DETAILS.Text := ''
                UI.MAIN.SetHymnText(Format("No matching results for '{1}'", UI.SEARCH.Text()))
                UI.MAIN.HYMN.Opt('C' SW.TEXT_DISABLED)

            case "ShowSuggestions":
                this.LaunchSetText(SES.SUGGESTIONS " Match" (SES.SUGGESTIONS=1?'':'es'))

            case "Launching":
                this.LaunchSetEnabled(0)
                this.LaunchSetText("Launching")
                
            case "Launched":
                this.LaunchSetEnabled(0)
                this.LaunchSetText("Launched")
        }
        
    }
}