/*
    Event handler and forwarder for interface
    -------------------------------------------

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class Events {
    class System {
        static Exit(exitCode:=0, message:='Application exited due to an error') {
            /*
                System Exit
                Handles events for application exit.
            */
            try RT := Round((A_TickCount-_RUNTIME)/1000, 3)                                     ;; Running time of the software
            catch Error {
                RT := Round((A_TickCount-_STARTUP)/1000, 3)
            }

            FileManagement.CloseTemp()
            try SES.EndSession()

            if !exitCode or exitCode == 2 {
                _LOG.info("System: The user has closed the program")
                _LOG.info("System: Application exited. Running time: " RT " second(s)")
            } else if exitCode == 10 {                                                      ;; Exit Code 10 - System reload
                _LOG.info("System: System requested an application reload")
                _LOG.info("System: Application will reload. Running time: " RT " second(s)")
                _LOG.Close()
                Reload()
                return
            } else {
                _LOG.error(Format(
                    "System: Exit code {1}; Reason: {2}; Running time: {3} second(s)",
                    exitCode, message, RT)
                )
            }

            _LOG.Close()                                                                        ;; Close the log
            ExitApp(exitCode)
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
        static Click(source, hk:='') {
            if !UI.SETTINGS.IsOpened() {
                UI.RCTX.ShowMenu()
            }
        }
    }

    class Launch {
        static Click(source, hk:='') {
            if !System.IsActive() or !ControlGetEnabled(UI.BTN.LAUNCH) {
                return
            }
            source := (!source ? 'MouseReleaseEvent':source)
            _LOG.Verbose("Events: Launch button was pressed. | Source: " source)
            Launcher.Launch()
        }
    }

    class Settings {
        static Click(args*) => UI.SETTINGS.Show()
        static CloseEvent(args*) => UI.SETTINGS.Hide() 

        static ToggleCheck(chkObj, cfgKey, args*) {
            chkObj.SetChecked(chkObj.CheckState() ? 1:0)
            switch cfgKey {
                case 'FBK': CF.LAUNCH.FOCUS_BACK := chkObj.CheckState()
                case 'SLD': CF.LAUNCH.TYPE := chkObj.CheckState()
                case 'AOT': 
                    CF.WINDOW.ALWAYS_ON_TOP := chkObj.CheckState()
                    UI.MAIN.GUI.Opt((chkObj.CheckState() ? '+':'-') "AlwaysOnTop")
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
            _LOG.Verbose("Events: Search bar was cleared")
            UI.SEARCH.Clear()
            UI.SEARCH.SetFocus()
        }
    }
}