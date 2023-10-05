Class extends _GraphAPI

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getUserInfo($inURL : Text)->$userInfo : Object
	
	$userInfo:=Super._sendRequestAndWaitResponse("GET"; $inURL)
	$userInfo:=Super._cleanGraphObject($userInfo)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getCurrent($inSelect : Text)->$userInfo : Object
	
	var $urlParams; $URL : Text
	
	If (Length(String($inSelect))>0)
		$urlParams:="?$select="+$inSelect
	End if 
	
	$URL:=This._getURL()+"me"+$urlParams
	
	$userInfo:=This._getUserInfo($URL)
	
	
	// ----------------------------------------------------
	
	
Function get($inID : Text; $inSelect : Text) : Object
	
	If (Length($inID)>0)
		var $urlParams; $URL : Text
		
		$urlParams:=String($inID)
		If (Length(String($inSelect))>0)
			$urlParams:=$urlParams+"?$select="+$inSelect
		End if 
		
		$URL:=This._getURL()+"users/"+$urlParams
		
		return This._getUserInfo($URL)
	Else 
		This._try()
		This._throwError(9; {which: 1; function: "get"})
		This._finally()
		return Null
	End if 
	
	
	// ----------------------------------------------------
	
	
Function list($inParameters : Object) : Object
	
	var $urlParams; $URL; $delimiter : Text
	var $headers : Object
	
	$urlParams:="users"
	$delimiter:="?"
	
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
		$urlParams:=$urlParams+$delimiter+"$top="+Choose(Value type($inParameters.top)=Is text; \
			$inParameters.top; String($inParameters.top))
		$delimiter:="&"
	End if 
	If (Length(String($inParameters.orderBy))>0)
		$urlParams:=$urlParams+$delimiter+"$orderBy="+$inParameters.orderBy
		$delimiter:="&"
	End if 
	
	$URL:=This._getURL()+$urlParams
	
	return cs.GraphUserList.new(This._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function count($inParameters : Object) : Object
	
	var $urlParams; $URL; $delimiter : Text
	var $headers : Object
	
	$urlParams:="users"
	$delimiter:="?"
	
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
		$urlParams:=$urlParams+$delimiter+"$top="+Choose(Value type($inParameters.top)=Is text; \
			$inParameters.top; String($inParameters.top))
		$delimiter:="&"
	End if 
	If (Length(String($inParameters.orderBy))>0)
		$urlParams:=$urlParams+$delimiter+"$orderBy="+$inParameters.orderBy
		$delimiter:="&"
	End if 
	$urlParams:=$urlParams+$delimiter+"$count"
	$headers:={ConsistencyLevel: "eventual"}
	
	$URL:=This._getURL()+$urlParams
	
	return cs.GraphUserList.new(This._getOAuth2Provider(); $URL; $headers)
	
