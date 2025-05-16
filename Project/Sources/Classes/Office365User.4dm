Class extends _GraphAPI

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getUserInfo($inURL : Text) : Object
	
	var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $inURL)
	If (Value type($response)=Is object)
		return Super._cleanGraphObject($response)
	End if 
	
	return Null
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getCurrent($inSelect : Text) : Object
	
	var $urlParams : Text
	
	If (Length(String($inSelect))>0)
		$urlParams:="?$select="+$inSelect
	End if 
	
	var $URL : Text:=This._getURL()+"me"+$urlParams
	
	return This._getUserInfo($URL)
	
	
	// ----------------------------------------------------
	
	
Function get($inID : Text; $inSelect : Text) : Object
	
	If (Length($inID)>0)
		
		var $urlParams : Text:=String($inID)
		
		If (Length(String($inSelect))>0)
			$urlParams:=$urlParams+"?$select="+$inSelect
		End if 
		
		var $URL : Text:=This._getURL()+"users/"+$urlParams
		
		return This._getUserInfo($URL)
	Else 
		This._try()
		This._throwError(9; {which: 1; function: "office365.user.get"})
		This._finally()
		return Null
	End if 
	
	
	// ----------------------------------------------------
	
	
Function list($inParameters : Object) : Object
	
	var $headers : Object
	var $URL : cs.URL:=cs.URL.new(This._getURL()+"users")
	var $URLString : Text
	
	If (Length(String($inParameters.search))>0)
		$URL.addQueryParameter("$search"; $inParameters.search)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	If (Length(String($inParameters.filter))>0)
		$URL.addQueryParameter("$filter"; $inParameters.filter)
	End if 
	If (Length(String($inParameters.select))>0)
		$URL.addQueryParameter("$select"; $inParameters.select)
	End if 
	If (Not(Value type($inParameters.top)=Is undefined))
		$URL.addQueryParameter("$top"; Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
	End if 
	If (Length(String($inParameters.orderBy))>0)
		$URL.addQueryParameter("$orderBy"; $inParameters.orderBy)
	End if 
	$URLString:=$URL.toString()
	
	return cs.GraphUserList.new(This._getOAuth2Provider(); $URLString; $headers)
	
	
	// ----------------------------------------------------
	
	
Function count($inParameters : Object) : Object
	
	var $headers : Object
	var $URL : cs.URL:=cs.URL.new(This._getURL()+"users")
	var $URLString : Text
	
	If (Length(String($inParameters.search))>0)
		$URL.addQueryParameter("$search"; $inParameters.search)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	If (Length(String($inParameters.filter))>0)
		$URL.addQueryParameter("$filter"; $inParameters.filter)
	End if 
	If (Length(String($inParameters.select))>0)
		$URL.addQueryParameter("$select"; $inParameters.select)
	End if 
	If (Not(Value type($inParameters.top)=Is undefined))
		$URL.addQueryParameter("$top"; Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
	End if 
	If (Length(String($inParameters.orderBy))>0)
		$URL.addQueryParameter("$orderBy"; $inParameters.orderBy)
	End if 
	$URL.addQueryParameter("$count"; "true")
	$headers:={ConsistencyLevel: "eventual"}
	$URLString:=$URL.toString()

	return cs.GraphUserList.new(This._getOAuth2Provider(); $URLString; $headers)
	
