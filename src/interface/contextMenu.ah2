/*
    Right-click Context menu for HBL
    --------------------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-05
*/

Class UIContextMenu {
    static _NAME := "RCTX"

    static Setup() {
        return UIContextMenu()
    }

    __New() {
        this.OBJ := Menu()
        /*  Items below are for development mode only */
        if System.DEV_MODE {
            this.OBJ.Add("Open &Script Directory", ObjBindMethod(this, "_DevItems", 1))
            this.OBJ.Add("Open &Program Directory", ObjBindMethod(this, "_DevItems", 2))
            this.OBJ.Add("Open Program &Docs Directory", ObjBindMethod(this, "_DevItems", 3))
            this.OBJ.Add()
        }
        /*  --- End of developer options --- */

        ; this.VER := this.OBJ.Add(SW.COPYRIGHT, PlaceholderCallback)
        ; this.OBJ.Disable(SW.COPYRIGHT)
        ; this.OBJ.Add()
        ; this.OBJ.Add("&Settings", Events.Settings.Click)                                  ;; Temporarily turned off until Settings UI is complete
        this.OBJ.Add("&Minimize", ObjBindMethod(UI, "Minimize"))
        this.OBJ.Add()
        this.OBJ.Add("&About", ObjBindMethod(UI, "About"))
        this.OBJ.Add("&Exit", System.CloseEvent)
    }

    ShowMenu() {
        _LOG.Verbose("ContextMenu: Context menu was opened")
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