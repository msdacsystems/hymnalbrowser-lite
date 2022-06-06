/*
    Session data for HBL
    ----------------------------
    Contains session data such as hymn

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-06
*/

class Session {
    static Setup() {
        return Session()
    }

    __New() {
        _LOG.Debug('Session data was started.')
        this.GenerateProps()
    }

    GenerateProps() {
        this.DATA := Map(
            "CURR_NUM", 0,
            "CURR_TTL", '',
            "HYMN_PATH", '',
            "FILENAME", '',
        )

        for name, val in this.DATA {
            this.DefineProp(name, {value: val})
        }
    }

    _GetCurrentData() {
        /*  Lists all session properties and their values */
        _LOG.Verbose("Listing current session data")
        for i in this.OwnProps() {
            if i == "DATA" {
                A_Index--
                continue
            }
            _LOG.Verbose(Format("({1}/{2}) {3} -> {4}",
                A_Index, this.DATA.Capacity, i, this.GetOwnPropDesc(i).Value))
        }
    }
}