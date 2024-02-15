/*
    Interface for Buttons
    -----------------------

    (c) 2022 MSDAC Systems
    Author: Ken Verdadero
    Written 2022-06-03
*/

class UIButtons {
    static _NAME := "BTN"

    __New() {
        this.CLEAR := GUIx.Button.Extend(
            UI.MAIN.GUI.AddButton("0x40 0x300 0xC00 YP H25 W27", '❌')
        )
        this.LAUNCH := GUIx.Button.Extend(
            UI.MAIN.GUI.AddButton("0x300 0xC00 YP W100", " Launch")
        )

        this.LAUNCH.LAST_STATE := 0

        /*  Extended methods */
        this.LAUNCH.SetLastState := SetLastState(obj) => this.LaunchSetLastState()
        this.LAUNCH.SetMode := SetMode(obj, mode) => this.LaunchSetMode(mode)
    }

    Listener() {
        if !UI.SEARCH.HasText() {
            this.LaunchSetMode("InsertHymn")
        }
        if !StrLen(UI.MAIN.HymnText()) && this.LAUNCH.IsEnabled() {                          ;; Disable the launch button as soon as the hymn text is found to be none
            this.LaunchSetMode("NotAvailable")
        }
    }

    LaunchSetLastState() => this.LAUNCH.LAST_STATE := ControlGetEnabled(this.LAUNCH)

    LaunchSetMode(mode, args*) {
        switch mode {
            case "InsertHymn":
                SES.LAUNCH_READY := false
                this.LAUNCH.SetEnabled(0)
                this.LAUNCH.SetText("Insert Hymn")
                UI.MAIN.ClearHymnText()
                UI.MAIN.DETAILS.Text := ""
                (UI.CPLTR.ACTIVE ? UI.CPLTR.Close() : 0)

            case "Ready":
                this.LAUNCH.SetText("Launch")

            case "NotAvailable":
                SES.LAUNCH_READY := false
                this.LAUNCH.SetEnabled(0)
                this.LAUNCH.SetText("Not Available")
                UI.MAIN.DETAILS.Text := ''
                UI.MAIN.SetHymnText(Format("No matching results for '{1}'", UI.SEARCH.Text()))
                UI.MAIN.HYMN.Opt('C' SW.TEXT_DISABLED)

            case "ShowSuggestions":
                this.LAUNCH.SetText(SES.SUGGESTIONS " Match" (SES.SUGGESTIONS = 1 ? '' : 'es'))

            case "Launching":
                this.LAUNCH.SetEnabled(0)
                this.LAUNCH.SetText("Launching")

            case "Launched":
                SES.LAUNCH_READY := false
                this.LAUNCH.SetEnabled(0)
                this.LAUNCH.SetText("Launched")
        }

    }
}