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
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get events() : Collection
    
    return This._internals._list
