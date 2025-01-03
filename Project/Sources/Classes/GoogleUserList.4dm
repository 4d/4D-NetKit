Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
    
    Super($inProvider; $inURL; "people"; $inHeaders)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get users() : Collection
    
    return This._internals._list