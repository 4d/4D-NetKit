Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider)
	
	Super:C1705($inProvider)
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getUserInfo($inURL : Text)->$userInfo : Object
	
	$userInfo:=Super:C1706._sendRequestAndWaitResponse("GET"; $inURL)
	$userInfo:=Super:C1706._cleanResponseObject($userInfo)
	
	
	// ----------------------------------------------------
	
	
Function getCurrent($inSelect : Text)->$userInfo : Object
	
	var $urlParams; $URL : Text
	
	If (Length:C16(String:C10($inSelect))>0)
		$urlParams:="?$select="+$inSelect
	End if 
	
	$URL:=This:C1470._getURL()+"me"+$urlParams
	
	$userInfo:=This:C1470._getUserInfo($URL)
	
	
	// ----------------------------------------------------
	
	
Function get($inID : Text; $inSelect : Text) : Object
	
	If (Length:C16($inID)>0)
		var $urlParams; $URL : Text
		
		$urlParams:=String:C10($inID)
		If (Length:C16(String:C10($inSelect))>0)
			$urlParams:=$urlParams+"?$select="+$inSelect
		End if 
		
		$URL:=This:C1470._getURL()+"users/"+$urlParams
		
		return This:C1470._getUserInfo($URL)
	Else 
		This:C1470._try()
		This:C1470._throwError(9; New object:C1471("which"; 1; "function"; "get"))
		This:C1470._finally()
		return Null:C1517
	End if 
	
	
	// ----------------------------------------------------
	
	
Function list($inParameters : Object) : Object
	
	var $urlParams; $URL; $delimiter : Text
	var $headers : Object
	
	$urlParams:="users"
	$delimiter:="?"
	
	If (Length:C16(String:C10($inParameters.search))>0)
		$urlParams:=$urlParams+$delimiter+"$search="+$inParameters.search
		$delimiter:="&"
/*
see: https://devblogs.microsoft.com/microsoft365dev/microsoft-graph-advanced-queries-for-directory-objects-are-now-generally-available/
*/
		$headers:=New object:C1471("ConsistencyLevel"; "eventual")
	End if 
	If (Length:C16(String:C10($inParameters.filter))>0)
		$urlParams:=$urlParams+$delimiter+"$filter="+$inParameters.filter
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.select))>0)
		$urlParams:=$urlParams+$delimiter+"$select="+$inParameters.select
		$delimiter:="&"
	End if 
	If (Not:C34(Value type:C1509($inParameters.top)=Is undefined:K8:13))
		$urlParams:=$urlParams+$delimiter+"$top="+Choose:C955(Value type:C1509($inParameters.top)=Is text:K8:3; \
			$inParameters.top; String:C10($inParameters.top))
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.orderBy))>0)
		$urlParams:=$urlParams+$delimiter+"$orderBy="+$inParameters.orderBy
		$delimiter:="&"
	End if 
	
	$URL:=This:C1470._getURL()+$urlParams
	
	return cs:C1710._GraphUserList.new(This:C1470._getOAuth2Provider(); $URL; $headers)
	
	