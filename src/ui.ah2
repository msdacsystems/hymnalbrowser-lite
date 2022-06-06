/*
    Base Interface class for HBL
    ----------------------------
    This class handles all instance objects of the interface controls
    such as buttons, search bar, and completer.

    This class will be the API for the UI.

    To access one of UI objects, call the property:
        - UI.SEARCH.OBJ.Show()

    (c) 2022 Ken Verdadero, Reynald Ycong
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
                - a "Setup()" method.
                - "_NAME" property
                - "__new" method containing all the setup variables

            The setup method should return an instance of the class.
            
        */
        for classObj in UI.UIs {
            UI.DefineProp(StrUpper(classObj._NAME), {value: classObj.Setup()})              ;; Initiate GUI Setup for the class; Store the class instance
        }
        _LOG.Verbose("UI: UI Classes were successfully setup")
        UI.ConnectEvents()
        UI.StartThreads()
    }

    static ConnectEvents() {
        /* 
            Connects all events for every control.
            Events are forwarded to Events class.
        */
        _LOG.Verbose("UI: Connecting UI Events")
        UI.MAIN.GUI.OnEvent("Close", Events.CloseEvent)
        UI.MAIN.HYMN.OnEvent("Click", Events.Hymn.Click)
        UI.MAIN.TITLE.OnEvent("Click", Events.Title.Click)
        UI.MAIN.DETAILS.OnEvent("Click", Events.Details.Click)
        UI.BTN.LAUNCH.OnEvent("Click", Events.Launch.Click)
        
        UI.BTN.CLEAR.OnEvent("Click", Events.Search.Clear)
        UI.SEARCH.OBJ.OnEvent("Change", Events.Search.Changed)        
        UI.CPLTR.LIST.OnEvent("Change", Events.Completer.Changed)

        OnMessage(0x0201, ObjBindMethod(UI, "LeftMousePressEvent"))
        OnMessage(0x0204, ObjBindMethod(UI, "RightMousePressEvent"))
    }
    
    static StartThreads() {
        _LOG.Verbose("UI: Starting UI Listener Threads")
        SetTimer(ObjBindMethod(UI.SEARCH, "Listener"), 20)
        SetTimer(ObjBindMethod(UI.CPLTR, "Listener"), SW.CPLTR_LIS_RATE)                    ;; Start the listener thread
    }


    static LeftMousePressEvent(args*) {
        MouseGetPos(&X, &Y, &W, &C)
        if WinExist(System.AHK_PID) == W {
            if SW.VERBOSE_LOG && !UI.ACTIVE {
                _LOG.Verbose('Window is activated from LMouse')
                UI.SetActive()
            }
            System.MoveMain()                                                               ;; Allows the user to click-hold on the window to move
        }
    }
    
    static RightMousePressEvent(args*) {
        
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
}