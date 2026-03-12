/**
 * * Configuration
 * ----------------
 * Manages the configuration settings for Hymnal Browser Lite
 * 
 * (c) 2022-2025 MSDAC Systems
 * @author Ken Verdadero <dev@kenverdadero.com>
 * Written 2022-06-04
 * 
 * Configuration will be aliased to "CF" when referencing from other classes.
 * (i.e: CF.TEMP_MAX_RECENT)
 *     
 * The configuration will load the defaults first to the instance
 * before loading the custom settings specified in Software.FILE_CONFIG.
 * This is to prevent unexpected property errors.
 *     
 * All properties that has prefix of '__' in their names will be considered
 * as private properties, these will not be included in dumping configurations.
 *     
 * Improvements:
 *  TODO: Place the generatedDefaults config to A_Temp before moving to ProgramData
 *  in case the parent directories are also absent.
 */
class Config {
  static FILE := Software.FILE_CONFIG
  static HEAD_TEXT := Format(
    "{1} Configuration`nThis file was generated automatically."
    "`n`n{2}`nLast updated: {3}",
    Software.PARENT_NAME, Software.VERSION_STRING, Time.GetCurrentTime()
  )

  __New() {
    if !FileExist(Config.FILE) {
      Console.warn("Config: Configuration is missing. Generating defaults.", true)
      this.GenerateDefaults()
    } else {
      this.LoadDefaults(true)                                                         ;; Loads the default configuration
      this.Load()                                                                     ;; Loads the custom configuration; Conflicting keys will override the default.
    }
  }

  Load() {
    /*
        Reads and loads from external configuration file.
        * All unused keys will not be removed from the object data (CFG.DATA).
    */
    Console.Info("Config: Reading configuration from `"" Config.FILE '"', true)
    try {
      if !StrLen(FileRead(Config.FILE)) {
        this.GenerateDefaults()
        return
      }
      this.__CFG := KConfig.Read(Config.FILE)                                         ;; this.__CFG is the copy of loaded configuration; used for recovery or reverting settings
      this.__CFG.DeleteProp("Capacity")
    } catch Error {
      Console.Error("Config: There was an error loading the configuration", true)
      return
    }

    this.ApplyData(this.__CFG)
    Console.Info("Config: Successfully loaded configuration", true)
  }

  /**
   * Returns default configuration.
   *     
   * This method contains all the keys and values to be inserted when:
   *    (1) the configuration was missing
   *    (2) the configuration was corrupted (i.e, there's missing pairs)
   *     
   * The HID object contains the configuration that system needs
   * but not necessarily should be present in the configuration file.
   * This is useful for keys like VERBOSE_LOG as it's considered as an advanced
   * setting.
   *     
   * Configuration generator (Config.GenerateDefaults) should not include
   * the hidden keys, but they should be still defined in the system.
   *     
   * Maintainer could add default values using object structure.
   * This object will be converted to a configuration-readable file.
   *     
   * Objects are treated as a section.
   * Properties of an object are treated as pairs of keys and values.
   * Nested objects [sections] are not allowed.
   *     
   * See KConfig documentation for more info.
   */
  GetDefaults(includeHidden := false, hiddenOnly := false) {
    DEF := Object()
    HID := Object()                                                                     ;; Hidden configuration that will not be present when generated. Still needed by the system

    HID.TME_QUERY := 1                                                                  ;; Time delay before a hymn query is considered a count

    ; MAIN section holds user-facing options that may be toggled
    ; both verbose logging and update-check preference are configurable.
    DEF.MAIN := Object()
    DEF.MAIN.VERBOSE_LOG := false                                                       ;; Extra details when logging (previously hidden)
    DEF.MAIN.CHECK_UPDATES := true                                                      ;; Automatically check for updates on startup

    DEF.WINDOW := Object()
    DEF.WINDOW.ALWAYS_ON_TOP := true                                                    ;; Make the window always on top of other windows
    DEF.WINDOW.XPOS := 0                                                                ;; Window X position on startup
    DEF.WINDOW.YPOS := 0                                                                ;; Window Y position on startup
    DEF.WINDOW.MON := 1                                                                 ;; Monitor number the window will be displayed (default is 1/Primary)

    HID.TEMP := Object()
    HID.TEMP.MAX_RECENT := 20                                                           ;; Maximum Temporary files stored in temp folder of the application. Affects launch times

    HID.HYMNAL := Object()
    HID.HYMNAL.PACKAGE := 'hymns.sda'                                                   ;; Hymnal database filename

    DEF.LAUNCH := Object()
    DEF.LAUNCH.FOCUS_BACK := false                                                      ;; Focus back to the main window after launching a presentation
    DEF.LAUNCH.TYPE := 0                                                                ;; Presenter type; 1 - Open, 2 - Open in Slideshow

    ; merge hidden values into defaults without overwriting existing default keys
    if includeHidden {
      for key, val in HID.OwnProps() {
        if !DEF.HasOwnProp(key) {
          DEF.DefineProp(key, {
            value: val
          })
        } else if TypeMatch(val, "Object") && TypeMatch(DEF[key], "Object") {
          ; merge nested objects shallowly for hidden entries
          for subk, subv in val.OwnProps() {
            if !DEF[key].HasOwnProp(subk) {
              DEF[key].DefineProp(subk, {
                value: subv
              })
            }
          }
        }
      }
    }
    return (hiddenOnly ? HID : DEF)
  }

  LoadDefaults(includeHidden := false) => this.ApplyData(this.GetDefaults(includeHidden))   ;; Applies the default configuration to the base instance

  /**
   * Inherits configObject to config instance.
   * Keeps default keys that are absent in config and tracks when defaults are injected.
   * When missing sections/properties are added the configuration will be dumped to
   * file automatically so that the on-disk copy stays in sync with the defaults.
   */
  ApplyData(configObject) {
    madeChanges := false                                  ;; track if we injected any defaults

    for name, val in configObject.OwnProps() {
      if ArrayMatch(name, [
        'DATA',
        '__CFG'
      ]) {                                        ;; Exclude DATA map and __CFG
        continue
      }
      if TypeMatch(val, "Object") {                                                   ;; Since object's properties will be fully replaced, we need to retain props that might be absent in the new data
        C_CFG := this.GetDefaults(true)                                             ;; Copy of default configuration
        DEF := C_CFG.GetOwnPropDesc(name).Value                                     ;; Retrieve default CFG.Object.Object value

        ;; determine whether merging will add any missing default keys
        for k, _ in DEF.OwnProps() {
          if !val.HasOwnProp(k) {
            madeChanges := true
            break
          }
        }

        this.DefineProp(name, {
          value: ObjectMerge(DEF, val)
        })                       ;; ! Merged object will be defined; e.g: In case ALWAYS_ON_TOP is removed from CFG, the default will still be present.
        continue
      }
      this.DefineProp(name, {
        value: val
      })                                             ;; Transfer the loaded configuration data to the instance's properties
    }

    ;; ensure any missing top-level entries from the original
    ;; configuration object are reflected on the instance.  Previously
    ;; we iterated over the defaults (C_CFG) but those defaults are
    ;; already applied by LoadDefaults(), so the ``this.HasOwnProp``
    ;; check would never fire and madeChanges would remain false.
    ;; Instead, walk the original configObject itself and add any
    ;; names it contains that somehow were skipped during the first
    ;; pass (e.g. excluded by ArrayMatch).
    for name, val in configObject.OwnProps() {
      if !this.HasOwnProp(name) {
        this.DefineProp(name, {
          value: val
        })
        madeChanges := true
      }
    }

    this.__CFG := configObject                                                          ;; Backup of the original data

    ;; persist updated configuration if any defaults were injected
    if madeChanges {
      Console.Info("Config: Upgrading configuration with new keys")
      this.Dump()
    }
  }

  /*  Generates a configuration file based on the default values */
  GenerateDefaults(autoReload := true) {
    if KConfig.Dump(this.GetDefaults(), Config.FILE, Config.HEAD_TEXT) {
      Console.Warn(
        "Config: Required folders does not exists, "
        "invoking system to resolve", true)
      System.VerifyDirectories(true)
      this.GenerateDefaults()
    } else {
      Console.Info("Config: Configuration was generated successfully.", true)
      (autoReload ? this.LoadDefaults(true) : 0)
    }
  }

  /**
   * Dumps the updated configuration to file.
   */
  Dump() {
    F_CFG := Object()                                                                   ;; Filtered configuration
    for name, val in this.OwnProps() {
      if SubStr(name, 1, 2) == '__' {                                                 ;; Ignore all entries that prefixes '__' since they are considered as private properties
        continue
      }
      F_CFG.DefineProp(name, {
        value: val
      })
    }
    F_CFG := ObjectSub(F_CFG, this.GetDefaults(false, true))                              ;; exclude hidden defaults (explicit args)
    KConfig.Dump(F_CFG, Config.FILE, Config.HEAD_TEXT)
  }
}
