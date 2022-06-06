/*
    Background thread for HBL
    -------------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-04
*/


class BackgroundThread {
    static REFRESH_RATE := 20                                                               ;; Measured in milliseconds
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
            SetTimer(
                ObjBindMethod(BackgroundThread, method),
                BackgroundThread.REFRESH_RATE
            )
        }
        
        /* Keybindings; might move to a separate class */
        Hotkey("~RButton", ObjBindMethod(Events.ContextMenu, "Click", 'RButton'))
        Hotkey("~Enter", ObjBindMethod(Events.Launch, "Click", 'ReturnKey'))
        Hotkey("~NumpadEnter", ObjBindMethod(Events.Launch, "Click", 'NumpadEnter'))
    }

    static WindowListener() {
        /*
            Background listener for window.
            Checks if the main window is on focus.

            Used by UI.CPLTR, and UI class.
        */

        if !System.IsActive() && UI.ACTIVE {
            (SW.VERBOSE_LOG ? _LOG.Verbose('BackgroundThread: Window is inactive'):0)
            UI.SetInactive()
        }

        if System.IsActive() && !UI.ACTIVE {
            (SW.VERBOSE_LOG ? _LOG.Verbose('BackgroundThread: Window is activated'):0)
            UI.SetActive()
        }
    }

    static LaunchButton() {
        if !System.IsActive()
            return
        if SES.LAUNCH_READY and A_TimeIdleKeyboard > 1250 {                                 ;; Make a delay before setting the text back to ready mode
            UI.BTN.LaunchSetMode("Ready")
        }
    }
}