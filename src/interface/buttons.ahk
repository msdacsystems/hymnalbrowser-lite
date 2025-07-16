/**
 * * Interface for Buttons
 * -----------------------
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2022-06-03
 */
class UIButtons {
  static _NAME := "BTN"
  static LAUNCH_STATES := {
    Launch: "🚀 Launch",
    InsertHymn: "Start typing",
    NotAvailable: "Not Available",
    ShowSuggestions: "Show suggestions",
    Launching: "🔃 Launching",
    Launched: "🟢 Launched",
  }

  __New() {
    this.CLEAR := GUIx.Button.Extend(
      UI.MAIN.GUI.AddButton("0x40 0x300 0xC00 YP H28 W27", '❌')
    )
    this.LAUNCH := GUIx.Button.Extend(
      UI.MAIN.GUI.AddButton("0x300 0xC00 YP W100", UIButtons.LAUNCH_STATES.Launch)
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
        this.LAUNCH.SetText(UIButtons.LAUNCH_STATES.InsertHymn)
        UI.MAIN.ClearHymnText()
        UI.MAIN.DETAILS.Text := ""
        (UI.CPLTR.ACTIVE ? UI.CPLTR.Close() : 0)

      case "Ready":
        this.LAUNCH.SetText(UIButtons.LAUNCH_STATES.Launch)

      case "NotAvailable":
        SES.LAUNCH_READY := false
        this.LAUNCH.SetEnabled(0)
        this.LAUNCH.SetText(UIButtons.LAUNCH_STATES.NotAvailable)
        UI.MAIN.DETAILS.Text := ''
        UI.MAIN.SetHymnText(Format("No matching results for '{1}'", UI.SEARCH.Text()))
        UI.MAIN.HYMN.Opt('C' SW.TEXT_DISABLED)

      case "ShowSuggestions":
        this.LAUNCH.SetText(SES.SUGGESTIONS " Match" (SES.SUGGESTIONS = 1 ? '' : 'es'))

      case "🔃 Launching":
        this.LAUNCH.SetEnabled(0)
        this.LAUNCH.SetText(UIButtons.LAUNCH_STATES.Launching)

      case "Launched":
        SES.LAUNCH_READY := false
        this.LAUNCH.SetEnabled(0)
        this.LAUNCH.SetText(UIButtons.LAUNCH_STATES.Launched)
    }

  }
}
