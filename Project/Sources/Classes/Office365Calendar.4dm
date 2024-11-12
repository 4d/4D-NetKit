Class extends _GraphAPI

Class constructor($inProvider : cs.OAuth2Provider)
    
    Super($inProvider)
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function getCalendar($inID : Text; $inSelect : Text) : Object
    
    var $urlParams : Text:=""
    
    If (Length(String($inID))>0)
        $urlParams:="users/"+String($inID)+"/calendar"
    Else 
        $urlParams:="me/calendar"
    End if 
    
    If (Length(String($inSelect))>0)
        $urlParams:=$urlParams+"?$select="+$inSelect
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL)
    
    If (Value type($response)=Is object)
        return Super._cleanGraphObject($response)
    End if 
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getCalendarList($inParameters : Object) : Object
    
    var $headers : Object
    var $urlParams : Text:=""
    var $delimiter : Text:="?"
    
    If (Length(String($inID))>0)
        $urlParams:="users/"+String($inID)+"/calendar"
    Else 
        $urlParams:="me/calendar"
    End if 
    
    If (Length(String($inParameters.search))>0)
        $urlParams:=$urlParams+$delimiter+"$search="+$inParameters.search
        $delimiter:="&"
        $headers:={ConsistencyLevel: "eventual"}
    End if 
    If (Length(String($inParameters.filter))>0)
        $urlParams:=$urlParams+$delimiter+"$filter="+$inParameters.filter
        $delimiter:="&"
    End if 
    If (Length(String($inParameters.select))>0)
        $urlParams:=$urlParams+$delimiter+"$select="+$inParameters.select
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.top)=Is undefined))
        $urlParams:=$urlParams+$delimiter+"$top="+Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top))
        $delimiter:="&"
    End if 
    If (Length(String($inParameters.orderBy))>0)
        $urlParams:=$urlParams+$delimiter+"$orderBy="+$inParameters.orderBy
        $delimiter:="&"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    
    return cs.GraphCalendarList.new(This._getOAuth2Provider(); $URL; $headers)
