Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object; $inRequestSyncToken : Boolean)
    
    Super($inProvider; $inURL; "people"; $inHeaders; $inRequestSyncToken)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get users() : Collection
    
    return This._internals._list