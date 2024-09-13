Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text)
    
    Super($inProvider; $inURL; "users")
    This._internals._URL:=$inURL
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get users() : Collection
    
    return This._internals._list