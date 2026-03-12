/**
 * * Event handler and forwarder for interface
 * ------------------------------------------
 * 
 * This class handles all events that are triggered by the interface.
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2022-06-03
 */
class Events {
  class System {
    /**
     * System Exit
     * Handles events for application exit.
     */
    static Exit(exitCode := 0, message := 'Application exited due to an error', args*) {
      try RT := Round((A_TickCount - APP_STARTUP_TIME) / 1000, 3)                                     ;; Running time of the software
      catch Error {
        RT := Round((A_TickCount - _STARTUP) / 1000, 3)
      }

      FileManagement.CloseTemp()
      try SES.EndSession()

      if !exitCode or exitCode == 2 {
        Console.info("System: The user has closed the program")
        Console.info("System: Application exited. Running time: " RT " second(s)")
      } else if exitCode == 10 {                                                      ;; Exit Code 10 - System reload
        Console.info("System: System requested an application reload")
        Console.info("System: Application will reload. Running time: " RT " second(s)")
        Console.Close()
        Reload()
        return
      } else if exitCode == 12 {                                                      ;; Exit Code 12 - System Update
        Console.info("System: System requested a package update")
        Console.info("System: Application will terminate. Running time: " RT " second(s)")
      } else {
        Console.error(Format(
          "System: Exit code {1}; Reason: {2}; Running time: {3} second(s)",
          exitCode, message, RT)
        )
      }

      Console.Close()                                                                    ;; Close the log
      ExitApp(exitCode)
    }

    /**
     * Manual update check triggered from UI (context menu or otherwise).
     */
    static CheckUpdates(args*) {
      if UPT && UPT.IsDownloading() {
        MsgBox("An update is already being downloaded. Please wait.", SW.TITLE)
        return
      }
      Console.Info("Events: Manual update check requested")
      UPT.CheckForUpdates(true)
    }
    static Reload() {
      Events.System.Exit(10)
    }
  }

  class Title {
    static Click(args*) {
    }
  }

  class Hymn {
    static Click(args*) {
    }
  }

  class Details {
    static Click(args*) {
    }
  }

  class ContextMenu {
    static Click(source, hk := '') {
      if !UI.SETTINGS.IsOpened() and !UPT.IsDownloading() {
        UI.RCTX.ShowMenu()
      }
    }
  }

  class Launch {
    static Click(source, hk := '') {
      if !System.IsActive() or !ControlGetEnabled(UI.BTN.LAUNCH) {
        return
      }
      source := (!source ? 'MouseReleaseEvent' : source)
      Console.Verbose("Events: Launch button was pressed. | Source: " source)
      Launcher.Launch()
    }
  }

  class Settings {
    static Click(args*) => UI.SETTINGS.Show()
    static CloseEvent(args*) => UI.SETTINGS.Hide()

    static ToggleCheck(chkObj, cfgKey, args*) {
      chkObj.SetChecked(chkObj.CheckState() ? 1 : 0)
      switch cfgKey {
        case 'FBK': CF.LAUNCH.FOCUS_BACK := chkObj.CheckState()
        case 'SLD': CF.LAUNCH.TYPE := chkObj.CheckState()
        case 'AOT':
          CF.WINDOW.ALWAYS_ON_TOP := chkObj.CheckState()
          UI.MAIN.GUI.Opt((chkObj.CheckState() ? '+' : '-') "AlwaysOnTop")
        case 'UPD':
          CF.MAIN.CHECK_UPDATES := chkObj.CheckState()
      }
      CF.Dump()
    }

    static Ok(args*) {
      Events.Settings.CloseEvent()
    }
  }

  class Search {
    static TextChanged(args*) {
      UI.CPLTR.ScanSearchBar()
      UI.SEARCH.RetrieveDetails("TextChangedEvent")
    }
    static Clear(args) {
      Console.Verbose("Events: Search bar was cleared")
      UI.SEARCH.Clear()
      UI.SEARCH.SetFocus()
    }
  }
}
