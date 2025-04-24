Class extends _GraphAPI

property userId : Text:=""
property id : Text:=""

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
    var $dateTime : cs.DateTime
    
    Case of 
        : (Value type($inParameters.startDateTime)=Is text)
            $dateTime:=cs.DateTime.new($inParameters.startDateTime)
            $startDateTime:=$dateTime.getDateTimeURLParameter()
        : (Value type($inParameters.startDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $dateTime:=cs.DateTime.new(Date($inParameters.startDateTime.date); Time($inParameters.startDateTime.time))
            $startDateTime:=$dateTime.getDateTimeURLParameter()
    End case 
    
    Case of 
        : (Value type($inParameters.endDateTime)=Is text)
            $dateTime:=cs.DateTime.new($inParameters.endDateTime)
            $endDateTime:=$dateTime.getDateTimeURLParameter()
        : (Value type($inParameters.endDateTime)=Is object)  // It assumes that object value is like {date: "2020-01-01"; time: "00:00:00"}
            $dateTime:=cs.DateTime.new(Date($inParameters.endDateTime.date); Time($inParameters.endDateTime.time))
            $endDateTime:=$dateTime.getDateTimeURLParameter()
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
    
    
    // ----------------------------------------------------
    
    
Function _conformEventDateTime($inObject : Object) : Object
    
    var $event : Object:=$inObject
    var $dateTime : cs.DateTime
    
    If (OB Is defined($event; "end"))
        Case of 
            : ((Value type($event.end.date)=Is date) && (Value type($event.end.time)=Is time))
                $dateTime:=cs.DateTime.new($event.end.date; $event.end.time)
                $event.end:=$dateTime.getGraphDateTime()
            : (Value type($event.end.dateTime)=Is text)
                $dateTime:=cs.DateTime.new($event.end.dateTime)
                $event.end:=$dateTime.getGraphDateTime()
        End case 
    End if 
    
    If (OB Is defined($event; "start"))
        Case of 
            : ((Value type($event.start.date)=Is date) && (Value type($event.start.time)=Is time))
                $dateTime:=cs.DateTime.new($event.start.date; $event.start.time)
                $event.start:=$dateTime.getGraphDateTime()
            : (Value type($event.start.dateTime)=Is text)
                $dateTime:=cs.DateTime.new($event.start.dateTime)
                $event.start:=$dateTime.getGraphDateTime()
        End case 
    End if 
    
    return $event
    
    
    // ----------------------------------------------------
    
    
Function _insertAttachment($inParameters : Object; $inAttachement : Object) : Object  // For test purposes only (subject to changes, use at your own risk)
    
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
            $urlParams+="/events/"+cs.Tools.me.urlEncode($inParameters.eventId)+"/attachments"
            
            var $URL : Text:=This._getURL()+$urlParams
            var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $inAttachement)
            
            return This._returnStatus($response)
    End case 
    
    return This._returnStatus()
    
    
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
            
        : ((Value type($inParameters.startDateTime)=Is undefined) && (Value type($inParameters.endDateTime)#Is undefined))
            Super._throwError(9; {which: "\"startDateTime\""; function: "office365.calendar.getEvent"})
            
        : ((Value type($inParameters.endDateTime)=Is undefined) && (Value type($inParameters.startDateTime)#Is undefined))
            Super._throwError(9; {which: "\"endDateTime\""; function: "office365.calendar.getEvent"})
            
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
                $prefer+="outlook.timezone="+cs.Tools.me.quoteString($inParameters.timeZone)+" "
            End if 
            If (Length(String($inParameters.bodyContentType))>0)
                $prefer+="outlook.body-content-type="+cs.Tools.me.quoteString($inParameters.bodyContentType)+" "
            End if 
            If (Length($prefer)>0)
                $headers.Prefer:=$prefer
            End if 
            
            var $URL : Text:=This._getURL()+$urlParams
            var $result : Object:=Super._cleanGraphObject(Super._sendRequestAndWaitResponse("GET"; $URL; $headers))
            
            If (Value type($result)=Is object)
                var $options : Object:={userId: This.userId; calendarId: String($inParameters.calendarId); eventId: String($inParameters.eventId)}
                return cs.GraphEvent.new(This._internals._oAuth2Provider; $options; $result)
            End if 
    End case 
    
    return Null
    
    
Function getEvents($inParameters : Object) : Object
    
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
    Super._throwErrors(False)
    
    Case of 
        : ((Value type($inParameters.startDateTime)=Is undefined) && (Value type($inParameters.endDateTime)#Is undefined))
            Super._throwError(9; {which: "\"startDateTime\""; function: "office365.calendar.getEvent"})
            
        : ((Value type($inParameters.endDateTime)=Is undefined) && (Value type($inParameters.startDateTime)#Is undefined))
            Super._throwError(9; {which: "\"endDateTime\""; function: "office365.calendar.getEvent"})
            
        Else 
            var $headers : Object:={}
            var $urlParams : Text:=""
            If (Length(String(This.userId))>0)
                $urlParams+="users/"+This.userId
            Else 
                $urlParams+="me"
            End if 
            If ((Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
                $urlParams+="/calendars/"+$inParameters.calendarId
                This.id:=$inParameters.calendarId
            Else 
                $urlParams+="/calendar"
            End if 
            If ((Value type($inParameters.startDateTime)#Is undefined) && (Value type($inParameters.endDateTime)#Is undefined))
                $urlParams+="/calendarView"+This._getURLParamsFromObject($inParameters)
            Else 
                $urlParams+="/events"+This._getURLParamsFromObject($inParameters)
            End if 
            
            var $prefer : Text:=""
            If ((Value type($inParameters.timeZone)=Is text) && (Length(String($inParameters.timeZone))>0))
                $prefer+="outlook.timezone="+cs.Tools.me.quoteString($inParameters.timeZone)
            End if 
            If ((Value type($inParameters.bodyContentType)=Is text) && (Length(String($inParameters.bodyContentType))>0))
                $prefer+=((Length($prefer)>0) ? "; " : "")+"outlook.body-content-type="+cs.Tools.me.quoteString($inParameters.bodyContentType)+" "
            End if 
            If (Length($prefer)>0)
                $headers.Prefer:=$prefer
            End if 
            
            If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
                $headers.ConsistencyLevel:="eventual"
            End if 
            
            var $URL : Text:=This._getURL()+$urlParams
            var $result : cs.GraphEventList:=cs.GraphEventList.new(This; $URL; $headers)
            
            If (Not(OB Is defined($result; "calendarId")) && (Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
                $result.calendarId:=$inParameters.calendarId
            End if 
            
            Super._throwErrors(True)
            
            return $result
            
    End case 
    
    Super._throwErrors(True)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function createEvent($inEvent : Object; $inParameters : Object) : Object
    
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
    var $event : Object:=This._conformEventDateTime(Super._cleanGraphObject($inEvent))
    var $attachments : Collection:=Null
    
    If (Value type($event.attachments)=Is collection) && ($event.attachments.length>0)
        $attachments:=$event.attachments
        OB REMOVE($event; "attachments")
    End if 
    
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $event)
    
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
                $response.attachments.push(This._cleanGraphObject($result))
            Else 
                return This._returnStatus($result)
            End if 
        End for each 
    End if 
    
    return This._returnStatus({event: This._cleanGraphObject($response)})
    
    
    // ----------------------------------------------------
    
    
Function deleteEvent($inParameters : Object) : Object
    
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
    Super._sendRequestAndWaitResponse("DELETE"; $URL; $headers)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function updateEvent($inEvent : Object; $inParameters : Object) : Object
    
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
    var $event : Object:=This._conformEventDateTime(Super._cleanGraphObject($inEvent))
    var $attachments : Collection:=Null
    
    If (Value type($event.attachments)=Is collection) && ($event.attachments.length>0)
        $attachments:=$event.attachments
        OB REMOVE($event; "attachments")
    End if 
    
    var $response : Object:=Super._sendRequestAndWaitResponse("PATCH"; $URL; $headers; $event)
    
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
                $response.attachments.push(This._cleanGraphObject($result))
            Else 
                return This._returnStatus($result)
            End if 
        End for each 
    End if 
    
    return This._returnStatus({event: This._cleanGraphObject($response)})
