Class extends _BaseClass

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super()
	
	This._internals._URL:=""
	This._internals._statusLine:=""
	This._internals._oAuth2Provider:=Null
	If (OB Class($inProvider)=cs.OAuth2Provider)
		This._internals._oAuth2Provider:=$inProvider
	Else 
		This._throwError(14; {which: "\"$inProvider\""; function: "\"_BaseClass:constructor\""; type: "\"cs.OAuth2Provider\""})
	End if 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getToken() : Object
	
	If (OB Class(This._internals._oAuth2Provider)=cs.OAuth2Provider)
		This._internals._oAuth2Provider.getToken()
	End if 
	
	return This._internals._oAuth2Provider.token
	
	
	// ----------------------------------------------------
	
	
Function _getAccessToken() : Text
	
	return String(This._getToken().access_token)
	
	
	// ----------------------------------------------------
	
	
Function _getAccessTokenType() : Text
	
	var $tokenType : Text
	var $token : Object:=This._getToken()
	
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
	
	
Function _sendRequestAndWaitResponse($inMethod : Text; $inURL : Text; $inHeaders : Object; $inBody : Variant) : Variant
	
	This._try()
	
	var $response : Variant:=Null
	var $options : Object:={headers: {}}
	var $token : Text:=This._getAccessToken()
	
	If (($inHeaders#Null) && (Value type($inHeaders)=Is object))
		$options.headers:=OB Copy($inHeaders)
	End if 
	If (Length(String($token))>0)
		$options.headers["Authorization"]:=This._getAccessTokenType()+" "+$token
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
	
	var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new($inURL; $options).wait())
	var $status : Integer:=Num($request["response"]["status"])
	var $statusText : Text:=String($request["response"]["statusText"])
	This._internals._statusLine:=String($status)+" "+$statusText
	
	If (Int($status/100)=2)  // 200 OK, 201 Created, 202 Accepted... are valid status codes
		
		var $contentType : Text:=String($request["response"]["headers"]["content-type"])
		var $charset : Text:=cs.Tools.me.getHeaderValueParameter($contentType; "charset"; "UTF-8")
		
		If (OB Is defined($request.response; "body"))
			var $text : Text
			Case of 
				: (Value type($request["response"]["body"])=Is object)
					$response:=$request["response"]["body"]
					
				: (($contentType="application/json@") || ($contentType="text/plain@"))
					If (Value type($request["response"]["body"])=Is text)
						$text:=$request["response"]["body"]
					Else 
						$text:=Try(Convert to text($request["response"]["body"]; $charset))
					End if 
					If ($contentType="application/json@")
						$response:=Try(JSON Parse($text))
					Else 
						$response:=$text
					End if 
					
				: ((OB Is defined($request.response; "body") && (Value type($request["response"]["body"])=Is BLOB)))
					$response:=4D.Blob.new($request["response"]["body"])
					
				: ($contentType="multipart/@")
					var $headers : Text:="HTTP/1.1 "+This._internals._statusLine+"\r\n"
					$keys:=OB Keys($request.response.headers)
					For each ($key; $keys)
						$headers+=$key+": "+$request.response.headers[$key]+"\r\n"
					End for each 
					$headers+="\r\n"
					If (Value type($request["response"]["body"])=Is text)
						$text:=$request["response"]["body"]
					Else 
						$text:=Try(Convert to text($request["response"]["body"]; $charset))
					End if 
					$response:=$headers+$text
					
			End case 
			
		Else 
			
			$response:=Null
		End if 
		
	Else 
		
		var $message : Text
		
		Case of 
			: (Value type($request["response"]["body"])=Is text)
				$message:=$request["response"]["body"]
				
			: (Value type($request["response"]["body"])=Is object)
				$message:=Try(JSON Stringify($request["response"]["body"]))
				
			Else 
				$message:=Try(Convert to text($request["response"]["body"]; "UTF-8"))
				
		End case 
		
		This._throwError(8; {status: $status; explanation: $statusText; message: $message})
		$response:=Null
		
	End if 
	
	This._finally()
	
	return $response
	
	
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
	
	
Function _returnStatus($inAdditionalInfo : Object) : Object
	
	var $status : Object:={}
	var $errorStack : Collection:=Super._getErrorStack()
	
	If (Not(OB Is empty($inAdditionalInfo)))
		$status:=OB Copy($inAdditionalInfo)
	End if 
	
	If ($errorStack.length>0)
		$status.success:=False
		$status.errors:=$errorStack
		$status.statusText:=$errorStack.first().message
	Else 
		$status.success:=True
		$status.statusText:=This._getStatusLine()
	End if 
	
	return $status
