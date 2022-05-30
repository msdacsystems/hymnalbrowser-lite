Class Core {
    ;; Handles important functions that are crucial for the software
    static getFilteredArray(Haystack, Needle) {
        ;; Returns matched hymns
        FilteredArray := []
        for i, e in Haystack {
            if RegExMatch(e, Format("(?i){1}", Needle)) {
                FilteredArray.push(e)
            }
        }
        return FilteredArray
    }
}