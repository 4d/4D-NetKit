Class extends _GraphAPI

property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider)
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
    // Mark: - [Public]
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
        $urlParams+="?$select="+$inSelect
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL)
    
    If (Value type($response)=Is object)
        return Super._cleanGraphObject($response)
    End if 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getCalendarList($inParameters : Object) : Object
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $headers : Object
    var $urlParams : Text:=""
    var $delimiter : Text:="?"
    
    If (Length(String(This.userId))>0)
        $urlParams:="users/"+This.userId
    Else 
        $urlParams:="me"
    End if 
    $urlParams+="/calendars"
    
    If (Length(String($inParameters.search))>0)
        $urlParams+=($delimiter+"$search="+$inParameters.search)
        $delimiter:="&"
        $headers:={ConsistencyLevel: "eventual"}
    End if 
    If (Length(String($inParameters.filter))>0)
        $urlParams+=($delimiter+"$filter="+$inParameters.filter)
        $delimiter:="&"
    End if 
    If (Length(String($inParameters.select))>0)
        $urlParams+=($delimiter+"$select="+$inParameters.select)
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.top)=Is undefined))
        $urlParams+=($delimiter+"$top="+Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
        $delimiter:="&"
    End if 
    If (Length(String($inParameters.orderBy))>0)
        $urlParams+=($delimiter+"$orderBy="+$inParameters.orderBy)
        $delimiter:="&"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $result : cs.GraphCalendarList:=cs.GraphCalendarList.new(This._getOAuth2Provider(); $URL; $headers)
    
    Super._throwErrors(True)
    
    return $result
