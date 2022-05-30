; #include software.ah2

Class System {
    /*
        Handles all process and system events
    */
    __New() {
       this.INIT := "Hymnal Browser"
    }
    static CloseEvent() {
        ;; When the user closed the software
        try UI.CPLTR.Destroy()
        ToolRep("The user has closed the program")
    }
    static SizeEvent(WinStatus, W, H) {
        UI.MAIN.GetPos(&X, &Y)
        UI.MAIN.Move(X, Y, SW.SIZE[1], SW.SIZE[2])
    }
    static getPosInfo(&X, &Y, &W, &H) {
        UI.MAIN.GetPos(&XA, &YA, &WA, &HA)
        X := XA
        Y := YA
        W := WA
        H := HA
    }
    static getPID() {
        try PID := WinGetPID(SW.NAME)
        catch Error
            PID := 0x0
        return PID
    }
    static moveMain() {
        Completer.updatePos()
        Completer.hide()
        PostMessage(0xA1, 2,,, "A")
    }
}