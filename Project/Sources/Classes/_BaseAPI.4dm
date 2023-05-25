Class extends _BaseClass

Class constructor($inProvider : cs:C1710.OAuth2Provider)
	
	Super:C1705()
	
	This:C1470._internals._URL:=""
	This:C1470._internals._oAuth2Provider:=$inProvider
	This:C1470._internals._statusLine:=""
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getToken() : Object
	
	If (This:C1470._internals._oAuth2Provider.token=Null:C1517)
		This:C1470._internals._oAuth2Provider.getToken()
	End if 
	
	return This:C1470._internals._oAuth2Provider.token
	
	
	// ----------------------------------------------------
	
	
Function _getAcessToken() : Text
	
	return String:C10(This:C1470._getToken().access_token)
	
	
	// ----------------------------------------------------
	
	
Function _getAcessTokenType() : Text
	
	var $tokenType : Text
	var $token : Object
	
	$token:=This:C1470._getToken()
	
	Case of 
		: (Value type:C1509($token.token_type)=Is text:K8:3)
			$tokenType:=String:C10($token.token_type)
			
		: (Value type:C1509($token.type)=Is text:K8:3)
			$tokenType:=String:C10($token.type)
			
		Else 
			$tokenType:="Bearer"
			
	End case 
	
	return $tokenType
	
	
	// ----------------------------------------------------
	
	
Function _sendRequestAndWaitResponse($inMethod : Text; $inURL : Text; $inHeaders : Object; $inBody : Variant)->$response : Variant
	
	This:C1470._try()
	
	var $options : Object
	var $token; $savedMethod : Text
	
	$token:=This:C1470._getAcessToken()
	$options:=New object:C1471()
	$options.headers:=New object:C1471()
	If (Length:C16(String:C10($token))>0)
		$options.headers["Authorization"]:=This:C1470._getAcessTokenType()+" "+$token
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
	Case of 
		: ((Value type:C1509($inBody)=Is text:K8:3) || (Value type:C1509($inBody)=Is object:K8:27))
			$options.body:=$inBody
			$options.dataType:=(Value type:C1509($inBody)=Is text:K8:3) ? "text" : "object"
		Else 
			$options.body:=$inBody
			$options.dataType:="auto"
	End case 
	
	var $request : 4D:C1709.HTTPRequest
	
	$savedMethod:=Method called on error:C704
	ON ERR CALL:C155("_ErrorHandler")
	$request:=4D:C1709.HTTPRequest.new($inURL; $options)
	$request.wait()
	ON ERR CALL:C155($savedMethod)
	
	var $status : Integer
	var $statusText : Text
	$status:=$request["response"]["status"]
	$statusText:=$request["response"]["statusText"]
	This:C1470._internals._statusLine:=String:C10($status)+" "+$statusText
	
	If (Int:C8($status/100)=2)  // 200 OK, 201 Created, 202 Accepted... are valid status codes
		
		var $contentType; $charset : Text
		var $blob : Blob
		
		$contentType:=String:C10($request["response"]["headers"]["content-type"])
		$charset:=_getHeaderValueParameter($contentType; "charset"; "UTF-8")
		
		Case of 
			: (Value type:C1509($request["response"]["body"])=Is object:K8:27)
				$response:=$request["response"]["body"]
				
			: (($contentType="application/json@") || ($contentType="text/plain@"))
				var $text : Text
				If (Value type:C1509($request["response"]["body"])=Is text:K8:3)
					$text:=$request["response"]["body"]
				Else 
					$text:=Convert to text:C1012($request["response"]["body"]; $charset)
				End if 
				If ($contentType="application/json@")
					$response:=JSON Parse:C1218($text)
				Else 
					$response:=$text
				End if 
				
			: ((OB Is defined:C1231($request.response; "body") && (Value type:C1509($request["response"]["body"])=Is BLOB:K8:12)))
				$response:=4D:C1709.Blob.new($request["response"]["body"])
				
		End case 
		
	Else 
		
		var $explanation; $message : Text
		$explanation:=$request["response"]["statusText"]
		
		Case of 
			: (Value type:C1509($request["response"]["body"])=Is text:K8:3)
				$message:=$request["response"]["body"]
				
			: (Value type:C1509($request["response"]["body"])=Is object:K8:27)
				$message:=JSON Stringify:C1217($request["response"]["body"])
				
			Else 
				$message:=Convert to text:C1012($request["response"]["body"]; "UTF-8")
				
		End case 
		
		This:C1470._throwError(8; New object:C1471("status"; $status; "explanation"; $explanation; "message"; $message))
		$response:=Null:C1517
		
	End if 
	
	This:C1470._finally()
	
	
	// ----------------------------------------------------
	
	
Function _getStatusLine() : Text
	
	return This:C1470._internals._statusLine
	
	
	// ----------------------------------------------------
	
	
Function _getURL() : Text
	
	return This:C1470._internals._URL
	
	
	// ----------------------------------------------------
	
	
Function _getOAuth2Provider() : cs:C1710.OAuth2Provider
	
	return This:C1470._internals._oAuth2Provider
	
	
	// ----------------------------------------------------
	
	
Function _returnStatus($inAdditionalInfo : Object)->$status : Object
	
	var $errorStack : Collection
	$errorStack:=Super:C1706._getErrorStack()
	$status:=New object:C1471
	
	If (Not:C34(OB Is empty:C1297($inAdditionalInfo)))
		var $keys : Collection
		var $key : Text
		
		$keys:=OB Keys:C1719($inAdditionalInfo)
		For each ($key; $keys)
			$status[$key]:=$inAdditionalInfo[$key]
		End for each 
	End if 
	
	If ($errorStack.length>0)
		$status.success:=False:C215
		$status.errors:=$errorStack
		$status.statusText:=$errorStack[0].message
	Else 
		$status.success:=True:C214
		$status.statusText:=This:C1470._getStatusLine()
	End if 
	