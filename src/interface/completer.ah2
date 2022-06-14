/*
    Completer GUI for Search bar
    -----------------------------
    A customized ListBox as a line completer suggestion box.

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-04
*/

Class UICompleter {
    static _NAME := "CPLTR"

    __New() {
        this.WIDTH := UI.SEARCH.WIDTH
        this.HEIGHT := UI.SEARCH.HEIGHT
        this.TITLE := "HBL Completer"
        this.MAX_ITEMS := SW.CPLTR_MAX_ITEMS
        this.ITEM_HEIGHT := 25                                                              ;; Size of a single item measured in pixels
        this.DATA := Object()
        this.DATA.DefineProp("LIT", {value: []})                                            ;; Array of the items in completer (List Items / LIT)
        this.DATA.DefineProp("IDX", {value: 0})                                             ;; Cached index number of completer
        this.DATA.DefineProp("FCS", {value: ''})                                            ;; Cached current item text of completer
        this.ACTIVE := false
        this.REQUEST_SEARCH_UPDATE := false                                                 ;; Search updater indicator; when turned on, the listener will change the text according to the recent IDX
        
        this.Update(true)                                                                   ;; Update the completer for the first time

        /* Binds all hotkeys to their corresponding keypress mode */
        Hotkey('~Esc', ObjBindMethod(this, "KeyPress", "Close"))
        Hotkey('~Tab', ObjBindMethod(this, "KeyPress", "Close"))
        Hotkey('~Up', ObjBindMethod(this, "KeyPress", "PrevItem"))
        Hotkey('~Down', ObjBindMethod(this, "KeyPress", "NextItem"))
        Hotkey('~WheelUp', ObjBindMethod(this, "KeyPress", "WheelUp"))
        Hotkey('~WheelDown', ObjBindMethod(this, "KeyPress", "WheelDown"))
        Hotkey('~LButton Up', ObjBindMethod(this, "KeyPress", "LButton Up"))
    }
    
    Update(init:=false) {
        /*
            Updates the Completer window.
            This method is used when dynamically resizing the listbox.

            This is due to the limitation that AHK cannot redraw—
            the listbox unless it's destroyed and created again.
        */
        this.Close()
        this.OBJ := Gui("-Caption +ToolWindow", this.TITLE)                                 ;; Completer GUI Object
        this.OBJ.SetFont("S" SW.GLB_FONT_SIZE, SW.GLB_FONT_NAME)
        this.LIST := this.OBJ.AddListBox(Format("W{1} H{2} -VScroll",                       ;; List box inside the completer.
                                        this.WIDTH, this.HEIGHT))
        WinSetTransColor("f0f0f0", this.OBJ)                                              ;; Make the list box only visible

        if init {                                                                           ;; Initial completer setup
            this.ACTIVE := false                                                            ;; Don't activate the completer yet.
        } else {
            this.GetSpawnPoint(&X, &Y)
            this.ACTIVE := true
            this.OBJ.show(Format("X{1} Y{2}", X, Y))
        }
    }

    ScanSearchBar() {
        /*
            Handles TextChangedEvent for completer.
            Forwarded from Events.Search.Changed

            Scans the search bar's value and filters the hymns according
            to the current search bar's text using ArrayFilter().
        */
        try this.OBJ.Hide()                                                                 ;; Hide the completer 
        if !StrLen(UI.SEARCH.Text()) {                                                      ;; If the search bar is empty
            ToolTip('')                                                                     ;; Clear tooltips and the status bar
            UI.MAIN.ShowStatus('')
            return this.Close()
        }

        FILTERED := ArrayFilter(HYMNAL["HYMNS"], UI.SEARCH.Text(), 'Contains')              ;; Retrieve all matching hymns from the search bar keyword
        FLEN := FILTERED.Length        

        if FLEN <= 0 {                                                                      ;; When there's no matching results
            UI.MAIN.ShowStatus('')
            UI.MAIN.ClearHymnText()
            return this.Close()
        }
            
        this.HEIGHT := (this.ITEM_HEIGHT * (FLEN > this.MAX_ITEMS ? this.MAX_ITEMS:FLEN))   ;; Calculates the new height for the completer's ListBox
        this.Update()                                                                       ;; Reinitalize a new completer GUI
        
        try {
            this.LIST.Opt("-Redraw")                                                        ;; Turn off redraw before adding the items
            this.LIST.Add(FILTERED)                                                         ;; Appends all filtered/matched hymns to the list box
            this.LIST.Opt("+Redraw")
        }

        System.SetActive()                                                                  ;; Responsible for keeping the focus on main window
        
        SES.SUGGESTIONS := FLEN                                                             ;; Update item count data (List Size); Sets suggestion count
        this.DATA.LIT := FILTERED                                                           ;; Update items array (List Items)
        
        UI.BTN.LaunchSetMode("ShowSuggestions")
    }


    Listener() {
        /*
            UICompleter Listener thread
            ----------------------------
            Keeps track of the index and text value of the ListBox.
            This method is responsible for keeping the hymn entry same
            with the selection in list box.

            The way listener updates the search bar is when the keystrokes
            are pressed and requested for changes.
        */
        if this.ACTIVE {                                                                    ;; Only record an index and text value if the completer is present & active
            try {
                this.DATA.IDX := this.LIST.Value
                this.DATA.FCS := this.LIST.Text
            } catch Error as e {
                _LOG.Error("UICompleter: " e.Message)
            }
        }

        if this.REQUEST_SEARCH_UPDATE {
            this.REQUEST_SEARCH_UPDATE := false
            UI.SEARCH.SetText(this.DATA.FCS)                                                ;; Apply the new focused item's text to the search bar
            Send("{End}")                                                                   ;; Keep text cursor at the end of the search bar
            UI.SEARCH.RetrieveDetails("CompleterRequest")
        }
    }

    KeyPress(key, hk) {
        /*
            Handles keystrokes and shortcut for the completer.
            The main window must be active to trigger the keypresses.

            Includes:
                - Ctrl+A (Select all)
                - Up, Down, Left, Right (Navigation)
                - Tab (Next Control)
                - Click (Selecting an item)
        */
        if !System.IsActive() or !this.ACTIVE {                                             ;; Ignore if the main window or the completer is inactive
            return
        }

        if ArrayMatch(key, ['PrevItem', 'NextItem', 'WheelUp', 'WheelDown']) {              ;; Handles behavior of Previous and Next item in completer (ListBox)
            if ArrayMatch(key, ['WheelUp', 'WheelDown']) {
                if !System.IsFocused() && !this.IsFocused() {                               ;; Prevent scrolling of list when the mouse is not on top of the window
                    return
                }
            }
            try {
                switch (ArrayMatch(key, ['NextItem', 'WheelDown']) ? 1:0) {
                    case 0: 
                        (this.DATA.IDX ? this.DATA.IDX--:0)                                 ;; Previous item
                    case 1:
                        (this.DATA.IDX < this.DATA.LIT.Length ? this.DATA.IDX++:0)          ;; Next item
                }
                this.LIST.Choose(this.DATA.IDX)                                             ;; Focus the next item
                if this.DATA.IDX && this.DATA.LIT[this.DATA.IDX] != UI.SEARCH.Text() {      ;; Prevent search request for if same item is queried
                    this.REQUEST_SEARCH_UPDATE := true                                      ;; Request an update of search bar for the listener
                } 
            } catch Error as e {
                _LOG.Error('UICompleter: Unable to process item actions. ' e.Message)
                _LOG.Error("UICompleter: Source trigger: " key)
                _LOG.Error("UICompleter: Current List Size: " SES.SUGGESTIONS)
                _LOG.Error("UICompleter: Current Index: " this.DATA.IDX)
                _LOG.Error("UICompleter: Current Focused Item: " this.DATA.FCS)
                _LOG.Error("UICompleter: Matched Items: " ArrayAsStr(this.DATA.LIT))
            }
        }

        if Key == "Close" {                                                                 ;; Closes the completer if the tab is pressed.
            this.Close()
        }

        if ArrayMatch(key, ['LButton Up', 'LButton Down']) {                                ;; Simulates an action when clicking on an item.
            if this.IsFocused() {                                                           ;; Only request for an update if the completer is focused
                this.REQUEST_SEARCH_UPDATE := true                                          ;; Request for changes
            }
            this.Close()                                                                    ;; Close the completer after picking.
        }
    }

    Close() {
        /*
            Destroys the completer.

            The text value is unaffected to preserve the search bar's value.
            This is due to the listener is running and any changes to the cached text
            will reflect to the search bar.
            
        */
        if !this.ACTIVE                                                                     ;; Ignore when the completer is already destroyed
            return
        this.ACTIVE := false
        this.DATA.IDX := 0                                                                  ;; Sets back the recent index to 0
        this.DATA.LIT := []
        try this.OBJ.Destroy()
    }

    IsFocused() {
        /*  Returns focus state of the completer */
        if !this.ACTIVE
            return 0
        MouseGetPos(&X, &Y, &W, &C)
        return (WinExist(this.OBJ) = W ? 1:0)
    }

    GetSpawnPoint(&X, &Y) {
        /*
            Determines where to show up the completer.
            This method considers edge regions.
        */
        WinGetClientPos(&X, &Y, &W, &H, SW.NAME)
        Y += 81                                                                             ;; Offset from the search bar
    }

    GetCurrentCompletion() {
        /*  Returns the first index from the completion */
        if !this.ACTIVE
            return ''
        return this.DATA.LIT[1]
    }
}