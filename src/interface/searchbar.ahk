/**
 * * Interface for Search Bar
 * ------------------------
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2022-06-03
 */
class UISearchBar {
  static _NAME := "SEARCH"

  __New() {
    this.WIDTH := SW.SIZE[1] / 1.5
    this.HEIGHT := 27
    this.OBJ := UI.MAIN.GUI.AddEdit(
      Format("XS  W{1} H{2} +WantReturn",
        this.WIDTH, this.HEIGHT), "")
    this.OBJ.SetFont("S" SW.GLB_FONT_SIZE, SW.GLB_FONT_NAME)
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
      Console.Verbose("Query: No text detected in search bar")
    }
  }

  KeyPress(key) {
    if !System.IsActive()
      return
    switch key {
      case "~^A":                                                                     ;; Ctrl+A for selecting all text in the search bar
        if !System.IsFocused()
          return
        this.SelectAll()
    }
  }

  RetrieveDetails(source := '') {
    query := this.Text()
    if !StrLen(query)
      return
    ST := A_TickCount
    result := HymnSearchService.Query(query)
    if !result {
      UI.MAIN.ClearHymnText()
      UI.BTN.LaunchSetMode("NotAvailable")
      Console.Verbose(Format("Query: No matching results for {1} ({2}ms)", query, A_TickCount - ST))
      return
    }
    this._ProcessHymnResult(result, source, ST)
  }

  _ProcessHymnResult(result, source, ST) {
    if this.text() = result.NUM ' ' result.TTL {
      UI.MAIN.SetHymnText(Format("{1}: {2} {3}", result.EQ_CT, result.EQ_NUM, result.EQ_TTL))
      UI.MAIN.HYMN.SetFont("C" SW.TEXT_DISABLED)
    } else {
      UI.MAIN.SetHymnText(Format("{1} {2}", result.NUM, result.TTL))
      UI.MAIN.HYMN.SetFont("C" SW.TEXT)
    }
    Console.Verbose(Format("Query: Hymn #{1} Found at index {2} in {3} ({4} ms) | Source: {5}", result.REF, ZFill(result.IDX, 3), result.CT, A_TickCount - ST, source))

    SES.ProcessSearchResult(result)
    SES.LAUNCH_READY := true
    UI.BTN.LAUNCH.SetEnabled(1)
    SES.ResetQueryTimeout()

    LaunchedAt := STS.GetStat(result.NUM).launchedAt
    if (LaunchedAt) {
      /* Move DETAILS to the right of HYMN text */
      UI.MAIN.HYMN.GetPos(&HymnX, &X_, &HymnW, &H_)
      ControlMove(HymnX + this._GetTextPixelWidth(UI.MAIN.HYMN) + 4, 33, HymnW, 20, UI.MAIN.DETAILS)
      UI.MAIN.DETAILS.Text := Format("({1})", Utils.HumanizeISO8601Date(LaunchedAt))
    } else {
      UI.MAIN.DETAILS.Text := ""
    }
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
