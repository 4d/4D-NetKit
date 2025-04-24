Class extends _GraphAPI

property userId : Text:=""
property id : Text:=""

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
    
    Super($inProvider)
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""


	// Mark: - [Public]
    // ----------------------------------------------------
    
    
Function list : cs.GraphCategoryList
    
/*
        GET /me/outlook/masterCategories
        GET /users/{id|userPrincipalName}/outlook/masterCategories
*/
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    var $headers : Object:={}
    var $urlParams : Text:=""
    
    If (Length(String(This.userId))>0)
        $urlParams:="users/"+This.userId
    Else 
        $urlParams:="me"
    End if 
    $urlParams+="/outlook/masterCategories"+Super._getURLParamsFromObject($inParameters)
    
    If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
        $headers.ConsistencyLevel:="eventual"
    End if 
    
    var $URL : Text:=This._getURL()+$urlParams
    var $result : cs.GraphCategoryList:=cs.GraphCategoryList.new(This._getOAuth2Provider(); $URL; $headers)
    
    Super._throwErrors(True)
    
    return $result
