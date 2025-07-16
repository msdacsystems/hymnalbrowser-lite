/**
 * 
 * * Session data for HBL
 * ----------------------------
 * Contains session data.
 * Works similarly to Config class but this handles only the data in current session.
 * All data after application exit will be erased as they are not used or will be
 * already uploaded to stats file.
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2022-06-06
 */
class Session {
  static Setup() {
    return Session()
  }

  __New() {
    Console.Info('Session: Session data was started.')
    this.GenerateProps()
  }

  GenerateProps() {
    this.DATA := {
      CURR_NUM: 0,
      CURR_TTL: '',
      CURR_HYMN: '',
      HYMN_PATH: '',
      FILENAME: '',
      SUGGESTIONS: 0,
      LAUNCH_READY: false,
      COUNT_LAUNCH: 0,
      COUNT_QUERY: 0,
      LAST_QUERIED: '',
      TME_QUERY: CF.TME_QUERY,
    }

    for name, val in this.DATA.OwnProps() {
      this.DefineProp(name, {
        value: val
      })
    }
  }

  _GetCurrentData() {
    /*
        Lists all session properties and their values.
        This is only for development and debugging.
    */
    Console.Verbose("Listing current session data")
    for i in this.OwnProps() {
      if i == "DATA" {                                                                ;; Ignore data property
        A_Index--
        continue
      }
      Console.Verbose(Format("({1}/{2}) {3} -> {4}",
        A_Index, this.DATA.Capacity, i, this.GetOwnPropDesc(i).Value))
    }
  }

  /**
   * Sends a report to logger during application exit
   */
  _SendEndReport() {
    if this.COUNT_LAUNCH {
      Console.Info(Format("Session: Launched {1} file(s) at end of session",
        this.COUNT_LAUNCH))
    }
    if this.COUNT_QUERY {
      Console.Info(Format("Session: Queried {1} hymn(s) at end of session",
        this.COUNT_QUERY))
    }
  }

  /*  Resets the query timeout */
  ResetQueryTimeout() {
    this.TME_QUERY := CF.TME_QUERY
  }

  /*  Executes several instructions about closing the session */
  EndSession() {
    UI.UpdatePos()
    CF.Dump()
    this._SendEndReport()
  }

  /**
   * Processes the search result and updates the session data.
   */
  ProcessSearchResult(data) {
    SES.CURR_NUM := data.NUM
    SES.CURR_TTL := data.TTL
    SES.CURR_HYMN := data.NUM ' ' data.TTL
    SES.FILENAME := Format("{1} {2}.pptx", data.NUM, data.TTL)
    SES.HYMN_PATH := Format("{1}/{2}", data.CT, SES.FILENAME)
  }
}
