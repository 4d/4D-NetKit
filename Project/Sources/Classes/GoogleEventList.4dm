/**
 * @class GoogleEventList
 * @extends _GoogleBaseList
 * @description Paginated list of Google Calendar events returned by the
 *   `events.list` endpoint. Wraps each raw event object into a `GoogleEvent`
 *   instance on first access via the `events` getter (lazy, cached);
 *   use `next()` / `previous()` inherited from `_BaseList` to navigate pages.
 */

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

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Object} $inParameters - `_GoogleBaseList` parameters object;
 *   pass at minimum `{url: Text}` pointing to the `events.list` endpoint.
 *   Top-level response properties (`kind`, `etag`, `summary`, etc.) are forwarded
 *   automatically when listed in `$inParameters.attributes`.
 */
Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider; $inParameters)
    
    This._internals._events:=Null
    This._internals._update:=True
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
/**
 * @function get events
 * @returns {Collection} Current page of `GoogleEvent` instances
 * @description Lazily wraps each raw event object from `_internals._list` into a
 *   `GoogleEvent` instance on first access; the result is cached and invalidated
 *   when `next()` / `previous()` loads a new page
 */
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
 
