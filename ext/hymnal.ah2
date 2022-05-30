#Include ..\..\lib\KVLib.ah2

HYMNAL := HymnalDB.ScanHymnal()               ;; Default variable

Class HymnalDB {
    static FILE_HYMNS := "C:\ProgramData\MSDAC Systems\Hymnal Browser Lite\hymns.sda"

    static SplitHymn(file) {
        /* 
         *  Splits the filename of the hymnal by parsing the parts into:
         *  Category, Hymn Number, Hymn Title, File Extension)
         *
         *  Returns a map of 4 keys
         */
        OUT := Map(
            "CAT", SubStr(file, 1, 2),
            "NUM", (isDigit(SubStr(file, 4, 3)) ? SubStr(file, 4, 3):0),
            "TTL", SubStr(file, 8, -6),
            "EXT", (StrSplit(file, ".").length > 1 ? StrReplace(StrSplit(file, ".")[-1], "`r"):"")
        )
        return OUT
    }

    static ScanHymnal() {
        /*
         *  Returns a map of all hymnal data extracted from the .sda file zip
         */
        HymnZip := TarZip(HymnalDB.FILE_HYMNS)
        _HYMNAL := [[[], []], [[], []], [[], []], -1, -1, -1]
        HNUMS := []
        CATS := ["EN", "TL", "US"]
        
        for i, FILE in HymnZip.files {
            spH := HymnalDB.SplitHymn(FILE)
            HNUMS.push(sph['NUM'])
            loop CATS.Length {
                if (spH["CAT"] == CATS[A_Index] && spH["EXT"] = "pptx") {
                    _HYMNAL[A_Index][1].push(spH["NUM"])
                    _HYMNAL[A_Index][2].push(spH["TTL"])
                    break
                } else if (spH["EXT"] != "pptx" and SubStr(FILE, -1) != "/") {
                    ; ToolTipX(Format("Unnecessary file `"{1}`" detected inside the database.", FILE), 1)
                }
            }
        }
        _HYMNAL[4] := []
        loop CATS.Length {
            P_Index := A_Index
            loop _HYMNAL[P_Index][1].length {
                _HYMNAL[4].push(_HYMNAL[P_Index][1][A_Index] " " _HYMNAL[P_Index][2][A_Index])
            }
        }
        
        _HYMNAL[4] := SortArray(_HYMNAL[4])
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
            "HYMNS", _HYMNAL[4],
            "TOTAL", _HYMNAL[5]
        )
        return _BOOK
    }
}