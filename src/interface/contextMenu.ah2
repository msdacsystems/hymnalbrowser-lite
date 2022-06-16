/*
    Right-click Context menu for HBL
    --------------------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-05
*/

Class UIContextMenu {
    static _NAME := "RCTX"

    __New() {
        this.OBJ := Menu()
        if System.DEV_MODE {
            /* For development mode only */
            this.OBJ.Add("Open &Script Directory", ObjBindMethod(this, "_DevItems", 1))
            this.OBJ.Add("Open &Program Directory", ObjBindMethod(this, "_DevItems", 2))
            this.OBJ.Add("Open Program &Docs Directory", ObjBindMethod(this, "_DevItems", 3))
            this.OBJ.Add()
        }
        this.OBJ.Add("&Settings", Events.Settings.Click)
        this.OBJ.Add("&Minimize", ObjBindMethod(UI, "Minimize"))
        this.OBJ.Add()
        this.OBJ.Add("&About", ObjBindMethod(UI, "About"))
        this.OBJ.Add("&Exit", Events.System.Exit)
    }

    ShowMenu() {
        _LOG.Verbose("ContextMenu: Context menu was opened")
        UI.CPLTR.Close()
        this.OBJ.Show()
    }

    _DevItems(item, args*) {
        switch item {
            case 1: OpenFolder(A_ScriptDir)
            case 2: OpenFolder(SW.DIR_PROGRAM)
            case 3: OpenFolder(SW.DIR_DOCS_PROGRAM)
        }
    }
}