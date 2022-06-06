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
        ControlSetEnabled(mode, this.LAUNCH)
        SES.LAUNCH_READY := mode
    }
    LaunchIsEnabled() {
        return ControlGetEnabled(this.LAUNCH)
    }

    LaunchSetText(text) {
        this.LAUNCH.Text := text
    }

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