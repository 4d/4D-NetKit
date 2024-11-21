Class extends _GoogleAPI

property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
	Super($inProvider; "https://www.googleapis.com/calendar/v3/")

    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function getCalendar($inID : Text) : Object
    
    // GET https://www.googleapis.com/calendar/v3/users/me/calendars/calendarId
    Super._clearErrorStack()
    
    var $URL : Text:=Super._getURL()+"users/me/calendars/"+$inID
    var $headers : Object:={Accept: "application/json"}
    var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
    
    return $response
    
    
    // ----------------------------------------------------
    
    
Function getCalendarList($inParameters : Object) : Object
    
    // GET https://www.googleapis.com/calendar/v3/users/me/calendarList
    Super._clearErrorStack()
    Super._throwErrors(False)

    var $headers : Object:={Accept: "application/json"}
    var $urlParams : Text:=""
    var $delimiter : Text:="?"
    
    $urlParams:="calendar/me/calendarList"
    
    If (Not(Value type($inParameters.maxResults)=Is undefined))
        $urlParams+=($delimiter+"maxResults="+Choose(Value type($inParameters.maxResults)=Is text; $inParameters.maxResults; String($inParameters.maxResults)))
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
    
    return Null
