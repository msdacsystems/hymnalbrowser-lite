/*
    * Configuration
    ----------------
    Manages the configuration settings for Hymnal Browser Lite

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-04
*/

class Config {
    /*
        Configuration will be aliased to "CF" when referencing from other classes.
        (i.e: CF.TEMP_MAX_RECENT)

        The configuration will load the defaults first to the instance
        before loading the custom settings specified in Software.FILE_CONFIG.
        This is to prevent unexpected property errors.

        All properties that has prefix of '__' in their names will be considered
        as private properties, these will not be included in dumping configurations.

        Improvements:
            TODO: Place the generatedDefaults config to A_Temp before moving to ProgramData
            in case the parent directories are also absent.
    */
    static FILE := Software.FILE_CONFIG
    static HEAD_TEXT := Format(
                "{1} Configuration`nThis file was generated automatically."
                "`n`n{2}`nLast updated: {3}",
                Software.PARENT_NAME, Software.VERSION_STRING, Time.GetCurrentTime()
                )

    __New() {
        if !FileExist(Config.FILE) {
            _LOG.warn("Config: Configuration is missing. Generating defaults.", true)
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
        _LOG.Info("Config: Reading configuration from `"" Config.FILE '"', true)
        try {
            if !StrLen(FileRead(Config.FILE)) {
                this.GenerateDefaults()
                return
            }
            this.__CFG := KConfig.Read(Config.FILE)                                         ;; this.__CFG is the copy of loaded configuration; used for recovery or reverting settings
            this.__CFG.DeleteProp("Capacity")
        } catch Error {
            _LOG.Error("Config: There was an error loading the configuration", true)
            return
        }
        
        this.ApplyData(this.__CFG)
        _LOG.Info("Config: Successfully loaded configuration", true)
    }

    GetDefaults(includeHidden:=false, hiddenOnly:=false) {
        /*
            Returns default configuration.

            This method contains all the keys and values to be inserted when:
                (1) the configuration was missing
                (2) the configuration was corrupted (i.e, there's missing pairs)

            The HID object contains the configuration that system needs
            but not necessarily should be present in the configuration file.
            This is useful for keys like VERBOSE_LOG as it's considered as an advanced
            setting.

            Configuration generator (Config.GenerateDefaults) should not include
            the hidden keys, but they should be still defined in the system.

            Maintainer could add default values using object structure.
            This object will be converted to a configuration-readable file.

            Objects are treated as a section.
            Properties of an object are treated as pairs of keys and values.
            Nested objects [sections] are not allowed.

            See KConfig documentation for more info.
        */
        DEF := Object()
        HID := Object()                                                                     ;; Hidden configuration that will not be present when generated. Still needed by the system
        
        HID.TME_QUERY := 1                                                                  ;; Time delay before a hymn query is considered a count

        HID.MAIN := Object()
        HID.MAIN.VERBOSE_LOG := false                                                       ;; Extra details when logging

        DEF.WINDOW := Object()
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

        DEF := (includeHidden ? ObjectMerge(DEF, HID):DEF)
        return (hiddenOnly ? HID:DEF)
    }

    LoadDefaults(includeHidden:=false) => this.ApplyData(this.GetDefaults(includeHidden))   ;; Applies the default configuration to the base instance

    ApplyData(configObject) {
        /*  
            Inherits configObject to config instance.
            Keeps default keys that is absent in config.
        */
        for name, val in configObject.OwnProps() {
            if ArrayMatch(name, ['DATA', '__CFG']) {                                        ;; Exclude DATA map and __CFG
                continue
            }
            if TypeMatch(val, "Object") {                                                   ;; Since object's properties will be fully replaced, we need to retain props that might be absent in the new data
                C_CFG := this.GetDefaults(true)                                             ;; Copy of default configuration
                DEF := C_CFG.GetOwnPropDesc(name).Value                                     ;; Retrieve default CFG.Object.Object value
                this.DefineProp(name, {value: ObjectMerge(DEF, val)})                       ;; ! Merged object will be defined; e.g: In case ALWAYS_ON_TOP is removed from CFG, the default will still be present.
                continue
            }
            this.DefineProp(name, {value: val})                                             ;; Transfer the loaded configuration data to the instance's properties
        }
        this.__CFG := configObject                                                          ;; Backup of the original data
    }

    GenerateDefaults(autoReload:=true) {
        /*  Generates a configuration file based on the default values */
        if KConfig.Dump(this.GetDefaults(), Config.FILE, Config.HEAD_TEXT) {
            _LOG.Warn(
                "Config: Required folders does not exists, " 
                "invoking system to resolve", true)
            System.VerifyDirectories(true)
            this.GenerateDefaults()
        } else {
            _LOG.Info("Config: Configuration was generated successfully.", true)
            (autoReload ? this.LoadDefaults(true):0)
        }
    }

    Dump() {
        /*
            Dumps the updated configuration to file.   
        */
        F_CFG := Object()                                                                   ;; Filtered configuration
        for name, val in this.OwnProps() {
            if SubStr(name, 1, 2) == '__' {                                                 ;; Ignore all entries that prefixes '__' since they are considered as private properties
                continue
            }
            F_CFG.DefineProp(name, {value: val})
        }
        F_CFG := ObjectSub(F_CFG, this.GetDefaults(, true))                                 ;; ! Needs review
        KConfig.Dump(F_CFG, Config.FILE, Config.HEAD_TEXT)
    }
}