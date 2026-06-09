/**
 * @class Office365Calendar
 * @description Microsoft Graph API client for calendar and event management.
 *   Supports reading, creating, updating, and deleting calendars and events,
 *   with optional `calendarId` and `userId` scoping.
 *   Accepts event date/time as ISO text, `{date; time}` objects, or Graph `{dateTime; timeZone}`
 *   objects — normalised automatically by `_conformEventDateTime`.
 */

Class extends _GraphAPI

property userId : Text:=""
property id : Text:=""

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `userId` {Text} — Graph user ID or UPN; defaults to `""` (uses `me` endpoint)
 */
    
    Super($inProvider)
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
/**
 * @function _getURLParamsFromObject
 * @private
 * @param {Object} $inParameters - Query parameters; extends the base implementation with:
 *   - `startDateTime` {Text|Object} — Start of the date range (ISO text or `{date; time}` object)
 *   - `endDateTime` {Text|Object} — End of the date range (ISO text or `{date; time}` object)
 * @param {Boolean} $inCount - When `True`, appends `$count=true` to the URL
 * @returns {Text} URL query string
 * @description Overrides `_GraphAPI._getURLParamsFromObject` to handle Graph calendar-specific
 *   `startDateTime` and `endDateTime` parameters; other OData params are forwarded to `Super`
 */
    
    var $URL : cs._URL:=cs._URL.new(Super._getURLParamsFromObject($inParameters; $inCount))
    var $startDateTime : Text:=""
    var $endDateTime : Text:=""
    var $dateTime : cs._DateTime
    
    Case of 
        : (Value type($inParameters.startDateTime)=Is text)
            $dateTime:=cs._DateTime.new($inParameters.startDateTime)
            $startDateTime:=$dateTime.getDateTimeURLParameter()
        : (Value type($inParameters.startDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $dateTime:=cs._DateTime.new(Date($inParameters.startDateTime.date); Time($inParameters.startDateTime.time))
            $startDateTime:=$dateTime.getDateTimeURLParameter()
    End case 
    
    Case of 
        : (Value type($inParameters.endDateTime)=Is text)
            $dateTime:=cs._DateTime.new($inParameters.endDateTime)
            $endDateTime:=$dateTime.getDateTimeURLParameter()
        : (Value type($inParameters.endDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $dateTime:=cs._DateTime.new(Date($inParameters.endDateTime.date); Time($inParameters.endDateTime.time))
            $endDateTime:=$dateTime.getDateTimeURLParameter()
    End case 
    
    If (Length($startDateTime)>0)
        $URL.addQueryParameter("startDateTime"; cs._Tools.me.urlEncode($startDateTime))
    End if 
    If (Length($endDateTime)>0)
        $URL.addQueryParameter("endDateTime"; cs._Tools.me.urlEncode($endDateTime))
    End if 
    
    return $URL.toString()
    
    
    // ----------------------------------------------------
    
    
Function _conformEventDateTime($inObject : Object; $inName : Text) : Object
/**
 * @function _conformEventDateTime
 * @private
 * @param {Object} $inObject - Event object containing the named property
 * @param {Text} $inName - Property name to conform (`"start"` or `"end"`)
 * @returns {Object} Normalised Graph `{dateTime; timeZone}` object, or the original value
 *   when the format is unrecognised
 * @description Normalises a date/time property to the Graph `{dateTime; timeZone}` format
 *   accepted by the Microsoft Graph API; delegates to `_DateTime`
 */
    
    var $dateTime : cs._DateTime
    var $timeZone : Text:=((Value type($inObject[$inName].timeZone)=Is text) && (Length($inObject[$inName].timeZone)>0)) ? String($inObject[$inName].timeZone) : ""
    Case of 
        : (Value type($inObject[$inName].dateTime)=Is text)
            $dateTime:=cs._DateTime.new({dateTime: $inObject[$inName].dateTime; timeZone: $timeZone})
            return $dateTime.getGraphDateTime()
        : ((Value type($inObject[$inName].date)=Is date) && (Value type($inObject[$inName].time)#Is undefined))
            $dateTime:=cs._DateTime.new({date: $inObject[$inName].date; time: $inObject[$inName].time; timeZone: $timeZone})
            return $dateTime.getGraphDateTime()
    End case 
    
    return $inObject[$inName]
    
    
    // ----------------------------------------------------
    
    
Function _conformEvent($inObject : Object) : Object
/**
 * @function _conformEvent
 * @private
 * @param {Object} $inObject - Raw event object (may contain `start`, `end`, `calendarId`, `id`)
 * @returns {Object} Normalised event object ready for the Graph API;
 *   `calendarId` and `id` are removed (they live in the URL, not the body)
 * @description Prepares an event object for a Graph API call:
 *   normalises `start`/`end` via `_conformEventDateTime` and strips URL-level fields
 */
    
    var $event : Object:=$inObject
    
    If (OB Is defined($event; "end"))
        $event.end:=This._conformEventDateTime($event; "end")
    End if 
    
    If (OB Is defined($event; "start"))
        $event.start:=This._conformEventDateTime($event; "start")
    End if 
    
    If (OB Is defined($event; "calendarId"))
        OB REMOVE($event; "calendarId")
    End if 
    
    If (OB Is defined($event; "id"))
        OB REMOVE($event; "id")
    End if 
    
    return $event
    
    
    // ----------------------------------------------------
    
    
Function _insertAttachment($inParameters : Object; $inAttachement : Object) : Object  // For test purposes only (subject to changes, use at your own risk)
/**
 * @function _insertAttachment
 * @private
 * @param {Object} $inParameters - Must include:
 *   - `eventId` {Text} — ID of the event to attach to
 *   - `calendarId` {Text} — Optional calendar ID
 * @param {Object} $inAttachement - Attachment object in Graph API format
 * @returns {Object} Status object with the attachment result
 * @description Uploads an attachment to an event via
 *   `POST /me/calendars/{id}/events/{id}/attachments`.
 *   **For test purposes only — subject to change, use at your own risk.**
 */
    
/*
    POST /me/events/{id}/attachments
    POST /users/{id | userPrincipalName}/events/{id}/attachments
    
    POST /me/calendar/events/{id}/attachments
    POST /users/{id | userPrincipalName}/calendar/events/{id}/attachments
    
    POST /me/calendars/{id}/events/{id}/attachments
    POST /users/{id | userPrincipalName}/calendars/{id}/events/{id}/attachments
*/
    Case of 
        : (Value type($inParameters.eventId)#Is text)
            Super._throwError(10; {which: "\"eventId\""; function: "office365.calendar._insertAttachment"})
            
        : (Length(String($inParameters.eventId))=0)
            Super._throwError(9; {which: "\"eventId\""; function: "office365.calendar._insertAttachment"})
            
        Else 
            var $headers : Object:={Accept: "application/json"}
            var $URLString : Text:=This._getURL()
            
            If (Length(String(This.userId))>0)
                $URLString+="users/"+This.userId
            Else 
                $URLString+="me"
            End if 
            
            If (Length(String($inParameters.calendarId))>0)
                $URLString+="/calendars/"+cs._Tools.me.urlEncode($inParameters.calendarId)
            Else 
                $URLString+="/calendar"
            End if 
            $URLString+="/events/"+cs._Tools.me.urlEncode($inParameters.eventId)+"/attachments"
            
            var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URLString; $headers; $inAttachement)
            
            return This._returnStatus($response)
    End case 
    
    return This._returnStatus()
    
    
    // Mark: - [Public]
    // Mark: - Calendars
    // ----------------------------------------------------
    
    
Function getCalendar($inID : Text; $inSelect : Text) : Object
/**
 * @function getCalendar
 * @param {Text} $inID - Calendar ID; uses the default calendar when empty
 * @param {Text} $inSelect - Comma-separated list of properties to return (OData `$select`)
 * @returns {Object} Cleaned calendar object, or `Null` on failure
 * @description Fetches a single calendar via
 *   `GET /me/calendars/{id}` or `GET /me/calendar`
 */
    
    var $URLString : Text:=""
    
    If (Length(String(This.userId))>0)
        $URLString:="users/"+This.userId
    Else 
        $URLString:="me"
    End if 
    
    If (Length(String($inID))>0)
        $URLString+="/calendars/"+cs._Tools.me.urlEncode($inID)
    Else 
        $URLString+="/calendar"
    End if 
    
    If (Length(String($inSelect))>0)
        $URLString+=Super._getURLParamsFromObject({select: $inSelect})
    End if 
    
    var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; This._getURL()+$URLString)
    
    If (Value type($response)=Is object)
        return cs._Tools.me.cleanGraphObject($response)
    End if 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getCalendars($inParameters : Object) : cs.GraphCalendarList
/**
 * @function getCalendars
 * @param {Object} $inParameters - Query options:
 *   - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`)
 *   - `filter`, `select`, `top`, `orderBy` — standard OData parameters
 * @returns {cs.GraphCalendarList} Pageable list of calendars
 * @description Lists calendars via `GET /me/calendars`
 */
    
    Super._clearErrorStack()
    
    var $result : cs.GraphCalendarList
    
    Try
        var $headers : Object:={}
        var $URLString : Text:=""
        
        If (Length(String(This.userId))>0)
            $URLString:="users/"+This.userId
        Else 
            $URLString:="me"
        End if 
        $URLString+="/calendars"+Super._getURLParamsFromObject($inParameters)
        
        If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
            $headers.ConsistencyLevel:="eventual"
        End if 
        
        $result:=cs.GraphCalendarList.new(This._getOAuth2Provider(); This._getURL()+$URLString; $headers)
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return $result
    
    
    // Mark: - Events
    // ----------------------------------------------------
    
    
Function getEvent($inParameters : Object) : cs.GraphEvent
/**
 * @function getEvent
 * @param {Object} $inParameters - Required and optional parameters:
 *   - `eventId` {Text} — **Required.** ID of the event to fetch
 *   - `startDateTime` {Text|Object} — **Required.** Range start (used as query parameter)
 *   - `endDateTime` {Text|Object} — **Required.** Range end (used as query parameter)
 *   - `calendarId` {Text} — Calendar ID; uses default calendar when empty
 *   - `timeZone` {Text} — Response time zone (`Prefer: outlook.timezone`)
 *   - `bodyContentType` {Text} — Body format (`Prefer: outlook.body-content-type`)
 *   - `select` {Text} — OData `$select`
 * @returns {cs.GraphEvent} Event object, or `Null` when not found or on error
 * @description Fetches a single event via `GET /me/calendar/events/{id}` or
 *   `GET /me/calendars/{id}/events/{id}`. See inline comment for all supported Graph endpoints.
 */
    
/*
    GET /me/events/{id}
    GET /me/calendar/events/{id}
    GET /me/calendars/{id}/events/{id}
    
    GET /users/{id | userPrincipalName}/events/{id}
    GET /users/{id | userPrincipalName}/calendar/events/{id}
    GET /users/{id | userPrincipalName}/calendars/{id}/events/{id}
*/
    
    Super._clearErrorStack()
    
    Case of 
        : (Value type($inParameters.eventId)#Is text)
            Super._throwError(10; {which: "\"eventId\""; function: "office365.calendar.getEvent"})
            
        : (Length(String($inParameters.eventId))=0)
            Super._throwError(9; {which: "\"eventId\""; function: "office365.calendar.getEvent"})
            
        : ((Value type($inParameters.startDateTime)=Is undefined) && (Value type($inParameters.endDateTime)#Is undefined))
            Super._throwError(9; {which: "\"startDateTime\""; function: "office365.calendar.getEvent"})
            
        : ((Value type($inParameters.endDateTime)=Is undefined) && (Value type($inParameters.startDateTime)#Is undefined))
            Super._throwError(9; {which: "\"endDateTime\""; function: "office365.calendar.getEvent"})
            
        Else 
            var $headers : Object:={}
            var $URLString : Text:=""
            
            If (Length(String(This.userId))>0)
                $URLString:="users/"+This.userId
            Else 
                $URLString:="me"
            End if 
            
            If ((Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
                $URLString+="/calendars/"+cs._Tools.me.urlEncode($inParameters.calendarId)
            Else 
                $URLString+="/calendar"
            End if 
            $URLString+="/events/"+cs._Tools.me.urlEncode($inParameters.eventId)
            
            $URLString+=This._getURLParamsFromObject($inParameters)
            
            var $prefer : Text:=""
            If (Length(String($inParameters.timeZone))>0)
                $prefer+="outlook.timezone="+cs._Tools.me.quoteString($inParameters.timeZone)+" "
            End if 
            If (Length(String($inParameters.bodyContentType))>0)
                $prefer+="outlook.body-content-type="+cs._Tools.me.quoteString($inParameters.bodyContentType)+" "
            End if 
            If (Length($prefer)>0)
                $headers.Prefer:=$prefer
            End if 
            
            var $result : Object:=cs._Tools.me.cleanGraphObject(Super._sendRequestAndWaitResponse("GET"; This._getURL()+$URLString; $headers))
            
            If (Value type($result)=Is object)
                var $options : Object:={userId: This.userId; calendarId: String($inParameters.calendarId); eventId: String($inParameters.eventId)}
                return cs.GraphEvent.new(This._internals._oAuth2Provider; $options; $result)
            End if 
    End case 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getEvents($inParameters : Object) : cs.GraphEventList
/**
 * @function getEvents
 * @param {Object} $inParameters - Required and optional parameters:
 *   - `startDateTime` {Text|Object} — **Required.** Start of the date range
 *   - `endDateTime` {Text|Object} — **Required.** End of the date range
 *   - `calendarId` {Text} — Calendar ID; uses default calendar when empty
 *   - `timeZone` {Text} — Response time zone (`Prefer: outlook.timezone`)
 *   - `bodyContentType` {Text} — Body format (`Prefer: outlook.body-content-type`)
 *   - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`)
 *   - `filter`, `select`, `top`, `orderBy` — standard OData parameters
 * @returns {cs.GraphEventList} Pageable list of events
 * @description Lists events via `GET /me/calendar/calendarView` (when both date bounds are set)
 *   or `GET /me/calendar/events`. See inline comment for all supported endpoints.
 */
    
/*
    A user's or group's default calendar.
    
        GET /me/calendar/events
        GET /users/{id | userPrincipalName}/calendar/events
        GET /me/calendar/calendarView?startDateTime={start_datetime}&endDateTime={end_datetime}
        GET /users/{id | userPrincipalName}/calendar/calendarView?startDateTime={start_datetime}&endDateTime={end_datetime}
    
    A user's calendar in the default calendarGroup.
    
        GET /me/calendars/{id}/events
        GET /users/{id | userPrincipalName}/calendars/{id}/events
        GET /me/calendars/{id}/calendarView?startDateTime={start_datetime}&endDateTime={end_datetime}
        GET /users/{id | userPrincipalName}/calendars/{id}/calendarView?startDateTime={start_datetime}&endDateTime={end_datetime}
*/
    Super._clearErrorStack()
    
    Try
        
        Case of 
            : ((Value type($inParameters.startDateTime)=Is undefined) && (Value type($inParameters.endDateTime)#Is undefined))
                Super._throwError(9; {which: "\"startDateTime\""; function: "office365.calendar.getEvent"})
                
            : ((Value type($inParameters.endDateTime)=Is undefined) && (Value type($inParameters.startDateTime)#Is undefined))
                Super._throwError(9; {which: "\"endDateTime\""; function: "office365.calendar.getEvent"})
                
            Else 
                var $headers : Object:={}
                var $URLString : Text:=""
                If (Length(String(This.userId))>0)
                    $URLString+="users/"+This.userId
                Else 
                    $URLString+="me"
                End if 
                If ((Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
                    $URLString+="/calendars/"+$inParameters.calendarId
                    This.id:=$inParameters.calendarId
                Else 
                    $URLString+="/calendar"
                End if 
                If ((Value type($inParameters.startDateTime)#Is undefined) && (Value type($inParameters.endDateTime)#Is undefined))
                    $URLString+="/calendarView"+This._getURLParamsFromObject($inParameters)
                Else 
                    $URLString+="/events"+This._getURLParamsFromObject($inParameters)
                End if 
                
                var $prefer : Text:=""
                If ((Value type($inParameters.timeZone)=Is text) && (Length(String($inParameters.timeZone))>0))
                    $prefer+="outlook.timezone="+cs._Tools.me.quoteString($inParameters.timeZone)
                End if 
                If ((Value type($inParameters.bodyContentType)=Is text) && (Length(String($inParameters.bodyContentType))>0))
                    $prefer+=((Length($prefer)>0) ? "; " : "")+"outlook.body-content-type="+cs._Tools.me.quoteString($inParameters.bodyContentType)+" "
                End if 
                If (Length($prefer)>0)
                    $headers.Prefer:=$prefer
                End if 
                
                If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
                    $headers.ConsistencyLevel:="eventual"
                End if 
                
                var $result : cs.GraphEventList:=cs.GraphEventList.new(This; This._getURL()+$URLString; $headers)
                
                If (Not(OB Is defined($result; "calendarId")) && (Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
                    $result.calendarId:=$inParameters.calendarId
                End if 
                
                return $result
                
        End case 
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function createEvent($inEvent : Object; $inParameters : Object) : Object
/**
 * @function createEvent
 * @param {Object} $inEvent - Event object; `calendarId`, `id`, and `attachments` are
 *   handled automatically
 * @param {Object} $inParameters - Optional overrides:
 *   - `calendarId` {Text} — Target calendar ID (takes precedence over `$inEvent.calendarId`)
 * @returns {Object} Status object; includes `event` with the created event data
 * @description Creates a calendar event via `POST /me/calendar/events`.
 *   Attachments in `$inEvent.attachments` are uploaded separately after event creation.
 *   See inline comment for all supported Graph endpoints.
 */
    
/*
        POST /me/events
        POST /users/{id | userPrincipalName}/events
        
        POST /me/calendar/events
        POST /users/{id | userPrincipalName}/calendar/events
        
        POST /me/calendars/{id}/events
        POST /users/{id | userPrincipalName}/calendars/{id}/events
    */
    Super._clearErrorStack()
    
    Try
        var $headers : Object:={Accept: "application/json"}
        var $URLString : Text:=This._getURL()
        var $calendarId : Text:=""
        
        Case of 
            : (Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0)
                $calendarId:=$inParameters.calendarId
            : (Value type($inEvent.calendarId)=Is text) && (Length(String($inEvent.calendarId))>0)
                $calendarId:=$inEvent.calendarId
        End case 
        
        If (Length(String(This.userId))>0)
            $URLString+="users/"+This.userId
        Else 
            $URLString+="me"
        End if 
        
        If (Length(String($calendarId))>0)
            $URLString+="/calendars/"+cs._Tools.me.urlEncode($calendarId)
        Else 
            $URLString+="/calendar"
        End if 
        $URLString+="/events"
        
        var $event : Object:=This._conformEvent(cs._Tools.me.cleanGraphObject($inEvent))
        var $attachments : Collection:=Null
        
        If (Value type($event.attachments)=Is collection) && ($event.attachments.length>0)
            $attachments:=$event.attachments
            OB REMOVE($event; "attachments")
        End if 
        
        var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URLString; $headers; $event)
        
        If ((Value type($attachments)=Is collection) && ($attachments.length>0))
            
            var $params : Object:={eventId: $response.id; calendarId: String($calendarId)}
            var $attachment : Object
            
            $response.attachments:=[]
            For each ($attachment; $attachments)
                
                var $result : Object:=This._insertAttachment($params; $attachment)
                If ($result.success)
                    Try
                        OB REMOVE($result; "success")
                        OB REMOVE($result; "errors")
                        OB REMOVE($result; "statusText")
                    End try
                    $response.attachments.push(cs._Tools.me.cleanGraphObject($result))
                Else 
                    return This._returnStatus($result)
                End if 
            End for each 
        End if 
        
        return This._returnStatus({event: cs._Tools.me.cleanGraphObject($response)})
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function deleteEvent($inParameters : Object) : Object
/**
 * @function deleteEvent
 * @param {Object} $inParameters - Required parameters:
 *   - `eventId` {Text} — ID of the event to delete
 *   - `calendarId` {Text} — Calendar ID; uses default calendar when empty
 * @returns {Object} Status object
 * @description Permanently deletes a calendar event via `DELETE /me/calendar/events/{id}`.
 *   See inline comment for all supported Graph endpoints.
 */
    
/*
        DELETE /me/events/{id}
        DELETE /users/{id | userPrincipalName}/events/{id}
        DELETE /groups/{id}/events/{id}
        
        DELETE /me/calendar/events/{id}
        DELETE /users/{id | userPrincipalName}/calendar/events/{id}
        DELETE /groups/{id}/calendar/events/{id}/
        
        DELETE /me/calendars/{id}/events/{id}
        DELETE /users/{id | userPrincipalName}/calendars/{id}/events/{id}
        
        DELETE /me/calendarGroups/{id}/calendars/{id}/events/{id}
        DELETE /users/{id | userPrincipalName}/calendarGroups/{id}/calendars/{id}/events/{id}
    */
    
    Super._clearErrorStack()
    
    Try
        var $headers : Object:={Accept: "application/json"}
        var $URLString : Text:=This._getURL()
        
        If (Length(String(This.userId))>0)
            $URLString+="users/"+This.userId
        Else 
            $URLString+="me"
        End if 
        If (Length(String($inParameters.calendarId))>0)
            $URLString+="/calendars/"+cs._Tools.me.urlEncode($inParameters.calendarId)
        Else 
            $URLString+="/calendar"
        End if 
        $URLString+="/events"
        If (Length(String($inParameters.eventId))>0)
            $URLString+="/"+cs._Tools.me.urlEncode($inParameters.eventId)
        End if 
        
        Super._sendRequestAndWaitResponse("DELETE"; $URLString; $headers)
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function updateEvent($inEvent : Object; $inParameters : Object) : Object
/**
 * @function updateEvent
 * @param {Object} $inEvent - Event object with updated properties;
 *   `calendarId` and `id` are read from `$inEvent` when not in `$inParameters`
 * @param {Object} $inParameters - Optional overrides:
 *   - `calendarId` {Text} — Target calendar ID
 *   - `id` {Text} — Event ID (takes precedence over `$inEvent.id`)
 * @returns {Object} Status object; includes `event` with the updated event data
 * @description Updates a calendar event via `PATCH /me/calendar/events/{id}`.
 *   Attachments in `$inEvent.attachments` are uploaded separately after the update.
 *   See inline comment for all supported Graph endpoints.
 */
    
/*
    PATCH /me/events/{id}
    PATCH /users/{id | userPrincipalName}/events/{id}
    PATCH /groups/{id}/events/{id}
    
    PATCH /me/calendar/events/{id}
    PATCH /users/{id | userPrincipalName}/calendar/events/{id}
    PATCH /groups/{id}/calendar/events/{id}
    
    PATCH /me/calendars/{id}/events/{id}
    PATCH /users/{id | userPrincipalName}/calendars/{id}/events/{id}
    
    PATCH /me/calendarGroups/{id}/calendars/{id}/events/{id}
    PATCH /users/{id | userPrincipalName}/calendarGroups/{id}/calendars/{id}/events/{id}
*/
    Super._clearErrorStack()
    
    Try
        var $headers : Object:={Accept: "application/json"}
        var $URLString : Text:=This._getURL()
        var $calendarId : Text:=""
        var $eventId : Text:=""
        
        Case of 
            : (Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0)
                $calendarId:=$inParameters.calendarId
            : (Value type($inEvent.calendarId)=Is text) && (Length(String($inEvent.calendarId))>0)
                $calendarId:=$inEvent.calendarId
        End case 
        
        Case of 
            : (Value type($inParameters.id)=Is text) && (Length(String($inParameters.id))>0)
                $eventId:=$inParameters.id
            : (Value type($inEvent.id)=Is text) && (Length(String($inEvent.id))>0)
                $eventId:=$inEvent.id
        End case 
        
        If (Length(String(This.userId))>0)
            $URLString+="users/"+This.userId
        Else 
            $URLString+="me"
        End if 
        
        If (Length(String($calendarId))>0)
            $URLString+="/calendars/"+cs._Tools.me.urlEncode($calendarId)
        Else 
            $URLString+="/calendar"
        End if 
        $URLString+="/events/"+cs._Tools.me.urlEncode($eventId)
        
        var $event : Object:=This._conformEvent(cs._Tools.me.cleanGraphObject($inEvent))
        var $attachments : Collection:=Null
        
        If (Value type($event.attachments)=Is collection) && ($event.attachments.length>0)
            $attachments:=$event.attachments
            OB REMOVE($event; "attachments")
        End if 
        
        var $response : Object:=Super._sendRequestAndWaitResponse("PATCH"; $URLString; $headers; $event)
        
        If ((Value type($attachments)=Is collection) && ($attachments.length>0))
            
            var $params : Object:={eventId: $response.id; calendarId: String($inParameters.calendarId)}
            var $attachment : Object
            
            $response.attachments:=[]
            For each ($attachment; $attachments)
                
                var $result : Object:=This._insertAttachment($params; $attachment)
                If ($result.success)
                    Try
                        OB REMOVE($result; "success")
                        OB REMOVE($result; "errors")
                        OB REMOVE($result; "statusText")
                    End try
                    $response.attachments.push(cs._Tools.me.cleanGraphObject($result))
                Else 
                    return This._returnStatus($result)
                End if 
            End for each 
        End if 
        
        return This._returnStatus({event: cs._Tools.me.cleanGraphObject($response)})
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return This._returnStatus()
    
    
    // Mark: - Notifications
    // ----------------------------------------------------
    
    
Function notifier($inParameters : Object; $inCalendarId : Text) : cs.GraphNotification
/**
 * @function notifier
 * @param {Object} $inParameters - Notification callbacks and options:
 *   - `onCreate` {4D.Function} — Called when an event is created; receives the `eventId`
 *   - `onDelete` {4D.Function} — Called when an event is deleted; receives the `eventId`
 *   - `onModify` {4D.Function} — Called when an event is modified; receives the `eventId`
 *   - `endPoint` {Text} — Webhook URL for push mode; omit to use pull (delta query) mode
 * @param {Text} $inCalendarId - Calendar to subscribe to; defaults to the default calendar
 * @returns {cs.GraphNotification} Notification object with `start()`, `stop()`,
 *   `expiration`, and `isStarted`
 * @description Creates a `GraphNotification` for calendar event change notifications via the
 *   Microsoft Graph subscription API. See inline comment for full parameter details.
 */
    
/*
    Creates a notification object for calendar event change notifications.
    
    The notification object can be started and stopped. When started, it creates
    a Microsoft Graph subscription and dispatches callbacks when changes are detected.
    The subscription is automatically renewed before expiration.
    
    Parameters:
        $inParameters.onCreate : 4D.Function - Called when an event is created. Receives the eventId.
        $inParameters.onDelete : 4D.Function - Called when an event is deleted. Receives the eventId.
        $inParameters.onModify : 4D.Function - Called when an event is modified. Receives the eventId.
        $inParameters.endPoint : Text - Optional. Webhook URL for push mode. If omitted, uses pull (delta query) mode.
        $inCalendarId : Text - Optional. Calendar ID to subscribe to. If omitted, subscribes to the default calendar.
    
    Returns:
        cs.GraphNotification object with start(), stop(), expiration and isStarted.
    
    See: https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions
*/
    
    // Build the resource path for the subscription
    var $resource : Text
    var $deltaResource : Text
    If (Length(String(This.userId))>0)
        $resource:="users/"+This.userId
    Else 
        $resource:="me"
    End if 
    $deltaResource:=$resource
    If (Length(String($inCalendarId))>0)
        $resource+="/calendars/"+cs._Tools.me.urlEncode($inCalendarId)+"/events"
        $deltaResource+="/calendars/"+cs._Tools.me.urlEncode($inCalendarId)+"/calendarView"
    Else 
        $resource+="/events"
        $deltaResource+="/calendarView"
    End if 
    
    var $notif : cs.GraphNotification:=cs.GraphNotification.new("event"; This._getOAuth2Provider(); $inParameters; $resource; This.userId; This)
    $notif._internals._deltaResource:=$deltaResource
    return $notif
