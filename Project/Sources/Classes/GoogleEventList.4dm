Class extends _GoogleBaseList

property kind : Text
property etag : Text
property summary : Text
property calendarId : Text
property description : Text
property updated : Text
property timeZone : Text
property accessRole : Text
property defaultReminders : Collection

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider; $inParameters)
    
    This._internals._events:=null
    This._internals._update:=true
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get events() : Collection
    
    If (This._internals._update)
        
        var $iter : Object
        
        This._internals._events:=[]
        For each ($iter; This._internals._list)
            This._internals._events.push(cs.GoogleEvent.new($iter))
        End for each 
        
        This._internals._update:=False
    End if 
    
    return This._internals._events
    
    
    // ----------------------------------------------------
    
    
Function next() : Boolean
    
    This._internals._update:=Super.next()
    return This._internals._update
    
    
    // ----------------------------------------------------
    
    
Function previous() : Boolean
    
    This._internals._update:=Super.previous()
    return This._internals._update
    
