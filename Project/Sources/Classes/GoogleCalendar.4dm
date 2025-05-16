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
    var $URL : cs.URL:=cs.URL.new(This._getURL()+"users/me/calendarList")
    
    If (Not(Value type($inParameters.top)=Is undefined))
        $URL.addQueryParameter("maxResults"; Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
    End if 
    If (Not(Value type($inParameters.minAccessRole)=Is undefined))
        $URL.addQueryParameter("minAccessRole"; String($inParameters.minAccessRole))
    End if 
    If (Not(Value type($inParameters.pageToken)=Is undefined))
        $URL.addQueryParameter("pageToken"; String($inParameters.pageToken))
    End if 
    If (Not(Value type($inParameters.showHidden)=Is undefined))
        $URL.addQueryParameter("showHidden"; Choose(Bool($inParameters.showHidden); "true"; "false"))
    End if 
    If (Not(Value type($inParameters.showDeleted)=Is undefined))
        $URL.addQueryParameter("showDeleted"; Choose(Bool($inParameters.showDeleted); "true"; "false"))
    End if 
    
    var $options : Object:={}
    $options.url:=$URL.toString()
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
            var $URL : cs.URL:=cs.URL.new(This._getURL()+"calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events/"+cs.Tools.me.urlEncode($eventId))
            
            If (Not(Value type($inParameters.maxAttendees)=Is undefined))
                $URL.addQueryParameter("maxAttendees"; Choose(Value type($inParameters.maxAttendees)=Is text; $inParameters.maxAttendees; String($inParameters.maxAttendees)))
            End if 
            $URL.addQueryParameter("timeZone"; cs.Tools.me.urlEncode($timeZone))
            
            var $URLString : Text:=$URL.toString()
            var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URLString; $headers)
            
            return cs.GoogleEvent.new($response)
            
    End case 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getEvents($inParameters : Object) : Object
    
    // GET https://www.googleapis.com/calendar/v3/calendars/calendarId/events
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $URL : cs.URL:=cs.URL.new(This._getURL()+"calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events")
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
        $URL.addQueryParameter("eventTypes"; $inParameters.eventTypes)
    End if 
    If ((Value type($inParameters.iCalUID)=Is text) && (Length(String($inParameters.iCalUID))>0))
        $URL.addQueryParameter("iCalUID"; String($inParameters.iCalUID))
    End if 
    If (Not(Value type($inParameters.maxAttendees)=Is undefined))
        $URL.addQueryParameter("maxAttendees"; Choose(Value type($inParameters.maxAttendees)=Is text; $inParameters.maxAttendees; String($inParameters.maxAttendees)))
    End if 
    If (Not(Value type($inParameters.top)=Is undefined))
        $URL.addQueryParameter("maxResults"; Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
    End if 
    If ((Value type($inParameters.orderBy)=Is text) && (Length(String($inParameters.orderBy))>0))
        $URL.addQueryParameter("orderBy"; String($inParameters.orderBy))
    End if 
    If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
        $URL.addQueryParameter("q"; cs.Tools.me.urlEncode(String($inParameters.search)))
    End if 
    If (Not(Value type($inParameters.showDeleted)=Is undefined))
        $URL.addQueryParameter("showDeleted"; Choose(Bool($inParameters.showDeleted); "true"; "false"))
    End if 
    If (Not(Value type($inParameters.showHiddenInvitations)=Is undefined))
        $URL.addQueryParameter("showHiddenInvitations"; Choose(Bool($inParameters.showHiddenInvitations); "true"; "false"))
    End if 
    If (Not(Value type($inParameters.singleEvents)=Is undefined))
        $URL.addQueryParameter("singleEvents"; Choose(Bool($inParameters.singleEvents); "true"; "false"))
    End if 
    If (Length(String($startDateTime))>0)
        $URL.addQueryParameter("timeMin"; cs.Tools.me.urlEncode($startDateTime))
    End if 
    If (Length(String($endDateTime))>0)
        $URL.addQueryParameter("timeMax"; cs.Tools.me.urlEncode($endDateTime))
    End if 
    If ((Value type($inParameters.updatedMin)=Is text) && (Length(String($inParameters.updatedMin))>0))
        $URL.addQueryParameter("updatedMin"; String($inParameters.updatedMin))
    End if 
    If ((Value type($inParameters.privateExtendedProperty)=Is text) && (Length(String($inParameters.privateExtendedProperty))>0))
        $URL.addQueryParameter("privateExtendedProperty"; String($inParameters.privateExtendedProperty))
    End if 
    If ((Value type($inParameters.sharedExtendedProperty)=Is text) && (Length(String($inParameters.sharedExtendedProperty))>0))
        $URL.addQueryParameter("sharedExtendedProperty"; String($inParameters.sharedExtendedProperty))
    End if 
    $URL.addQueryParameter("timeZone"; cs.Tools.me.urlEncode($timeZone))
    
    var $options : Object:={}
    $options.url:=$URL.toString()
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
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $headers : Object:={Accept: "application/json"}
    var $URL : cs.URL:=cs.URL.new(This._getURL()+"calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events")
    
    If (Not(Value type($inParameters.conferenceDataVersion)=Is undefined))
        $URL.addQueryParameter("conferenceDataVersion"; Choose(Value type($inParameters.conferenceDataVersion)=Is text; $inParameters.conferenceDataVersion; String($inParameters.conferenceDataVersion)))
    End if 
    If (Not(Value type($inParameters.maxAttendees)=Is undefined))
        $URL.addQueryParameter("maxAttendees"; Choose(Value type($inParameters.maxAttendees)=Is text; $inParameters.maxAttendees; String($inParameters.maxAttendees)))
    End if 
    If (Not(Value type($inParameters.sendNotifications)=Is undefined))
        $URL.addQueryParameter("sendNotifications"; Choose(Bool($inParameters.sendNotifications); "true"; "false"))
    End if 
    If ((Value type($inParameters.sendUpdates)=Is text) && (Length(String($inParameters.sendUpdates))>0))
        $URL.addQueryParameter("sendUpdates"; $inParameters.sendUpdates)  // "all", "externalOnly", "none"
    End if 
    If (Not(Value type($inParameters.supportsAttachments)=Is undefined))
        $URL.addQueryParameter("supportsAttachments"; Choose(Bool($inParameters.supportsAttachments); "true"; "false"))
    End if 
    
    var $URLString : Text:=$URL.toString()
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URLString; $headers; $inEvent)
    
    Super._throwErrors(True)
    
    return This._returnStatus({event: cs.GoogleEvent.new($response)})
    
    
    // ----------------------------------------------------
    
    
Function deleteEvent($inParameters : Object) : Object
    
    // DELETE https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $eventId : Text:=(Length(String($inParameters.eventId))>0) ? $inParameters.eventId : ""
    var $headers : Object:={Accept: "application/json"}
    var $URL : cs.URL:=cs.URL.new(This._getURL()+"calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events/"+cs.Tools.me.urlEncode($eventId))
    
    If (Not(Value type($inParameters.sendNotifications)=Is undefined))
        $URL.addQueryParameter("sendNotifications"; Choose(Bool($inParameters.sendNotifications); "true"; "false"))
    End if 
    If ((Value type($inParameters.sendUpdates)=Is text) && (Length(String($inParameters.sendUpdates))>0))
        $URL.addQueryParameter("sendUpdates"; $inParameters.sendUpdates)  // "all", "externalOnly", "none"
    End if 
    
    var $URLString : Text:=$URL.toString()
    var $response : Object:=Super._sendRequestAndWaitResponse("DELETE"; $URLString; $headers)
    
    Super._throwErrors(True)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function updateEvent($inEvent : Object; $inParameters : Object) : Object
    
    // PUT https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    // or
    // PATCH https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
    
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $calendarId : Text:=(Length(String($inParameters.calendarId))>0) ? $inParameters.calendarId : "primary"
    var $eventId : Text:=(Length(String($inEvent.id))>0) ? $inEvent.id : ""
    var $headers : Object:={Accept: "application/json"}
    var $URL : cs.URL:=cs.URL.new(This._getURL()+"calendars/"+cs.Tools.me.urlEncode($calendarID)+"/events/"+cs.Tools.me.urlEncode($eventId))
    var $bFullUpdate : Boolean:=False
    
    If (Value type($inParameters.conferenceDataVersion)#Is undefined)
        $URL.addQueryParameter("conferenceDataVersion"; Choose(Value type($inParameters.conferenceDataVersion)=Is text; $inParameters.conferenceDataVersion; String($inParameters.conferenceDataVersion)))
    End if 
    If (Value type($inParameters.maxAttendees)#Is undefined)
        $URL.addQueryParameter("maxAttendees"; Choose(Value type($inParameters.maxAttendees)=Is text; $inParameters.maxAttendees; String($inParameters.maxAttendees)))
    End if 
    If (Value type($inParameters.sendNotifications)#Is undefined)
        $URL.addQueryParameter("sendNotifications"; Choose(Bool($inParameters.sendNotifications); "true"; "false"))
    End if 
    If ((Value type($inParameters.sendUpdates)=Is text) && (Length(String($inParameters.sendUpdates))>0))
        $URL.addQueryParameter("sendUpdates"; $inParameters.sendUpdates)  // "all", "externalOnly", "none"
    End if 
    If (Value type($inParameters.supportsAttachments)#Is undefined)
        $URL.addQueryParameter("supportsAttachments"; Choose(Bool($inParameters.supportsAttachments); "true"; "false"))
    End if 
    If (Value type($inParameters.fullUpdate)#Is undefined)
        $bFullUpdate:=Bool($inParameters.fullUpdate)
    End if 
    
    var $URLString : Text:=$URL.toString()
    var $response : Object:=Super._sendRequestAndWaitResponse($bFullUpdate ? "PUT" : "PATCH"; $URLString; $headers; $inEvent)
    
    Super._throwErrors(True)
    
    return This._returnStatus({event: cs.GoogleEvent.new($response)})
