Class extends _GoogleAPI

property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider; "https://www.googleapis.com/calendar/v3/")
    
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Public]
    // Mark: - Calendars
    // ----------------------------------------------------
    
    
Function getCalendar($inID : Text) : Object
    
    // GET https://www.googleapis.com/calendar/v3/users/me/calendarList/calendarId
    
    var $response : Variant:=Null
    
    Case of 
        : (Value type($inID)#Is text)
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
    
    var $options : Object:={}
    $options.url:=This._getURL()+$urlParams
    $options.headers:={Accept: "application/json"}
    
    var $result : cs.GoogleCalendarList:=cs.GoogleCalendarList.new(This._getOAuth2Provider(); $options)
    
    Super._throwErrors(True)
    
    return $result
    
    
    // Mark: - [Public]
    // Mark: - Events
    // ----------------------------------------------------
    
    
Function getEvent($inParameters : Object) : Object
    
    // GET https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    
    Case of 
        : (Value type($inParameters.eventId)#Is text)
            Super._throwError(10; {which: "\"eventId\""; function: "google.calendar.getEvent"})
            
        : ((Value type($inParameters.startDateTime)=Is undefined) && (Value type($inParameters.endDateTime)#Is undefined))
            Super._throwError(9; {which: "\"startDateTime\""; function: "google.calendar.getEvent"})
            
        : ((Value type($inParameters.endDateTime)=Is undefined) && (Value type($inParameters.startDateTime)#Is undefined))
            Super._throwError(9; {which: "\"endDateTime\""; function: "google.calendar.getEvent"})
            
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
            $urlParams+=($delimiter+"timeZone="+cs.Tools.me.urlEncode($timeZone))
            
            var $URL : Text:=This._getURL()+$urlParams
            var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
            
            return cs.GoogleEvent.new($response)
            
    End case 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getEvents($inParameters : Object) : Object
    
    // GET https://www.googleapis.com/calendar/v3/calendars/calendarId/events
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $urlParams : Text:="calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events"
    var $delimiter : Text:="?"
    var $timeZone : Text:=(Length(String($inParameters.timeZone))>0) ? String($inParameters.timeZone) : "UTC"
    var $startDateTime : Text:=""
    var $endDateTime : Text:=""
    
    Case of 
        : (Value type($inParameters.startDateTime)=Is text)
            $startDateTime:=$inParameters.startDateTime
        : (Value type($inParameters.startDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $startDateTime:=String(Date($inParameters.startDateTime.date); ISO date GMT; Time($inParameters.startDateTime.time))
        Else 
            $startDateTime:=String(Current date; ISO date GMT; Current time)
    End case 
    
    Case of 
        : (Value type($inParameters.endDateTime)=Is text)
            $endDateTime:=$inParameters.endDateTime
        : (Value type($inParameters.endDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $endDateTime:=String(Date($inParameters.endDateTime.date); ISO date GMT; Time($inParameters.endDateTime.time))
    End case 
    
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
        $urlParams+=($delimiter+"q="+cs.Tools.me.urlEncode(String($inParameters.search)))
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
    If (Length(String($startDateTime))>0)
        $urlParams+=($delimiter+"timeMin="+cs.Tools.me.urlEncode($startDateTime))
        $delimiter:="&"
    End if 
    If (Length(String($endDateTime))>0)
        $urlParams+=($delimiter+"timeMax="+cs.Tools.me.urlEncode($endDateTime))
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
    $urlParams+=($delimiter+"timeZone="+cs.Tools.me.urlEncode($timeZone))
    
    var $options : Object:={}
    $options.url:=This._getURL()+$urlParams
    $options.headers:={Accept: "application/json"}
    $options.attributes:=["kind"; "etag"; "summary"; "calendarId"; "description"; "updated"; "timeZone"; "accessRole"; "defaultReminders"]
    
    var $result : cs.GoogleEventList:=cs.GoogleEventList.new(This._getOAuth2Provider(); $options)
    
    If ((Value type($result.calendarId)=Is undefined) && (Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
        $result.calendarId:=$inParameters.calendarId
    End if 
    
    Super._throwErrors(True)
    
    return $result
    
    
    // ----------------------------------------------------
    
    
Function createEvent($inEvent : Object; $inParameters : Object) : Object
    
    // POST https://www.googleapis.com/calendar/v3/calendars/calendarId/events
    
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
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $inEvent)
    
    return This._returnStatus({event: cs.GoogleEvent.new($response)})
    
    
    // ----------------------------------------------------
    
    
Function deleteEvent($inParameters : Object) : Object
    
    // DELETE https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    
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
    var $response : Object:=Super._sendRequestAndWaitResponse("DELETE"; $URL; $headers)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function updateEvent($inEvent : Object; $inParameters : Object) : Object
    
    // PUT https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $eventId : Text:=(Length(String($inParameters.eventId))>0) ? $inParameters.eventId : ""
    var $headers : Object:={Accept: "application/json"}
    var $urlParams : Text:="calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events/"+cs.Tools.me.urlEncode($eventId)
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
    var $response : Object:=Super._sendRequestAndWaitResponse("PUT"; $URL; $headers; $inEvent)
    
    return This._returnStatus({event: cs.GoogleEvent.new($response)})
