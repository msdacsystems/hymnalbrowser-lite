/*
    Interface for Search Bar
    ------------------------

    (c) 2022 MSDAC Systems
    Author: Ken Verdadero
    Written 2022-06-03
*/

class UISearchBar {
    static _NAME := "SEARCH"

    __New() {
        this.WIDTH := SW.SIZE[1] / 1.5
        this.HEIGHT := 20
        this.OBJ := UI.MAIN.GUI.AddEdit(
            Format("XS R1 W{1} H{2} +WantReturn",
                this.WIDTH, this.HEIGHT), "")
        GUIx.SetPlaceholder(this.OBJ, "Search")
    }

    SetText(text := '') => this.OBJ.Text := text                                              ;; Sets the text for the search bar
    Text(raw := false) => (raw ? this.OBJ.Text : Trim(this.OBJ.Text, ' `t`r`n'))                ;; Returns the current value of the search bar */
    HasText() => (StrLen(this.Text()) ? 1 : 0)                                                ;; Returns true if there's text in search bar except for whitespaces
    Clear() => this.OBJ.Text := ''                                                          ;; Clears the search bar
    SetFocus() => ControlFocus(this.OBJ)                                                    ;; Sets the focus to search bar
    IsEnabled() => ControlGetEnabled(this.OBJ)

    SelectAll() {
        this.SetFocus()
        Send("^A")
    }

    Listener() {
        if !this.HasText() && UI.BTN.LAUNCH.IsEnabled() && !System.IsOnModal() {            ;; Clears the Hymn text when there's no input in search
            _LOG.Verbose("Query: No text detected in search bar")
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

    RetrieveDetails(source := '') {
        if !StrLen(this.Text())
            return
        ST := A_TickCount
        REF := HymnalDB.ToHymnNumber(this.Text())                                           ;; Set a reference hymn number (000)

        if !HymnalDB.isValidHymn(this.Text(true)) {
            try REF := HymnalDB.ToHymnNumber(UI.CPLTR.GetCurrentCompletion())               ;; Substitute the first reference if text is understandable
            catch Error as e {                                                              ;; Invalid index
                UI.MAIN.ClearHymnText()
            }
        }

        /*
            Scan for Base Hymn and its equivalent hymn
        
            CT = Category (i.e: EN, TL)
        */
        CTS := ['EN', 'TL']
        for i, CT in CTS {
            EQ_CT := CTS[i = 1 ? 2 : 1]
            if ArrayMatch(REF, HYMNAL[CT][1]) {
                IDX := ArrayFind(HYMNAL[CT][1], REF)
                NUM := HYMNAL[CT][1][IDX]
                TTL := HYMNAL[CT][2][IDX]

                try {
                    EQ_NUM := HYMNAL[EQ_CT][1][IDX]
                    EQ_TTL := HYMNAL[EQ_CT][2][IDX]
                }
                catch Error {
                    EQ_NUM := 000
                    EQ_TTL := "N/A"
                }

                if this.text() = NUM ' ' TTL {                                              ;; Display the equivalent hymn if the search bar's text is complete
                    UI.MAIN.SetHymnText(Format("{1}: {2} {3}", EQ_CT, EQ_NUM, EQ_TTL))
                    UI.MAIN.HYMN.SetFont("C" SW.TEXT_DISABLED)
                } else {                                                                    ;; Display the closest hymn based on search text
                    UI.MAIN.SetHymnText(Format("{1} {2}", NUM, TTL))
                    UI.MAIN.HYMN.SetFont("C" SW.TEXT)
                }
                _LOG.Verbose(
                    Format(
                        "Query: Hymn #{1} Found at index {2} in {3} ({4} ms) | Source: {5}",
                        REF, ZFill(IDX, 3), CT, A_TickCount - ST, source
                    )
                )

                /*  Save to session data */
                SES.CURR_NUM := NUM
                SES.CURR_TTL := TTL
                SES.CURR_HYMN := NUM ' ' TTL
                SES.FILENAME := Format("{1} {2}.pptx", NUM, TTL)
                SES.HYMN_PATH := Format("{1}/{2}", CT, SES.FILENAME)

                SES.LAUNCH_READY := true
                UI.BTN.LAUNCH.SetEnabled(1)
                SES.ResetQueryTimeout()


                LaunchedAt := STS.GetStat(SES.CURR_NUM).launchedAt
                if (LaunchedAt) {
                    /* Move DETAILS to the right of HYMN text */
                    UI.MAIN.HYMN.GetPos(&HymnX, &X_, &HymnW, &H_)
                    ControlMove(HymnX + this._GetTextPixelWidth(UI.MAIN.HYMN) + 4, 33, HymnW, 20, UI.MAIN.DETAILS)
                    UI.MAIN.DETAILS.Text := Format("({1})", Utils.HumanizeISO8601Date(LaunchedAt))
                } else {
                    UI.MAIN.DETAILS.Text := ""
                }
                return
            }
        }
        UI.BTN.LaunchSetMode("NotAvailable")
        _LOG.Verbose(
            Format(
                "Query: No matching results for {1} ({2}ms)",
                this.Text(), A_TickCount - ST
            )
        )
    }

    /**
     * _GetTextPixelWidth(textCtrl)
     * 
     * Returns the pixel width of the text inside a given Text control, accurately accounting for its font.
     * 
     * @param textCtrl (GuiCtrlObj) - The AHK v2 Text control to measure.
     * @returns (Integer) - The pixel width of the control's current text.
     * 
     * Example:
     *     width := GetTextPixelWidth(MyText)
     */
    _GetTextPixelWidth(textCtrl) {
        hwnd := textCtrl.Hwnd
        text := textCtrl.Text
        hdc := DllCall("GetDC", "Ptr", hwnd, "Ptr")
        hFont := SendMessage(0x31, 0, 0, hwnd) ; WM_GETFONT
        oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")

        size := Buffer(8)
        DllCall("GetTextExtentPoint32W", "Ptr", hdc, "Str", text, "Int", StrLen(text), "Ptr", size)
        width := NumGet(size, 0, "Int")

        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
        DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", hdc)

        return width
    }
}