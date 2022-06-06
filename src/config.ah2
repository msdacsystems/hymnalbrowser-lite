/*
    Configuration Manager for HBL
    -----------------------------

    (c) 2022 Ken Verdadero, Reynald Ycong
    Written 2022-06-04
*/

class Config {
    static FILE := Software.FILE_CONFIG
    static CFG := Object()

    static Setup() {
        if !FileExist(Config.FILE) {
            _LOG.warn("Config: Configuration is missing. Generating defaults.")
            Config.GenerateDefaults()
        }
        _LOG.info("Config: Reading configuration from `"" Config.FILE '"')
        ; OpenFolder(Config.FILE)
        ; Config.CFG := KConfig.Read(Config.FILE)

    }

    static GenerateDefaults() {
        ; CFG := Object()

        ; CFG.DefineProp("")

        FileAppend(
            '',
            Config.FILE
        )
        _LOG.info("Config: Configuration was generated successfully.")
    }
}