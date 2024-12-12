Class extends _GraphAPI

property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider)
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
    
    var $URL : Text:=Super._getURLParamsFromObject($inParameters; $inCount)
    var $delimiter : Text:=(Position("&";$URL)>0) ? "&" : "?"
    
    If (Length(String($inParameters.startDateTime))>0)
        $URL+=$delimiter+"startDateTime="+cs.Tools.me.urlEncode(inParameters.startDateTime)
        $delimiter:="&"
    End if 
    If (Length(String($inParameters.endDateTime))>0)
        $URL+=$delimiter+"endDateTime="+cs.Tools.me.urlEncode(inParameters.endDateTime)
        $delimiter:="&"
    End if 

    return $result
    
    
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
        : (Type($inParameters.eventId)#Is text)
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
            
            A user's calendar in the default calendarGroup.
            
                GET /me/calendars/{id}/events
                GET /users/{id | userPrincipalName}/calendars/{id}/events
*/
    var $urlParams : Text:=""
    If (Length(String(This.userId))>0)
        $urlParams+="users/"+This.userId
    Else 
        $urlParams+="me"
    End if 
    If (Length(String($inParameters.calendarId))>0)
        $urlParams+="/calendars/"+$inParameters.calendarId
    Else 
        $urlParams+="/calendar"
    End if 
    $urlParams+="/events"+This._getURLParamsFromObject($inParameters)
    
    var $prefer : Text:=""
    If (Length(String($inParameters.timeZone))>0)
        $prefer+="outlook.timezone="+$inParameters.timeZone
    End if 
    If (Length(String($inParameters.bodyContentType))>0)
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
    
    Super._throwErrors(True)
    
    return $result
