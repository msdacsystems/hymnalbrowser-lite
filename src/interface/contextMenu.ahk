/**
 * * Right-click Context menu for HBL
 * --------------------------------
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2022-06-05
 */
class UIContextMenu {
  static _NAME := "RCTX"

  __New() {
    this.OBJ := Menu()
    if System.DEV_MODE {
      /* For development mode only */
      this.OBJ.Add("Dev &Tools", ObjBindMethod(this, "_DevItems", 0))
      this.OBJ.Disable("Dev &Tools")
      this.OBJ.Add("Open &Script Directory", ObjBindMethod(this, "_DevItems", 1))
      this.OBJ.Add("Open &Program Directory", ObjBindMethod(this, "_DevItems", 2))
      this.OBJ.Add("Open Program &Docs Directory", ObjBindMethod(this, "_DevItems", 3))
      this.OBJ.Add()
    }
    this.OBJ.Add("&Settings", Events.Settings.Click)
    this.OBJ.Add("&Minimize", ObjBindMethod(UI, "Minimize"))
    this.OBJ.Add()
    this.OBJ.Add("Open &Website", ObjBindMethod(UI, "OpenWebsite"))
    this.OBJ.Add("&Check for Updates", ObjBindMethod(Events.System, "CheckUpdates"))
    this.OBJ.Add("&About", ObjBindMethod(UI, "About"))
    this.OBJ.Add("&Exit", ObjBindMethod(Events.System, "Exit", 0, "Hi"))
  }

  ShowMenu() {
    Console.Verbose("ContextMenu: Context menu was opened")
    UI.CPLTR.Close()
    ;; disable manual update check while downloading
    if UPT && UPT.IsDownloading() {
      this.OBJ.Disable("&Check for Updates")
    } else {
      this.OBJ.Enable("&Check for Updates")
    }
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
