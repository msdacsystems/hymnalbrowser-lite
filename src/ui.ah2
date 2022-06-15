/*
    * Base Interface class for HBL
    ----------------------------
    This class handles all instance objects of the interface controls
    such as buttons, search bar, and completer.

    This class will be the API for the UI.

    To access one of UI objects, call the property:
        - UI.SEARCH.OBJ.Show()

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class UI {
    static ACTIVE := false                                                                  ;; Active status of the GUI
    static UIs := [
        /* List of all interface objects to be handled by this class */
        UIMainMenu, UISearchBar,
        UIButtons, UICompleter,
        UIContextMenu, UISettings,
    ]

    static Setup() {
        /* 
            This method defines and all available class object in interface.
            All interface objects will be a property of this UI class.

            Objects are retrieved from UI.UIs property.

            To access an interface class:
                - UI.ClassName.Method (ex: UI.MENU.Show())

            Every UI object should have:
                - "_NAME" property
                - "__new" method containing all the setup variables
        */
        ST := A_TickCount
        for classObj in UI.UIs {
            UI.DefineProp(StrUpper(classObj._NAME), {value: classObj.Call()})               ;; Initiate GUI Setup for the class; Store the class instance
        }
        UI.ConnectEvents()
        UI.StartThreads()
        UI.Keybinds()
        _LOG.Info(Format("UI: Setup finished ({1} ms)", A_TickCount-ST))
    }

    static ConnectEvents() {
        /* 
            Connects all events for every control.
            Events are forwarded to Events class.
        */
        _LOG.Verbose("UI: Connecting UI Events")
        UI.MAIN.GUI.OnEvent("Close", Events.System.Exit)
        UI.MAIN.HYMN.OnEvent("Click", Events.Hymn.Click)
        UI.MAIN.TITLE.OnEvent("Click", Events.Title.Click)
        UI.MAIN.DETAILS.OnEvent("Click", Events.Details.Click)
        UI.BTN.LAUNCH.OnEvent("Click", Events.Launch.Click)
        
        UI.BTN.CLEAR.OnEvent("Click", Events.Search.Clear)
        UI.SEARCH.OBJ.OnEvent("Change", Events.Search.TextChanged)        

        OnMessage(0x0201, ObjBindMethod(UI, "LeftMousePressEvent"))
        OnMessage(0x0204, ObjBindMethod(UI, "RightMousePressEvent"))
    }
    
    static StartThreads() {
        _LOG.Verbose("UI: Starting UI Listener Threads")
        SetTimer(ObjBindMethod(UI.SEARCH, "Listener"), 50)
        SetTimer(ObjBindMethod(UI.BTN, "Listener"), 50)
        SetTimer(ObjBindMethod(UI.CPLTR, "Listener"), SW.CPLTR_LIS_RATE)
    }
    
    static Keybinds() {
        _LOG.Verbose("UI: Binding keys")
        Hotkey("~^BackSpace", ObjBindMethod(UI.SEARCH, "KeyPress"))
        Hotkey("~^A", ObjBindMethod(UI.SEARCH, "KeyPress"))
        Hotkey("~Enter", ObjBindMethod(Events.Launch, "Click", 'ReturnKey'))
        Hotkey("~NumpadEnter", ObjBindMethod(Events.Launch, "Click", 'NumpadEnter'))
    }


    static LeftMousePressEvent(args*) {
        MouseGetPos(&X, &Y, &W, &C)
        if WinExist(System.AHK_ID) == W {
            if !UI.ACTIVE {
                _LOG.Verbose('UI: Window is activated from MouseClick')
                UI.SetActive()
            }
            UI.CPLTR.Close()                                                                ;; Close the completer if the window is starting to move
            System.MoveMain()                                                               ;; Allows the user to click-hold on the window to move
        }
    }
    
    static RightMousePressEvent(args*) {
        Events.ContextMenu.Click("RMousePressEvent")
    }

    static Hide() {
        /*  Hides the main window as well as the completer */
        UI.MAIN.GUI.Hide()
        UI.CPLTR.Close()
    }

    static Show(x:='', y:='') {
        /*
            Shows the main window.
            Automaticaly adjust the window's position if it's near edge.
        */
        try {
            if !GUIx.IsInSafeRegion(x, y, 361, 88, CF.WINDOW.MON) {                         ;; Check if the proposed coordinates is in safe region
                UI.MAIN.GUI.Show()                                                          ;; Show at center of primary monitor
                UI.UpdatePos()                                                              ;; Reupdate position with new coords
                return
            }
            UI.MAIN.GUI.Show(Format("X{1} Y{2}", x, y))                                     ;; Show in specific coordinates. Only works if arg 1 and 2 are valid.
        } catch Error as e {
            _LOG.Error(e.Message)
            UI.MAIN.GUI.Show()                                                              ;; Show at last coords when arg 1 and 2 is not specified.
        }
    }

    static UpdatePos() {
        /*  Dumps the new window coordinates to the settings */
        WinGetPos(&X, &Y,,, System.AHK_PID)
        CF.WINDOW.XPOS := X
        CF.WINDOW.YPOS := Y
        CF.WINDOW.MON := System.GetWinMonitor()
    }

    static Minimize(args*) {
        WinMinimize(System.AHK_PID)
    }

    static SetInactive() {
        /*  Sets the UI to inactive state */
        UI.ACTIVE := false
        UI.CPLTR.Close()
    }
    
    static SetActive() {
        /*  Sets the UI to an active state */
        UI.ACTIVE := true
        UI.SEARCH.SelectAll()                                                               ;; Automatically highlights all text whenever the window is reactivated
        UI.CPLTR.Close()                                                                    ;; Close the Completer
    }

    static About(args*) {
        /* Shows the about notification */
        TrayTip(Format("{1}`n{2}, {3}",
            SW.COPYRIGHT, SW.AUTHORS[1],
            SW.AUTHORS[2]), "About v" SW.VERSION, "0x24")
    }
}