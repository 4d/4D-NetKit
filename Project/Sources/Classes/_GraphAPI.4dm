Class extends _BaseClass

Class constructor($inOAuth2Provider : cs:C1710.OAuth2Provider; $inURL : Text)
	
	Super:C1705()
	
	// [Private]
	This:C1470._internals._URL:=$inURL
	This:C1470._internals._OAuth2Provider:=$inOAuth2Provider
	This:C1470._internals._statusLine:=""
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getAcessToken() : Text
	
	If (This:C1470._internals._OAuth2Provider.token=Null:C1517)
		This:C1470._internals._OAuth2Provider.getToken()
	End if 
	
	return String:C10(This:C1470._internals._OAuth2Provider.token.access_token)
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _sendRequestAndWaitResponse($inMethod : Text; $inURL : Text; $inHeaders : Object; $inBody : Text)->$response : Object
	
	This:C1470._try()
	
	var $options : Object
	var $bearer; $savedMethod : Text
	
	$bearer:=This:C1470._getAcessToken()
	$options:=New object:C1471()
	If (Length:C16(String:C10($bearer))>0)
		$options.headers:=New object:C1471()
		$options.headers["Authorization"]:="Bearer "+$bearer
	End if 
	If (($inHeaders#Null:C1517) && (Value type:C1509($inHeaders)=Is object:K8:27))
		var $keys : Collection
		var $key : Text
		$keys:=OB Keys:C1719($inHeaders)
		For each ($key; $keys)
			$options.headers[$key]:=$inHeaders[$key]
		End for each 
	End if 
	If (Length:C16(String:C10($inMethod))>0)
		$options.method:=Uppercase:C13($inMethod)
	End if 
	If (Length:C16(String:C10($inBody))>0)
		$options.body:=$inBody
	End if 
	$options.dataType:="text"
	
	var $request : 4D:C1709.HTTPRequest
	
	$savedMethod:=Method called on error:C704
	ON ERR CALL:C155("_ErrorHandler")
	$request:=4D:C1709.HTTPRequest.new($inURL; $options)
	$request.wait(30)
	ON ERR CALL:C155($savedMethod)
	
	var $status : Integer
	var $statusText : Text
	$status:=$request["response"]["status"]
	$statusText:=$request["response"]["statusText"]
	This:C1470._internals._statusLine:=String:C10($status)+" "+$statusText
	
	If (Int:C8($status/100)=2)  // 200 OK, 201 Created, 202 Accepted... are valid status codes
		
		If (String:C10($request["response"]["headers"]["Content-Type"])="application/json@")
			var $text; $charset : Text
			If (Value type:C1509($request["response"]["body"])=Is text:K8:3)
				$text:=$request["response"]["body"]
			Else 
				$charset:=_getHeaderValueParameter($request["response"]["headers"]["Content-Type"]; "charset"; "UTF-8")
				$text:=Convert to text:C1012($request["response"]["body"]; $charset)
			End if 
			$response:=JSON Parse:C1218($text)
		Else 
			$response:=Null:C1517
		End if 
		
	Else 
		
		var $explanation; $message : Text
		$explanation:=$request["response"]["statusText"]
		If (Value type:C1509($request["response"]["body"])=Is text:K8:3)
			$message:=$request["response"]["body"]
		Else 
			$message:=Convert to text:C1012($request["response"]["body"]; "UTF-8")
		End if 
		This:C1470._throwError(8; New object:C1471("status"; $status; "explanation"; $explanation; "message"; $message))
		$response:=Null:C1517
		
	End if 
	
	This:C1470._finally()
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getStatusLine() : Text
	
	return This:C1470._internals._statusLine
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getURL() : Text
	
	return This:C1470._internals._URL
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getOAuth2Provider() : cs:C1710.OAuth2Provider
	
	return This:C1470._internals._OAuth2Provider
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _cleanResponseObject($ioObject : Object) : Object
	
	var $keys : Collection
	var $key : Text
	
	$keys:=OB Keys:C1719($ioObject)
	For each ($key; $keys)
		If ((Position:C15("@"; $key)=1) || ($ioObject[$key]=Null:C1517))
			OB REMOVE:C1226($ioObject; $key)
		End if 
	End for each 
	
	return $ioObject
	