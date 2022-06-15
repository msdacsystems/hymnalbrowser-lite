/*
    Background Thread
    -------------------
    A thread collection for HBL

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-04
*/

class BackgroundThread {                                                              ;; Measured in milliseconds
    static Setup() {
        /*
            Automatically connects all methods to a timer thread.
            Excluding this Setup method.

            Refresh rates are specified by the REFRESH_RATE
        */
        methods := []                                                                       ;; Methods to be listed
        for i in BackgroundThread.OwnProps() {                                              ;; Get method list of this class
            if !ArrayMatch(i, ["__init", "prototype", "setup"]) {
                methods.Push(i)
            }
        }
        for method in methods {                                                             ;; Connect all methods to its background task
            if SubStr(method, 1, 2) == '__' {                                               ;; Ignore methods that have '__' prefix because they have custom refresh time
                continue
            }
            SetTimer(
                ObjBindMethod(BackgroundThread, method),
                SW.BG_REF_RATE
            )
        }
        
        SetTimer(ObjBindMethod(BackgroundThread, '__HymnStats'), 1000)                      ;; Hymn Statistics
    }

    static WindowListener() {
        /*
            Background listener for window.
            Checks if the main window is on focus.

            Used by UI.CPLTR, and UI class.
        */

        if !System.IsActive() && UI.ACTIVE && !System.HasCrashed() {
            _LOG.Verbose('BackgroundThread: Window is inactive')
            UI.SetInactive()
        }

        if System.IsActive() && !UI.ACTIVE && !System.IsOnModal() {
            _LOG.Verbose('BackgroundThread: Window is activated')
            UI.SetActive()
        }

        if UI.MAIN.WasMoved() and !GetKeyState("LButton", 'P') {
            WinGetPos(&X, &Y,,, System.AHK_TITLE)
            if !System.IsOnModal()
                _LOG.Verbose(Format(
                "BackgroundThread: Main window was moved. "
                "New window position: X:{1} Y:{2}", X, Y)
            )
            UI.UpdatePos()
            UI.MAIN.SetMoving(0)
        } 
    }

    static LaunchButton() {
        /*  Delayed setting of mode via keyboard time idle */
        if SES.LAUNCH_READY and A_TimeIdleKeyboard > 1250 {                                 ;; Make a delay before setting the text back to ready mode
                UI.BTN.LaunchSetMode("Ready")
        }
        if UI.BTN.LAUNCH.Text == "Launching" and A_TimeIdleKeyboard > 750 {                 ;; Time allowance before concluding the launch/ready mode
                UI.BTN.LaunchSetMode("Launched")
        }
    }

    static __HymnStats() {
        /* 
            Handles session hymn stats such as queries
        */
        if !SES.TME_QUERY {
            if UI.SEARCH.HasText() and SES.LAST_QUERIED != SES.CURR_HYMN {
                SES.COUNT_QUERY++
                SES.LAST_QUERIED := SES.CURR_HYMN
                _LOG.Verbose(
                    Format("Background: Query was incremented: {1} | Hymn: {2}",
                    SES.COUNT_QUERY, SES.CURR_HYMN)
                )
            }
            SES.TME_QUERY := CF.TME_QUERY
        }
        SES.TME_QUERY--
    }
}