/**
 * * Statistical Data Management
 * -------------------------------------------------
 * This module manages hymn-related statistics such as launches, queries, usage frequency, 
 * and suggested data. It integrates with session data to collect and forward relevant 
 * information for storage and analytics.
 * 
 * Statistics are stored in a JSON file, which can be exported and synchronized with 
 * cloud-based analytics systems for further processing.
 * 
 * Features:
 * - Tracks hymn launches and queries.
 * - Maintains timestamps for the last query and launch.
 * - Provides JSON-based data storage for easy integration and portability.
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 */
class Stats {
  /**
   * The ISO 8601 date format used for timestamps in the stats file.
   */
  static ISO_STRING := "yyyy-MM-ddTHH:mm:ssZ"
  FILE := SW.FILE_STATS

  /**
   * Deletes the stats file if it exists
   */
  static CleanStatsFile() {
    if FileExist(SW.FILE_STATS) {
      try {
        FileDelete(SW.FILE_STATS)
      } catch Error as e {
        Errors.Stats("CleanupFailed", e.message)
      }
    }
  }

  static Setup() {
    return Stats()
  }

  __New() {
    /**
     * Record of hymn stats
     */
    this.HymnData := Object()
    this.Load()

  }

  Load() {
    /*  Loads the stats from JSON file */
    if !FileExist(this.FILE) {
      Console.Error("Stats: File does not exist")
      return
    }

    Console.Info("Stats: Loading stats from JSON file: " . this.FILE)

    file := FileOpen(this.FILE, "r")
    if !file {
      Console.Error("Stats: Failed to stats file for reading")
      return
    }

    data := file.Read()
    file.Close()

    ;; Verify the JSON data
    try {
      parsed := JSON.parse(data)
    } catch Error as e {
      Errors.Stats("Corrupted", e.message)
      return
    }
    if !parsed {
      Console.Error("Stats: Stats file is empty")
      return
    }

    ;; Convert the JSON data to objects
    for i in parsed {
      statObj := MapToObj(i)
      if !statObj.id {
        Console.Error("Stats: Invalid JSON file")
        return
      }
      this.HymnData.DefineProp(statObj.id, {
        value: Stat(statObj.id)
      })
      statData := this.GetStat(statObj.id)
      statData.launches := statObj.launches
      statData.queries := statObj.queries
      statData.queriedAt := statObj.queriedAt
      statData.launchedAt := statObj.launchedAt
    }

    Console.Info(Format("Stats: Loaded {1} hymn stats", parsed.length))
  }

  HasStat(Hymn) {
    return this.HymnData.HasProp(Hymn)
  }

  /**
   * Returns the hymn stat object
   * @description Returns the hymn stat object. If the stat does not exist, it will be created.
   */
  GetStat(Hymn) {
    if !this.HasStat(Hymn) {
      return this.GenerateStat(Hymn)
    }
    return this.HymnData.GetOwnPropDesc(Hymn).value
  }

  /**
   * Generates a new hymn stat object
   */
  GenerateStat(Hymn) {
    if (this.HasStat(Hymn)) {
      Console.Error("Stats: Hymn stat already exists")
      return this.GetStat(Hymn)
    }

    this.HymnData.DefineProp(Hymn, {
      value: Stat(Hymn),
    })
    return this.HymnData.GetOwnPropDesc(Hymn).value
  }

  /**
   * Records the hymn query
   * @param Hymn the number of the hymn
   */
  RecordQuery(Hymn) {
    stat := this.GetStat(Hymn)
    stat.IncrementQuery()
    this.Export()
  }

  /**
   * Records the hymn launch
   * @param Hymn the number of the hymn
   */
  RecordLaunch(Hymn) {
    stat := this.GetStat(Hymn)
    stat.IncrementLaunch()
    this.Export()
  }

  /**
   * Exports the stats to a JSON file
   * 
   * This is invoked when the stats are updated.
   */
  Export() {
    data := JSON.stringify(this.GetConvertedStats(), 2)

    file := FileOpen(this.FILE, "w")
    if !file {
      Console.Error("Stats: Failed to open file for writing")
      return
    }

    file.Write(data)
    file.Close()
    Console.Verbose("Stats: Exported stats to JSON file")
  }

  /**
   * Converts the Stat objects to a JSON-compatible object
   * @returns {Array} 
   */
  GetConvertedStats() {
    out := []
    for name, val in this.HymnData.OwnProps() {
      stat := this.GetStat(name)
      out.Push(stat.ToObject())
    }
    return out
  }
}

/**
 * Represents a hymn statistic
 * @description Class for hymn statistics
 */
class Stat {
  __New(id) {
    this.id := id
    this.name := HymnalDB.GetHymnNameByNumber(id)
    this.launches := 0
    this.queries := 0
    this.queriedAt := ""
    this.launchedAt := ""
  }

  /**
   * @description Increments the launch count of the hymn
   */
  IncrementLaunch() {
    this.launches++
    this.launchedAt := FormatTime(, Stats.ISO_STRING)
  }

  /**
   * @description Increments the query count of the hymn
   */
  IncrementQuery() {
    this.queries++
    this.queriedAt := FormatTime(, Stats.ISO_STRING)
  }

  /**
   * Converts the Stat object to a JSON-compatible object
   */
  ToObject() {
    return {
      id: this.id,
      name: this.name,
      launches: this.launches,
      queries: this.queries,
      queriedAt: this.queriedAt,
      launchedAt: this.launchedAt,
    }
  }
}
