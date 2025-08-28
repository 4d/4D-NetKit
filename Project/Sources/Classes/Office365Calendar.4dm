Class extends _GraphAPI

property userId : Text:=""
property id : Text:=""

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider)
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
    
    var $URL : cs.URL:=cs.URL.new(Super._getURLParamsFromObject($inParameters; $inCount))
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
        $URL.addQueryParameter("startDateTime"; cs.Tools.me.urlEncode($startDateTime))
    End if 
    If (Length($endDateTime)>0)
        $URL.addQueryParameter("endDateTime"; cs.Tools.me.urlEncode($endDateTime))
    End if 
    
    return $URL.toString()
    
    
    // ----------------------------------------------------
    
    
Function _conformEventDateTime($inObject : Object; $inName : Text) : Object
    
    var $dateTime : cs.DateTime
    var $timeZone : Text:=((Value type($inObject[$inName].timeZone)=Is text) && (Length($inObject[$inName].timeZone)>0)) ? String($inObject[$inName].timeZone) : ""
    Case of 
        : (Value type($inObject[$inName].dateTime)=Is text)
            $dateTime:=cs.DateTime.new({dateTime: $inObject[$inName].dateTime; timeZone: $timeZone})
            return $dateTime.getGraphDateTime()
        : ((Value type($inObject[$inName].date)=Is date) && (Value type($inObject[$inName].time)#Is undefined))
            $dateTime:=cs.DateTime.new({date: $inObject[$inName].date; time: $inObject[$inName].time; timeZone: $timeZone})
            return $dateTime.getGraphDateTime()
    End case 
    
    return $inObject[$inName]
    
    
    // ----------------------------------------------------
    
    
Function _conformEvent($inObject : Object) : Object
    
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
                $URLString+="/calendars/"+cs.Tools.me.urlEncode($inParameters.calendarId)
            Else 
                $URLString+="/calendar"
            End if 
            $URLString+="/events/"+cs.Tools.me.urlEncode($inParameters.eventId)+"/attachments"
            
            var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URLString; $headers; $inAttachement)
            
            return This._returnStatus($response)
    End case 
    
    return This._returnStatus()
    
    
    // Mark: - [Public]
    // Mark: - Calendars
    // ----------------------------------------------------
    
    
Function getCalendar($inID : Text; $inSelect : Text) : Object
    
    var $URLString : Text:=""
    
    If (Length(String(This.userId))>0)
        $URLString:="users/"+This.userId
    Else 
        $URLString:="me"
    End if 
    
    If (Length(String($inID))>0)
        $URLString+="/calendars/"+cs.Tools.me.urlEncode($inID)
    Else 
        $URLString+="/calendar"
    End if 
    
    If (Length(String($inSelect))>0)
        $URLString+=Super._getURLParamsFromObject({select: $inSelect})
    End if 
    
    var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; This._getURL()+$URLString)
    
    If (Value type($response)=Is object)
        return Super._cleanGraphObject($response)
    End if 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getCalendars($inParameters : Object) : Object
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
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
    
    var $result : cs.GraphCalendarList:=cs.GraphCalendarList.new(This._getOAuth2Provider(); This._getURL()+$URLString; $headers)
    
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
            var $URLString : Text:=""
            
            If (Length(String(This.userId))>0)
                $URLString:="users/"+This.userId
            Else 
                $URLString:="me"
            End if 
            
            If ((Value type($inParameters.calendarId)=Is text) && (Length(String($inParameters.calendarId))>0))
                $URLString+="/calendars/"+cs.Tools.me.urlEncode($inParameters.calendarId)
            Else 
                $URLString+="/calendar"
            End if 
            $URLString+="/events/"+cs.Tools.me.urlEncode($inParameters.eventId)
            
            $URLString+=This._getURLParamsFromObject($inParameters)
            
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
            
            var $result : Object:=Super._cleanGraphObject(Super._sendRequestAndWaitResponse("GET"; This._getURL()+$URLString; $headers))
            
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
            
            var $result : cs.GraphEventList:=cs.GraphEventList.new(This; This._getURL()+$URLString; $headers)
            
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
    Super._clearErrorStack()
    Super._throwErrors(False)
    
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
        $URLString+="/calendars/"+cs.Tools.me.urlEncode($calendarId)
    Else 
        $URLString+="/calendar"
    End if 
    $URLString+="/events"
    
    var $event : Object:=This._conformEvent(Super._cleanGraphObject($inEvent))
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
                $response.attachments.push(This._cleanGraphObject($result))
            Else 
                Super._throwErrors(True)
                return This._returnStatus($result)
            End if 
        End for each 
    End if 
    
    Super._throwErrors(True)
    
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
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $headers : Object:={Accept: "application/json"}
    var $URLString : Text:=This._getURL()
    
    If (Length(String(This.userId))>0)
        $URLString+="users/"+This.userId
    Else 
        $URLString+="me"
    End if 
    If (Length(String($inParameters.calendarId))>0)
        $URLString+="/calendars/"+cs.Tools.me.urlEncode($inParameters.calendarId)
    Else 
        $URLString+="/calendar"
    End if 
    $URLString+="/events"
    If (Length(String($inParameters.eventId))>0)
        $URLString+="/"+cs.Tools.me.urlEncode($inParameters.eventId)
    End if 
    
    Super._sendRequestAndWaitResponse("DELETE"; $URLString; $headers)
    
    Super._throwErrors(True)
    
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
    Super._clearErrorStack()
    Super._throwErrors(False)
    
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
        $URLString+="/calendars/"+cs.Tools.me.urlEncode($calendarId)
    Else 
        $URLString+="/calendar"
    End if 
    $URLString+="/events/"+cs.Tools.me.urlEncode($eventId)
    
    var $event : Object:=This._conformEvent(Super._cleanGraphObject($inEvent))
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
                $response.attachments.push(This._cleanGraphObject($result))
            Else 
                Super._throwErrors(True)
                return This._returnStatus($result)
            End if 
        End for each 
    End if 
    
    Super._throwErrors(True)
    
    return This._returnStatus({event: This._cleanGraphObject($response)})
