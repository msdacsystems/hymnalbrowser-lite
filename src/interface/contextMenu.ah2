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
        ; this.VER := this.OBJ.Add(SW.COPYRIGHT, PlaceholderCallback)
        ; this.OBJ.Disable(SW.COPYRIGHT)
        ; this.OBJ.Add()
        this.OBJ.Add("&Settings", Events.Settings.Click)
        this.OBJ.Add("&Exit", System.CloseEvent)
    }

    ShowMenu() {
        (SW.VERBOSE_LOG ? _LOG.Debug("ContextMenu: Context menu was opened"):0)
        this.OBJ.Show()
    }
}