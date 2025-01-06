Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
    
    Super($inProvider; {url: $inURL; elements: "people"; headers: $inHeaders})
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get users() : Collection
    
    return This._internals._list