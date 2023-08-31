Class extends _BaseClass

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super()
	
	This._internals._URL:=""
	This._internals._oAuth2Provider:=$inProvider
	This._internals._statusLine:=""
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getToken() : Object
	
	If (This._internals._oAuth2Provider.token=Null)
		This._internals._oAuth2Provider.getToken()
	End if 
	
	return This._internals._oAuth2Provider.token
	
	
	// ----------------------------------------------------
	
	
Function _getAcessToken() : Text
	
	return String(This._getToken().access_token)
	
	
	// ----------------------------------------------------
	
	
Function _getAcessTokenType() : Text
	
	var $tokenType : Text
	var $token : Object
	
	$token:=This._getToken()
	
	Case of 
		: (Value type($token.token_type)=Is text)
			$tokenType:=String($token.token_type)
			
		: (Value type($token.type)=Is text)
			$tokenType:=String($token.type)
			
		Else 
			$tokenType:="Bearer"
			
	End case 
	
	return $tokenType
	
	
	// ----------------------------------------------------
	
	
Function _sendRequestAndWaitResponse($inMethod : Text; $inURL : Text; $inHeaders : Object; $inBody : Variant)->$response : Variant
	
	This._try()
	
	var $options : Object
	var $token : Text
	
	$token:=This._getAcessToken()
	$options:=New object()
	$options.headers:=New object()
	If (Length(String($token))>0)
		$options.headers["Authorization"]:=This._getAcessTokenType()+" "+$token
	End if 
	If (($inHeaders#Null) && (Value type($inHeaders)=Is object))
		var $keys : Collection
		var $key : Text
		$keys:=OB Keys($inHeaders)
		For each ($key; $keys)
			$options.headers[$key]:=$inHeaders[$key]
		End for each 
	End if 
	If (Length(String($inMethod))>0)
		$options.method:=Uppercase($inMethod)
	End if 
	Case of 
		: ((Value type($inBody)=Is text) || (Value type($inBody)=Is object))
			$options.body:=$inBody
			$options.dataType:=(Value type($inBody)=Is text) ? "text" : "object"
		Else 
			$options.body:=$inBody
			$options.dataType:="auto"
	End case 
	
	var $request : 4D.HTTPRequest
	
	This._installErrorHandler()
	$request:=4D.HTTPRequest.new($inURL; $options).wait()
	This._resetErrorHandler()
	
	var $status : Integer
	var $statusText : Text
	$status:=$request["response"]["status"]
	$statusText:=$request["response"]["statusText"]
	This._internals._statusLine:=String($status)+" "+$statusText
	
	If (Int($status/100)=2)  // 200 OK, 201 Created, 202 Accepted... are valid status codes
		
		var $contentType; $charset : Text
		var $blob : Blob
		
		$contentType:=String($request["response"]["headers"]["content-type"])
		$charset:=_getHeaderValueParameter($contentType; "charset"; "UTF-8")
		
		If (OB Is defined($request.response; "body"))
			Case of 
				: (Value type($request["response"]["body"])=Is object)
					$response:=$request["response"]["body"]
					
				: (($contentType="application/json@") || ($contentType="text/plain@"))
					var $text : Text
					If (Value type($request["response"]["body"])=Is text)
						$text:=$request["response"]["body"]
					Else 
						$text:=Convert to text($request["response"]["body"]; $charset)
					End if 
					If ($contentType="application/json@")
						$response:=JSON Parse($text)
					Else 
						$response:=$text
					End if 
					
				: ((OB Is defined($request.response; "body") && (Value type($request["response"]["body"])=Is BLOB)))
					$response:=4D.Blob.new($request["response"]["body"])
					
			End case 
			
		Else 
			
			$response:=Null
		End if 
		
	Else 
		
		var $explanation; $message : Text
		$explanation:=$request["response"]["statusText"]
		
		Case of 
			: (Value type($request["response"]["body"])=Is text)
				$message:=$request["response"]["body"]
				
			: (Value type($request["response"]["body"])=Is object)
				$message:=JSON Stringify($request["response"]["body"])
				
			Else 
				$message:=Convert to text($request["response"]["body"]; "UTF-8")
				
		End case 
		
		This._throwError(8; New object("status"; $status; "explanation"; $explanation; "message"; $message))
		$response:=Null
		
	End if 
	
	This._finally()
	
	
	// ----------------------------------------------------
	
	
Function _getStatusLine() : Text
	
	return This._internals._statusLine
	
	
	// ----------------------------------------------------
	
	
Function _getURL() : Text
	
	return This._internals._URL
	
	
	// ----------------------------------------------------
	
	
Function _getOAuth2Provider() : cs.OAuth2Provider
	
	return This._internals._oAuth2Provider
	
	
	// ----------------------------------------------------
	
	
Function _returnStatus($inAdditionalInfo : Object)->$status : Object
	
	var $errorStack : Collection
	$errorStack:=Super._getErrorStack()
	$status:=New object
	
	If (Not(OB Is empty($inAdditionalInfo)))
		var $keys : Collection
		var $key : Text
		
		$keys:=OB Keys($inAdditionalInfo)
		For each ($key; $keys)
			$status[$key]:=$inAdditionalInfo[$key]
		End for each 
	End if 
	
	If ($errorStack.length>0)
		$status.success:=False
		$status.errors:=$errorStack
		$status.statusText:=$errorStack[0].message
	Else 
		$status.success:=True
		$status.statusText:=This._getStatusLine()
	End if 
