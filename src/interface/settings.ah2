/*
    Settings GUI for HBL
    --------------------

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-05
*/

Class UISettings {
    static _NAME := "SETTINGS"

    __New() {
        this.WIDTH := 280
        this.HEIGHT := 350
        this.OBJ := Gui("+AlwaysOnTop +ToolWindow", "Settings")
        this.OBJ.SetFont('Q5 S' SW.GLB_FONT_SIZE, SW.GLB_FONT_NAME)
        this.OBJ.BackColor := 0xFFFFFF
        this.OBJ.AddText("", "Settings")
    }

    Show() {
        _LOG.Debug("UISettings: Settings was opened.")
        this.OBJ.Show(Format("W{1} H{2}", this.WIDTH, this.HEIGHT))
    }
}