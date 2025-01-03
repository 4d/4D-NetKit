Class extends _GoogleAPI

property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider; "https://www.googleapis.com/calendar/v3/")
    
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
    // Mark: - [Public]
    // Mark: - Calendars
    // ----------------------------------------------------
    
    
Function getCalendar($inID : Text) : Object
    
    // GET https://www.googleapis.com/calendar/v3/users/me/calendarList/calendarId
    
    var $response : Variant:=Null
    
    Case of 
        : (Type($inID)#Is text)
            Super._throwError(10; {which: "\"calendarId\""; function: "google.calendar.getCalendar"})
            
        Else 
            
            var $calendarID : Text:=(Length(String($inID))>0) ? $inID : "primary"
            var $URL : Text:=Super._getURL()+"users/me/calendarList/"+cs.Tools.me.urlEncode($calendarID)
            var $headers : Object:={Accept: "application/json"}
            $response:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
            
    End case 
    
    return $response
    
    
    // ----------------------------------------------------
    
    
Function getCalendars($inParameters : Object) : Object
    
    // GET https://www.googleapis.com/calendar/v3/users/me/calendarList
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $headers : Object:={Accept: "application/json"}
    var $urlParams : Text:=""
    var $delimiter : Text:="?"
    
    $urlParams:="users/me/calendarList"
    
    If (Not(Value type($inParameters.top)=Is undefined))
        $urlParams+=($delimiter+"maxResults="+Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.minAccessRole)=Is undefined))
        $urlParams+=($delimiter+"minAccessRole="+String($inParameters.minAccessRole))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.pageToken)=Is undefined))
        $urlParams+=($delimiter+"pageToken="+String($inParameters.pageToken))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.showHidden)=Is undefined))
        $urlParams+=($delimiter+"showHidden="+Choose(Bool($inParameters.showHidden); "true"; "false"))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.showDeleted)=Is undefined))
        $urlParams+=($delimiter+"showDeleted="+Choose(Bool($inParameters.showDeleted); "true"; "false"))
        $delimiter:="&"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $result : cs.GoogleCalendarList:=cs.GoogleCalendarList.new(This._getOAuth2Provider(); $URL; $headers)
    
    Super._throwErrors(True)
    
    return $result
    
    
    // Mark: - [Private]
    // Mark: - Events
    // ----------------------------------------------------
    
    
Function _deleteEvent($inParameters : Object) : Object  // For test purposes only (subject to changes, use at your own risk)
    
    // DELETE https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    
    var $response : Variant:=Null
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $eventId : Text:=(Length(String($inParameters.eventId))>0) ? $inParameters.eventId : ""
    var $headers : Object:={Accept: "application/json"}
    var $urlParams : Text:="calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events/"+cs.Tools.me.urlEncode($eventId)
    var $delimiter : Text:="?"
    
    If (Not(Value type($inParameters.sendNotifications)=Is undefined))
        $urlParams+=($delimiter+"sendNotifications="+Choose(Bool($inParameters.sendNotifications); "true"; "false"))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.sendUpdates)=Is text) && (Length(String($inParameters.sendUpdates))>0))
        $urlParams+=($delimiter+"sendUpdates="+$inParameters.sendUpdates)  // "all", "externalOnly", "none"
        $delimiter:="&"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    $response:=Super._sendRequestAndWaitResponse("DELETE"; $URL; $headers)
    
    return This._returnStatus($response)
    
    
    // ----------------------------------------------------
    
    
Function _insertEvent($inParameters : Object; $inEvent : Object) : Object  // For test purposes only (subject to changes, use at your own risk)
    
    // POST https://www.googleapis.com/calendar/v3/calendars/calendarId/events
    
    var $response : Variant:=Null
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $headers : Object:={Accept: "application/json"}
    var $urlParams : Text:="calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events"
    var $delimiter : Text:="?"
    
    If (Not(Value type($inParameters.conferenceDataVersion)=Is undefined))
        $urlParams+=($delimiter+"conferenceDataVersion="+Choose(Value type($inParameters.conferenceDataVersion)=Is text; $inParameters.conferenceDataVersion; String($inParameters.conferenceDataVersion)))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.maxAttendees)=Is undefined))
        $urlParams+=($delimiter+"maxAttendees="+Choose(Value type($inParameters.maxAttendees)=Is text; $inParameters.maxAttendees; String($inParameters.maxAttendees)))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.sendNotifications)=Is undefined))
        $urlParams+=($delimiter+"sendNotifications="+Choose(Bool($inParameters.sendNotifications); "true"; "false"))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.sendUpdates)=Is text) && (Length(String($inParameters.sendUpdates))>0))
        $urlParams+=($delimiter+"sendUpdates="+$inParameters.sendUpdates)  // "all", "externalOnly", "none"
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.supportsAttachments)=Is undefined))
        $urlParams+=($delimiter+"supportsAttachments="+Choose(Bool($inParameters.supportsAttachments); "true"; "false"))
        $delimiter:="&"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    $response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $inEvent)
    
    return This._returnStatus($response)
    
    
    // Mark: - [Public]
    // Mark: - Events
    // ----------------------------------------------------
    
    
Function getEvent($inParameters : Object) : Object
    
    // GET https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    
    var $response : Variant:=Null
    
    Case of 
        : (Type($inParameters.eventId)#Is text)
            Super._throwError(10; {which: "\"eventId\""; function: "google.calendar.getEvent"})
            
        Else 
            
            var $eventId : Text:=$inParameters.eventId
            var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
            var $timeZone : Text:=(Length(String($inParameters.timeZone))>0) ? String($inParameters.timeZone) : "UTC"
            var $headers : Object:={Accept: "application/json"}
            var $urlParams : Text:="calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events/"+cs.Tools.me.urlEncode($eventId)
            var $delimiter : Text:="?"
            
            If (Not(Value type($inParameters.maxAttendees)=Is undefined))
                $urlParams+=($delimiter+"maxAttendees="+Choose(Value type($inParameters.maxAttendees)=Is text; $inParameters.maxAttendees; String($inParameters.maxAttendees)))
                $delimiter:="&"
            End if 
            $urlParams+=($delimiter+"timeZone="+String($timeZone))
            
            var $URL : Text:=This._getURL()+$urlParams
            $response:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
            
    End case 
    
    return $response
    
    
    // ----------------------------------------------------
    
    
Function getEvents($inParameters : Object) : Object
    
    // GET https://www.googleapis.com/calendar/v3/calendars/calendarId/events
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $headers : Object:={Accept: "application/json"}
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $urlParams : Text:="calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events"
    var $delimiter : Text:="?"
    var $timeZone : Text:=(Length(String($inParameters.timeZone))>0) ? String($inParameters.timeZone) : "UTC"
    
    If ((Value type($inParameters.eventTypes)=Is text) && (Length(String($inParameters.eventTypes))>0))
        $urlParams+=($delimiter+"eventTypes="+$inParameters.eventTypes)
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.iCalUID)=Is text) && (Length(String($inParameters.iCalUID))>0))
        $urlParams+=($delimiter+"iCalUID="+String($inParameters.iCalUID))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.maxAttendees)=Is undefined))
        $urlParams+=($delimiter+"maxAttendees="+Choose(Value type($inParameters.maxAttendees)=Is text; $inParameters.maxAttendees; String($inParameters.maxAttendees)))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.top)=Is undefined))
        $urlParams+=($delimiter+"maxResults="+Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.orderBy)=Is text) && (Length(String($inParameters.orderBy))>0))
        $urlParams+=($delimiter+"orderBy="+String($inParameters.orderBy))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
        $urlParams+=($delimiter+"search="+String($inParameters.search))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.showDeleted)=Is undefined))
        $urlParams+=($delimiter+"showDeleted="+Choose(Bool($inParameters.showDeleted); "true"; "false"))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.showHiddenInvitations)=Is undefined))
        $urlParams+=($delimiter+"showHiddenInvitations="+Choose(Bool($inParameters.showHiddenInvitations); "true"; "false"))
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.singleEvents)=Is undefined))
        $urlParams+=($delimiter+"singleEvents="+Choose(Bool($inParameters.singleEvents); "true"; "false"))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.timeZone)=Is text) && (Length(String($inParameters.timeZone))>0))
        $urlParams+=($delimiter+"timeZone="+String($inParameters.timeZone))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.startDateTime)=Is text) && (Length(String($inParameters.startDateTime))>0))
        // TODO: Convert to RFC3339 using the correct timeZone
        $urlParams+=($delimiter+"timeMin="+String($inParameters.startDateTime))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.endDateTime)=Is text) && (Length(String($inParameters.endDateTime))>0))
        // TODO: Convert to RFC3339 using the correct timeZone
        $urlParams+=($delimiter+"timeMax="+String($inParameters.endDateTime))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.updatedMin)=Is text) && (Length(String($inParameters.updatedMin))>0))
        $urlParams+=($delimiter+"updatedMin="+String($inParameters.updatedMin))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.privateExtendedProperty)=Is text) && (Length(String($inParameters.privateExtendedProperty))>0))
        $urlParams+=($delimiter+"privateExtendedProperty="+String($inParameters.privateExtendedProperty))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.sharedExtendedProperty)=Is text) && (Length(String($inParameters.sharedExtendedProperty))>0))
        $urlParams+=($delimiter+"sharedExtendedProperty="+String($inParameters.sharedExtendedProperty))
        $delimiter:="&"
    End if 
    $urlParams+=($delimiter+"timeZone="+String($timeZone))
    
    var $URL : Text:=This._getURL()+$urlParams
    
    var $additionalAttributes : Collection:=["kind"; "etag"; "summary"; "calendarId"; "description"; "updated"; "timeZone"; "accessRole"; "defaultReminders"]
    var $result : cs.GoogleEventList:=cs.GoogleEventList.new(This._getOAuth2Provider(); $URL; $headers; $additionalAttributes)
    
    If ((Value type($result.calendarId)=Is undefined) && (Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
        $result.calendarId:=$inParameters.calendarId
    End if 
    
    Super._throwErrors(False)
    
    return $result
