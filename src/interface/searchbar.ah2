/*
    Interface for Search Bar
    ------------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-03
*/

class UISearchBar {
    static _NAME := "SEARCH"

    static Setup() {
        return UISearchBar()
    }

    __New() {
        this.WIDTH := SW.SIZE[1]/1.5
        this.HEIGHT := 20
        this.OBJ := UI.MAIN.GUI.AddEdit(
            Format("XS R1 W{1} H{2} +WantReturn",
            this.WIDTH, this.HEIGHT), "")

        SetTimer(ObjBindMethod(this, "Listener"), 20)

        Hotkey("~^BackSpace", ObjBindMethod(this, "KeyPress"))
        Hotkey("~^A", ObjBindMethod(this, "KeyPress"))
    }

    SetText(text:='') {
        /*  Sets the text for the search bar */
        if Type(text) != "String"
            return
        this.OBJ.Text := text
    }

    Text(raw:=false) {
        /*  Returns the current value of the search bar */
        return (raw ? this.OBJ.Text:Trim(this.OBJ.Text, ' `t`r`n'))
    }

    Clear() {
        /*  Clears the search bar */
        this.OBJ.Text := ''
    }

    SetFocus() {
        /*  Sets the focus to search bar */
        ControlFocus(this.OBJ)
    }

    SelectAll() {
        this.SetFocus()
        Send("^A")
    }

    Listener() {
        if !StrLen(this.text()) {                                                           ;; Clears the Hymn text when there's no input in search
            UI.MAIN.ClearHymnText()
            try UI.BTN.LAUNCH.Text := "Insert Hymn"
            try UI.BTN.LaunchSetEnabled(0)
            try (UI.CPLTR.ACTIVE ? UI.CPLTR.Close():0)
        }
    }

    KeyPress(key) {
        if !System.IsActive()
            return
        switch key {
            case "~^BackSpace":                                                             ;; Ctrl+Backspace for removing a word
                if !StrLen(this.Text())
                    return
                TEXT := StrSplit(this.Text(), ' ')
                TEXT.RemoveAt(-1)                                                           ;; Remove the last word
                this.SetText(Join(TEXT, ' '))
                Send("{BackSpace}")                                                         ;; Remove the del key created by Ctrl+Backspace
                Send("{End}")                                                               ;; Put the cursor at the end of the search text

            case "~^A":                                                                     ;; Ctrl+A for selecting all text in the search bar
                if !System.IsFocused()
                    return
                this.SetFocus()
                Send("^A")
        }
    }

    RetrieveDetails() {
        if !StrLen(this.text())
            return
        ST := A_TickCount
        REF := HymnalDB.ToHymnNumber(this.text())
        
        if !HymnalDB.isValidHymn(this.Text(true)) {
            try REF := HymnalDB.ToHymnNumber(UI.CPLTR.GetCurrentCompletion())               ;; Substitute the first reference
            catch Error {
                UI.MAIN.ClearHymnText()
            }
        }
        
        
        /*
            Scan for Base Hymn and its equivalent hymn
        */
        DC := ['EN', 'TL']
        for i, SQ in DC {
            EQ_SQ := DC[Inv(i)]
            if ArrayMatch(REF, HYMNAL[SQ][1]) {
                IDX := ArrayFind(HYMNAL[SQ][1], REF)
                NUM := HYMNAL[SQ][1][IDX]
                TTL := HYMNAL[SQ][2][IDX]
                try {
                    EQ_NUM := HYMNAL[EQ_SQ][1][IDX]
                    EQ_TTL := HYMNAL[EQ_SQ][2][IDX]
                }
                catch Error {
                    EQ_NUM := 000
                    EQ_TTL := "N/A"
                }
                
                if this.text() = NUM ' ' TTL {
                    UI.MAIN.SetHymnText(Format("{1}: {2} {3}", EQ_SQ, EQ_NUM, EQ_TTL))
                    UI.MAIN.HYMN.SetFont("C" SW.TEXT_DISABLED)
                } else {
                    UI.MAIN.SetHymnText(Format("{1} {2}", NUM, TTL))
                    UI.MAIN.HYMN.SetFont("C" SW.TEXT)
                }
                if SW.VERBOSE_LOG {
                    _LOG.Verbose(Format("Query: Hymn #{1} Found at index {2} in {3} ({4} ms)",
                                REF, ZFill(IDX, 3), SQ, A_TickCount-ST))
                }
                
                /*  Save to session data */
                SES.CURR_NUM := NUM
                SES.CURR_TTL := TTL
                SES.FILENAME := Format("{1} {2}.pptx", NUM, TTL)
                SES.HYMN_PATH := Format("{1}/{2}", SQ, SES.FILENAME)
                ; (SW.VERBOSE_LOG ? SES._GetCurrentData():0)

                UI.BTN.LAUNCH.Text := "Launch"
                UI.BTN.LaunchSetEnabled(1)
                return
            }
        }
        UI.BTN.LAUNCH.Text := "Not Available"
        UI.MAIN.SetHymnText(Format("No matching results for '{1}'", UI.SEARCH.Text()))
        UI.MAIN.HYMN.Opt('C' SW.TEXT_DISABLED)
        UI.BTN.LaunchSetEnabled(0)

    }
}