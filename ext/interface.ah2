
Class Interface {
    __New() {
        this.setupMainUI()
        this.setupCompleterUI()
    }

    setupMainUI() {
        this.MAIN := Gui("+LastFound -MaximizeBox -Caption", SW.TITLE)
        this.MAIN.SetFont("s9", "Segoe UI")
        this.TITLE := this.MAIN.AddText("XM c004B74 W" SW.SIZE[1] " H" SW.SIZE[2]*0.18, SW.NAME)
        this.HYMN := this.MAIN.AddText("XS", "English or Tagalog Hymn Long Title")
        this.DETAILS := this.MAIN.AddText("YS c808080", "(32 minutes ago)")
        this.ENTRY := this.MAIN.AddEdit(Format("XS R1 W{1} H{2}", Entry.WIDTH, Entry.HEIGHT), "")
        this.SETTINGS := this.MAIN.AddButton("X+5 H25 W25", "•")
        this.LAUNCH := this.MAIN.AddButton("X+5 H25 W70 BackgroundTrans c008A9A", "Launch")
    }

    setupCompleterUI() {
        ;; For Line Edit Completer (Prediction GUI)
        this.CPLTR := Gui("-MaximizeBox -Caption +ToolWindow", SW.TITLE)
        WinSetTransColor("f0f0f0", this.CPLTR)
        this.CPLTR.SetFont("s9", "Segoe UI")
        this.SUGG := this.CPLTR.AddListBox(Format("W{1} H{2} -VScroll", Completer.WIDTH, Completer.HEIGHT))
    }

    static ConnectEvents() {
        ;; Connects all events
        UI.MAIN.OnEvent("Close", System.CloseEvent)
        UI.MAIN.OnEvent("Size", System.SizeEvent)
        UI.LAUNCH.OnEvent("Click", Launch.click)
        UI.SETTINGS.OnEvent("Click", Settings.click)
        UI.TITLE.OnEvent("Click", TitleBar.click)

        UI.ENTRY.OnEvent("Change", Entry.changed)
        UI.ENTRY.OnEvent("LoseFocus", Entry.loseFocus)

        UI.SUGG.OnEvent("Change", Completer.clicked)
    }

    static mainIsActive() {
        return WinActive("ahk_pid" System.getPID()) ? 1:0
    }
}

Class StatusBar {
    ;; Handles all status bar related events
    static click(event) {
        ToolRep("The user has clicked the statusbar", event)
    }
}

Class Launch {
    static click(event) {
        ToolRep("The user has clicked the launch button", event)
    }
}

Class Settings {
    static click(event) {
        ToolRep("The user has clicked the settings button", event)
    }
}

Class TitleBar {
    static click(event) {
        ;; Sends message to the window to move
        System.moveMain()
    }
}


Class Entry {
    static WIDTH := 210
    static HEIGHT := 30
    static INIT := 1                                    ;; Indicates first run

    static Listener() {
        try {
            if UI.ENTRY.Focused {
                if GetKeyState("Down", "P") {
                    Completer.select(1)
                }
                if GetKeyState("Up", "P") {
                    Completer.select(0)
                }
                if GetKeyState("Enter", "P") {
                    ; Entry.setText(UI.SUGG.Text)
                }
            }
        }
    }

    static changed(event) {
        ; if Entry.INIT {
            ; }
        ; Completer.refresh()
        ; MsgBox(Completer.BROWSING)
        if !Completer.BROWSING  {
            TEXT := ControlGetText(UI.ENTRY)
            Completer.populateItems(Core.getFilteredArray(HYMNAL["HYMNS"], UI.ENTRY.Value))
            (Completer.itemCount() > 0 ? UI.CPLTR.show(): UI.CPLTR.hide())
            Completer.updatePos()
        }
        static BROWSING := 0
    }
    static loseFocus(event) {
        if !Interface.mainIsActive() {
            Completer.hide()
        }
    }
    static setText(text) {
        ControlSetText(text, UI.ENTRY)
        Completer.searchDone()
    }
    
}


Class Completer {
    static WIDTH := Entry.WIDTH
    static HEIGHT := Entry.HEIGHT
    static ITEM_HEIGHT := 26
    static MAX_ITEMS := 5
    static BROWSING := 0

    static Listener() {
        try {
            if UI.SUGG.Focused {
                ; KeyWait("L", "D T0.1")
                Entry.setText(UI.SUGG.Text)

            }
        }
    }

    static setup() {
        Completer.populateItems(HYMNAL["HYMNS"])
        Completer.updatePos()
    }

    static Hide() {
        try UI.CPLTR.Hide()
    }
    static Show() {
        try UI.CPLTR.Show()
    }
    static Select(Mode) {
        try {
            UI.SUGG.Choose(UI.SUGG.Value+(Mode ? 1:-1))
        } catch Error {
            UI.SUGG.Choose(Mode ? 1:Completer.itemCount())
        }
        Completer.BROWSING := 1
        ControlSetText(UI.SUGG.Text, UI.ENTRY)
    }
    
    static itemCount() {
        return SendMessage(0x18B, 0, 0, UI.SUGG, SW.TITLE)
    }
    static updatePos() {
        System.getPosInfo(&X, &Y, &W, &H)
        UI.CPLTR.GetPos(&XC, &YC, &WC, &HC)
        UI.CPLTR.Move(X, Y+(H*0.95), WC, HC)
        UI.MAIN.Show()
    }
    static clicked(event) {
        ; MsgRep(event)
        ; MsgRep(UI.SUGG.value)
    }
    static refresh() {
        ; UI.CPLTR.GetPos(&X, &Y, &W, &H)
        ; UI.CPLTR.Move(X, Y, W, Completer.HEIGHT)
        ; UI.CPLTR.Destroy()
        UI.setupCompleterUI()
    }
    static searchDone() {
        UI.CPLTR.Destroy()
        UI.setupCompleterUI()
        Completer.Hide()
    }
    static populateItems(Arr) {
        Completer.Hide()
        if Arr.Length <= 0 {
            tooltipX("No results found.", 2)
            Completer.searchDone()
        } else {
            Completer.HEIGHT := (Completer.ITEM_HEIGHT * (Arr.Length > Completer.MAX_ITEMS ? Completer.MAX_ITEMS:Arr.Length))
            Completer.refresh()
            UI.SUGG.Opt("-Redraw")
            UI.SUGG.Add(Arr)
            UI.SUGG.Opt("+Redraw")
            tooltipX(Completer.itemCount() " hymn " (Completer.itemCount() == 1 ? "suggestion":"suggestions"), 1)
        }
    }
}