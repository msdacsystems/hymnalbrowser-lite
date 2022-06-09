/*
    Hymnal Database
    ----------------
    Manages and parses the hymnal database

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
*/

Class HymnalDB {
    static SplitHymn(file) {
        /*
            Splits the filename of the hymnal by parsing the parts into:
                - Category, Hymn Number, Hymn Title, File Extension
            Returns an object.

                Index       Content
                -------    --------
                [1]     - English (# and Title)
                [2]     - Tagalog (# and Title)
                [3]     - User-personal (# and Title)
                [4]     - All in one Hymn Titles
                [5]     - Total number of hymns
        */
        OUT := Object()
        OUT.DefineProp("CAT", {value: SubStr(file, 1, 2)})
        OUT.DefineProp("NUM", {value: (isDigit(SubStr(file, 4, 3)) ? SubStr(file, 4, 3):0)})
        OUT.DefineProp("TTL", {value: SubStr(file, 8, -5)})
        OUT.DefineProp("EXT", {value: (StrSplit(file, ".").length > 1 ? StrReplace(StrSplit(file, ".")[-1], "`r"):"")})
        return OUT
    }

    static ToHymnNumber(text) {
        /*  Stringify the hymn to digits with 3 leading zeros */
        return ZFill(SubStr(StrSplit(text, ' ')[1], 1, 3), 3) 
    }

    static isValidHymn(hymn) {
        /*
            Verifies if the hymn text is valid.

            The way this works is the hymn-var will be trimmed to first 3 characters
            and will be zero-filled (3 digits).

            The RegEx matcher will verify if the first 3 characters were digits.
            If so, the number number will search for matching hymn number.

        */
        NUMSTR := HymnalDB.ToHymnNumber(hymn)
        
        if !RegExMatch(NUMSTR, '[0-9]{3}') {                                                ;; When the first 3 characters are not a digit & the 4th character is not a space
            return 0
        }

        if !ArrayMatch(NUMSTR, HYMNAL['ALL_NUM']) {                                         ;; When there's no matching Hymn Number in all database
            return 0
        }
        return 1
    }

    static ScanHymnal() {
        /*
            Returns a map of all hymnal data extracted from the .sda file zip.
        */
        CF.__FILE_HYMNALDB := 0

        for dir in SW.DIRS_HYMNAL_PACKAGE {
            _LOG.Verbose("HymnsDB: Scanning from directory `"" dir '"')
            if FileExist(PathJoin(dir, CF.HYMNAL.PACKAGE)) {
                _LOG.Verbose("HymnsDB: Database was found.")
                CF.__FILE_HYMNALDB := PathJoin(dir, CF.HYMNAL.PACKAGE)
                break
            }
            _LOG.Verbose("HymnsDB: Database was not found.")
        }

        if !CF.__FILE_HYMNALDB {
            _LOG.Error(
                Format(
                    "HymnsDB: Hymnal package '{1}' cannot be found "
                    "in any of scanned directories: {2}",
                    CF.HYMNAL.PACKAGE, ArrayAsStr(SW.DIRS_HYMNAL_PACKAGE,, '.', false,,, '"')
                )
            )
            Errors.HymnsDB("AbsentFile")
        }

        _LOG.Info("HymnsDB: Scanning hymnal from `"" CF.__FILE_HYMNALDB '"')
        HymnZip := TarZip(CF.__FILE_HYMNALDB)
        _HYMNAL := [[[], []], [[], []], [[], []], -1, -1, -1]
        CATS := ["EN", "TL", "US"]
        HNUMS := []
        INVALID_ITEMS := []
        
        for FILE in HymnZip.files {
            spH := HymnalDB.SplitHymn(FILE)
            if (spH.EXT != "pptx" and SubStr(FILE, -1) != "/") and StrLen(FILE) {
                _LOG.Warn(
                    Format("HymnsDB: Unnecessary file `"{1}`""
                        " detected inside the database.",
                        FILE)
                    )
                INVALID_ITEMS.Push(FILE)
            }

            loop CATS.Length {
                if (spH.CAT != CATS[A_Index] || spH.EXT != "pptx") {
                    continue
                }
                _HYMNAL[A_Index][1].push(spH.NUM)
                _HYMNAL[A_Index][2].push(spH.TTL)
                break
            }
            HNUMS.push(spH.NUM)
        }

        _HYMNAL[4] := []
        loop CATS.Length {
            P_Index := A_Index
            loop _HYMNAL[P_Index][1].length {
                _HYMNAL[4].push(
                    _HYMNAL[P_Index][1][A_Index] " " _HYMNAL[P_Index][2][A_Index]           ;; Hymn number & Hymn title
                )
            }
        }
        
        ; MsgRep(ArrayAsStr(_HYMNAL[4]))
        _HYMNAL[4] := ArraySort(_HYMNAL[4])
        _HYMNAL[5] := Map(
            "EN", _HYMNAL[1][1].length,
            "TL", _HYMNAL[2][1].length,
            "US", _HYMNAL[3][1].length,
            "ALL", _HYMNAL[4].length
        )
        _BOOK := Map(
            "EN", _HYMNAL[1],
            "TL", _HYMNAL[2],
            "US", _HYMNAL[3],
            "ALL_NUM", ArraySort(ArrayMerge(_HYMNAL[1][1], _HYMNAL[2][1], _HYMNAL[3][1])),
            "ALL_TTL", ArraySort(ArrayMerge(_HYMNAL[1][2], _HYMNAL[2][2], _HYMNAL[3][2])),
            "HYMNS", _HYMNAL[4],
            "TOTAL", _HYMNAL[5]
        )
        if INVALID_ITEMS.Length {
            _LOG.Warn("HymnsDB: Detected " INVALID_ITEMS.Length " invalid item(s)")
        }
        _LOG.Info('HymnsDB: Successfully scanned hymnal.')
        return _BOOK
    }
}