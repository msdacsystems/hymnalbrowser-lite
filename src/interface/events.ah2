/*
    Event handler and forwarder for interface
    -------------------------------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class Events {
    static CloseEvent(args*) {
        /* System Exit */
        System.CloseEvent()
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
            if !System.IsActive() {
                return
            }
            UI.RCTX.ShowMenu()
        }
    }

    class Launch {
        static Click(source, hk:='') {
            if !System.IsActive() or !ControlGetEnabled(UI.BTN.LAUNCH) {
                return
            }
            source := (!source ? 'MouseReleaseEvent':source)
            _LOG.Verbose("Events: Launch button was pressed. From: " source)
            Launcher.Launch()
        }
    }

    class Settings {
        static Click(args*) {
            UI.SETTINGS.Show()
        }
    }
    
    class Search {
        static Changed(args*) {
            UI.CPLTR.ScanSearchBar()
            UI.SEARCH.RetrieveDetails()
        }
        static Clear(args) {
            _LOG.Verbose("Events: Search bar was cleared")
            UI.SEARCH.Clear()
            UI.SEARCH.SetFocus()
        }
    }
}