Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
    
    Super($inProvider; $inURL; "items"; $inHeaders)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get calendars() : Collection
    
    return This._internals._list