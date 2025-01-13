Class extends _GraphAPI

property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider)
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
    
    var $URL : Text:=Super._getURLParamsFromObject($inParameters; $inCount)
    var $delimiter : Text:=(Position("&"; $URL)>0) ? "&" : "?"
    var $startDateTime : Text:=""
    var $endDateTime : Text:=""
    
    Case of 
        : (Value type($inParameters.startDateTime)=Is text)
            $startDateTime:=$inParameters.startDateTime
        : (Value type($inParameters.startDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $startDateTime:=String(Date($inParameters.startDateTime.date); ISO date GMT; Time($inParameters.startDateTime.time))
    End case 
    
    Case of 
        : (Value type($inParameters.endDateTime)=Is text)
            $endDateTime:=$inParameters.endDateTime
        : (Value type($inParameters.endDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $endDateTime:=String(Date($inParameters.endDateTime.date); ISO date GMT; Time($inParameters.endDateTime.time))
    End case 
    
    If (Length($startDateTime)>0)
        $URL+=$delimiter+"startDateTime="+cs.Tools.me.urlEncode($startDateTime)
        $delimiter:="&"
    End if 
    If (Length($endDateTime)>0)
        $URL+=$delimiter+"endDateTime="+cs.Tools.me.urlEncode($endDateTime)
        $delimiter:="&"
    End if 
    
    return $URL
    
    
Function _deleteEvent($inParameters : Object) : Object  // For test purposes only (subject to changes, use at your own risk)
    
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
    
    var $headers : Object:={Accept: "application/json"}
    var $urlParams : Text:=""
    
    If (Length(String(This.userId))>0)
        $urlParams:="users/"+This.userId
    Else 
        $urlParams:="me"
    End if 
    If (Length(String($inParameters.calendarId))>0)
        $urlParams+="/calendars/"+cs.Tools.me.urlEncode($inParameters.calendarId)
    Else 
        $urlParams+="/calendar"
    End if 
    $urlParams+="/events"
    If (Length(String($inParameters.eventId))>0)
        $urlParams+="/"+cs.Tools.me.urlEncode($inParameters.eventId)
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $response : Object:=Super._sendRequestAndWaitResponse("DELETE"; $URL; $headers)
    
    return This._returnStatus($response)
    
    
    // ----------------------------------------------------
    
    
Function _insertEvent($inParameters : Object; $inEvent : Object) : Object  // For test purposes only (subject to changes, use at your own risk)
    
/*
    POST /me/events
    POST /users/{id | userPrincipalName}/events
    
    POST /me/calendar/events
    POST /users/{id | userPrincipalName}/calendar/events
    
    POST /me/calendars/{id}/events
    POST /users/{id | userPrincipalName}/calendars/{id}/events
*/
    var $headers : Object:={Accept: "application/json"}
    var $urlParams : Text:=""
    
    If (Length(String(This.userId))>0)
        $urlParams:="users/"+This.userId
    Else 
        $urlParams:="me"
    End if 
    
    If (Length(String($inParameters.calendarId))>0)
        $urlParams+="/calendars/"+cs.Tools.me.urlEncode($inParameters.calendarId)
    Else 
        $urlParams+="/calendar"
    End if 
    $urlParams+="/events"
    
    var $URL : Text:=This._getURL()+$urlParams
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $inEvent)
    
    return This._returnStatus($response)
    
    
    // Mark: - [Public]
    // Mark: - Calendars
    // ----------------------------------------------------
    
    
Function getCalendar($inID : Text; $inSelect : Text) : Object
    
    var $urlParams : Text:=""
    
    If (Length(String(This.userId))>0)
        $urlParams:="users/"+This.userId
    Else 
        $urlParams:="me"
    End if 
    
    If (Length(String($inID))>0)
        $urlParams+="/calendars/"+cs.Tools.me.urlEncode($inID)
    Else 
        $urlParams+="/calendar"
    End if 
    
    If (Length(String($inSelect))>0)
        $urlParams+=Super._getURLParamsFromObject({select: $inSelect})
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL)
    
    If (Value type($response)=Is object)
        return Super._cleanGraphObject($response)
    End if 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getCalendars($inParameters : Object) : Object
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $headers : Object:={}
    var $urlParams : Text:=""
    
    If (Length(String(This.userId))>0)
        $urlParams:="users/"+This.userId
    Else 
        $urlParams:="me"
    End if 
    $urlParams+="/calendars"+Super._getURLParamsFromObject($inParameters)
    
    If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
        $headers.ConsistencyLevel:="eventual"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $result : cs.GraphCalendarList:=cs.GraphCalendarList.new(This._getOAuth2Provider(); $URL; $headers)
    
    Super._throwErrors(True)
    
    return $result
    
    
    // Mark: - Events
    // ----------------------------------------------------
    
    
Function getEvent($inParameters : Object) : Object
    
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
            
        Else 
            var $headers : Object:={}
            var $urlParams : Text:=""
            
            If (Length(String(This.userId))>0)
                $urlParams:="users/"+This.userId
            Else 
                $urlParams:="me"
            End if 
            
            If ((Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
                $urlParams+="/calendars/"+cs.Tools.me.urlEncode($inParameters.calendarId)
            Else 
                $urlParams+="/calendar"
            End if 
            $urlParams+="/events/"+cs.Tools.me.urlEncode($inParameters.eventId)
            
            $urlParams+=This._getURLParamsFromObject($inParameters)
            
            var $prefer : Text:=""
            If (Length(String($inParameters.timeZone))>0)
                $prefer+="outlook.timezone="+$inParameters.timeZone+" "
            End if 
            If (Length(String($inParameters.bodyContentType))>0)
                $prefer+="outlook.body-content-type="+$inParameters.bodyContentType+" "
            End if 
            If (Length($prefer)>0)
                $headers.Prefer:=$prefer
            End if 
            
            var $URL : Text:=This._getURL()+$urlParams
            var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
            
            If (Value type($response)=Is object)
                return Super._cleanGraphObject($response)
            End if 
    End case 
    
    return Null
    
    
Function getEvents($inParameters : Object) : Object
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
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
    var $headers : Object:={}
    var $urlParams : Text:=""
    If (Length(String(This.userId))>0)
        $urlParams+="users/"+This.userId
    Else 
        $urlParams+="me"
    End if 
    If ((Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
        $urlParams+="/calendars/"+$inParameters.calendarId
    Else 
        $urlParams+="/calendar"
    End if 
    If ((Value type($inParameters.startDateTime)=Is text) && (Length(String($inParameters.startDateTime))>0)\
      && (Value type($inParameters.endDateTime)=Is text) && (Length(String($inParameters.endDateTime))>0))
        $urlParams+="/calendarView"+This._getURLParamsFromObject($inParameters)
    Else 
        $urlParams+="/events"+This._getURLParamsFromObject($inParameters)
    End if 
    
    var $prefer : Text:=""
    If ((Value type($inParameters.timeZone)=Is text) && (Length(String($inParameters.timeZone))>0))
        $prefer+="outlook.timezone="+$inParameters.timeZone
    End if 
    If ((Value type($inParameters.bodyContentType)=Is text) && (Length(String($inParameters.bodyContentType))>0))
        $prefer+=((Length($prefer)>0) ? "; " : "")+"outlook.body-content-type="+$inParameters.bodyContentType+" "
    End if 
    If (Length($prefer)>0)
        $headers.Prefer:=$prefer
    End if 
    
    If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
        $headers.ConsistencyLevel:="eventual"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $result : cs.GraphEventList:=cs.GraphEventList.new(This._getOAuth2Provider(); $URL; $headers)
    
    If ((Value type($result.calendarId)=Is undefined) && (Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
        $result.calendarId:=$inParameters.calendarId
    End if 
    
    Super._throwErrors(True)
    
    return $result
