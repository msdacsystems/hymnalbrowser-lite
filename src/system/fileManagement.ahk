/*
    File Manager
    ------------
    Covers file control for the application.
    All methods under this class should be used in thread.

    (c) 2022 MSDAC Systems
    Author: Ken Verdadero
    Written 2022-06-04
*/

class FileManagement {
    static GetTempAttrib() {
        /*
            Returns two arrays that has data.
        
            FN - Filenames
            TM - Timestamps
        */
        FN := []
        TM := []
        loop files, PathJoin(SW.DIR_TEMP, "*.pptx") {
            if SubStr(A_LoopFileName, 1, 2) == '~$'                                         ;; Ignore currently opened presentations
                continue
            FN.Push(A_LoopFileFullPath)
            TM.Push(FileGetTime(A_LoopFileFullPath, "C"))
        }
        OUT := Object()
        OUT.DefineProp("FN", { value: FN })
        OUT.DefineProp("TM", { value: TM })
        return OUT
    }

    static RemoveOldest(args*) {
        /*
            Removes all items that are old by analyzing their creation date.
            Only retains items the size of SW.TEMP_MAX_RECENT.
        
            Even if the file is still open and the system needs to delete it,
            the system will wait until it finishes
        */
        TEMP_LENGTH := FileManagement.GetTempAttrib().FN.Length
        REMOVED := 0
        _LOG.Info(
            Format(
                "System: Temp {1}: {2}/{3}",
                (TEMP_LENGTH <= CF.TEMP.MAX_RECENT ? "file count" : "files overflowed"),
                TEMP_LENGTH, CF.TEMP.MAX_RECENT
            )
        )

        while FileManagement.GetTempAttrib().FN.Length > CF.TEMP.MAX_RECENT {               ;; Loop until the .pptx files are equal to the max recent temp
            TA := FileManagement.GetTempAttrib()
            IDX := ArrayMinIndex(TA.TM)
            try {
                FileDelete(TA.FN[IDX])                                                      ;; Delete the oldest file from array using ArrayMinIndex
                _LOG.Verbose(
                    Format("System: Deleted older temp file `"{1}`"", TA.FN[IDX])
                )
                TA.FN.RemoveAt(IDX)
                REMOVED++
            }
        }

        if FileManagement.GetTempAttrib().FN.Length == CF.TEMP.MAX_RECENT && REMOVED {
            _LOG.Info(Format(
                "System: Temp file count is nominal; "
                "removed {1} item{2}", REMOVED, (REMOVED == 1 ? '' : 's'))
            )
        }
    }

    static CloseTemp() {
        try if !System.DEV_MODE {
            FileDelete(SW.BIN_ZIP)
            FileDelete(SW.FILE_ZIPDLL)
            _LOG.Info("System: Internal files were closed successfully")
        }
        catch Error as e {
            _LOG.Warn("System: Unable to close internal file(s): " e.Message)
        }
    }
}