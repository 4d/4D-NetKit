Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object; $inAdditionalAttributes : Collection)
    
    Super($inProvider; $inURL; "items"; $inHeaders; $inAdditionalAttributes)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get events() : Collection
    
    return This._internals._list
