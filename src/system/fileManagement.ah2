/*
    File Manager
    ------------
    Covers file control for the application.
    All methods under this class should be used in thread.

    (c) 2022 MSDAC Systems
    Ken Verdadero, Reynald Ycong
    Written 2022-06-04
*/

class FileManagement {
    static RemoveTempSubdirs(args*) {
        /* Deletes the temp subfolders: EN, TL, US after launching a presentation */
        MAX_TRIES := 13
        SUBDIRS := [
            SW.DIR_TEMP "/EN",
            SW.DIR_TEMP "/TL",
            SW.DIR_TEMP "/US"
        ]
        while (DirExist(SUBDIRS[1]) or DirExist(SUBDIRS[2]) or DirExist(SUBDIRS[3])) {
            if !MAX_TRIES
                break
            Sleep(10)
            _LOG.Verbose("System: Deleting temp subfolders (Tries: " 14-MAX_TRIES ")")
            for dir in SUBDIRS {
                try DirDelete(dir, 1)
            }
            MAX_TRIES--
        }
        _LOG.Verbose("System: Temp subfolders were successfully deleted.")
    }

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
        OUT.DefineProp("FN", {value: FN})
        OUT.DefineProp("TM", {value: TM})
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
                (TEMP_LENGTH <= CF.TEMP.MAX_RECENT ? "file count":"files overflowed"),
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
                "removed {1} item{2}", REMOVED, (REMOVED == 1 ? '':'s'))
            )
        }
    } 

    static CloseTemp() {
        try {
            RunWaitOne(Format('{1} /c rmdir /s /q "{2}"', A_ComSpec, SW.DIR_TEMP))
            _LOG.Verbose("System: Temp folder was closed and deleted")
        } catch Error {
            _LOG.Warn("System: Unable to delete temp folder during exit")
        }
    }
}