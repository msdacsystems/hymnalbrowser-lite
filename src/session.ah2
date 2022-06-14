/*
    * Session data for HBL
    ----------------------------
    Contains session data.
    Works similarly to Config class but this handles only the data in current session.
    All data after application exit will be erased as they are not used or will be
    already uploaded to stats file.

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-06
*/

class Session {
    static Setup() {
        return Session()
    }

    __New() {
        _LOG.Info('Session: Session data was started.')
        this.GenerateProps()
    }

    GenerateProps() {
        this.DATA := {
            CURR_NUM:       0,
            CURR_TTL:       '',
            CURR_HYMN:      '',
            HYMN_PATH:      '',
            FILENAME:       '',
            SUGGESTIONS:    0,
            LAUNCH_READY:   false,
            COUNT_LAUNCH:   0,
            COUNT_QUERY:    0,
            LAST_QUERIED:   '',
            TME_QUERY:      CF.TME_QUERY,
        }

        for name, val in this.DATA.OwnProps() {
            this.DefineProp(name, {value: val})
        }
    }

    _GetCurrentData() {
        /*
            Lists all session properties and their values.
            This is only for development and debugging.
        */
        _LOG.Verbose("Listing current session data")
        for i in this.OwnProps() {
            if i == "DATA" {                                                                ;; Ignore data property
                A_Index--
                continue
            }
            _LOG.Verbose(Format("({1}/{2}) {3} -> {4}",
                A_Index, this.DATA.Capacity, i, this.GetOwnPropDesc(i).Value))
        }
    }

    _SendEndReport() {
        /*
            Sends a report to logger during application exit
        */
        if this.COUNT_LAUNCH {
            _LOG.Info(Format("Session: Launched {1} file(s) at end of session",
            this.COUNT_LAUNCH))
        }
        if this.COUNT_QUERY {
            _LOG.Info(Format("Session: Queried {1} hymn(s) at end of session",
            this.COUNT_QUERY))
        }
    }

    ResetQueryTimeout() {
        /*  Resets the query timeout */
        this.TME_QUERY := CF.TME_QUERY
    }

    EndSession() {
        /*  Executes several instructions about closing the session */
        UI.UpdatePos()
        this._SendEndReport()
    }
}