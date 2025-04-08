class Utils {
  static HumanizeISO8601Date(iso8601) {
    if (!iso8601)
      return ""

    timeDiff := DateDiff(A_Now, Utils.IsoToAhkDatetime(iso8601), "s")
    if (timeDiff < 0)
      return "in the future"

    units := [{ limit: 60, divisor: 1, singular: "second", plural: "seconds" }, { limit: 3600, divisor: 60, singular: "minute", plural: "minutes" }, { limit: 86400, divisor: 3600, singular: "hour", plural: "hours" }, { limit: 2592000, divisor: 86400, singular: "day", plural: "days" }, { limit: 31536000, divisor: 2592000, singular: "month", plural: "months" }
    ]

    for unit in units {
      if (timeDiff < unit.limit) {
        value := Round(timeDiff / unit.divisor)
        return value " " (value = 1 ? unit.singular : unit.plural) " ago"
      }
    }

    years := Round(timeDiff / 31536000)
    return years " year" (years = 1 ? "" : "s") " ago"
  }

  static IsoToAhkDatetime(iso8601) {
    RegExMatch(iso8601, "(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})", &match)
    return Format("{1}{2}{3}{4}{5}{6}", match[1], match[2], match[3], match[4], match[5], match[6])
  }
}