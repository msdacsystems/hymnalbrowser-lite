/**
 * * HymnSearchService
 * --------------------
 * This class handles the search queries for hymns in the database.
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 */
class HymnSearchService {
  static CTS := [
    'EN',
    'TL'
  ]

  /**
   * Run a search query across all content types.
   * @param {string} query - The search query, can be a hymn number or title.
   */
  static Query(query) {
    if !StrLen(query)
      return false

    REF := HymnalDB.ToHymnNumber(query)
    if !HymnalDB.isValidHymn(query) {
      try REF := HymnalDB.ToHymnNumber(UI.CPLTR.GetCurrentCompletion())
      catch Error
        return false
    }

    for i, CT in this.CTS {
      EQ_CT := this.CTS[i = 1 ? 2 : 1]
      if !ArrayMatch(REF, HYMNAL[CT][1])
        continue

      IDX := ArrayFind(HYMNAL[CT][1], REF)
      NUM := HYMNAL[CT][1][IDX]
      TTL := HYMNAL[CT][2][IDX]
      try {
        EQ_NUM := HYMNAL[EQ_CT][1][IDX]
        EQ_TTL := HYMNAL[EQ_CT][2][IDX]
      } catch Error {
        EQ_NUM := 0
        EQ_TTL := "N/A"
      }
      return {
        CT: CT,
        IDX: IDX,
        NUM: NUM,
        TTL: TTL,
        EQ_CT: EQ_CT,
        EQ_NUM: EQ_NUM,
        EQ_TTL: EQ_TTL,
        REF: REF
      }
    }
    return false
  }
}
