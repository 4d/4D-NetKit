Class extends _BaseClass

Class constructor($inProvider : cs:C1710.OAuth2Provider)
	
	Super:C1705()
	
	This:C1470._internals._URL:="https://graph.microsoft.com/v1.0/"
	This:C1470._internals._oAuth2Provider:=$inProvider
	This:C1470._internals._statusLine:=""
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getAcessToken() : Text
	
	If (This:C1470._internals._oAuth2Provider.token=Null:C1517)
		This:C1470._internals._oAuth2Provider.getToken()
	End if 
	
	return String:C10(This:C1470._internals._oAuth2Provider.token.access_token)
	
	
	// ----------------------------------------------------
	
	
Function _sendRequestAndWaitResponse($inMethod : Text; $inURL : Text; $inHeaders : Object; $inBody : Text)->$response : Variant
	
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
		If (($contentType="application/json@") || ($contentType="text/plain@"))
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
		Else 
			If (Value type:C1509($request["response"]["body"])=Is text:K8:3)
				$response:=$request["response"]["body"]
			Else 
				If (OB Is defined:C1231($request.response; "body") && (Value type:C1509($request["response"]["body"])=Is BLOB:K8:12))
					$response:=4D:C1709.Blob.new($request["response"]["body"])
				End if 
			End if 
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
	
	
Function _getStatusLine() : Text
	
	return This:C1470._internals._statusLine
	
	
	// ----------------------------------------------------
	
	
Function _getURL() : Text
	
	return This:C1470._internals._URL
	
	
	// ----------------------------------------------------
	
	
Function _getOAuth2Provider() : cs:C1710.OAuth2Provider
	
	return This:C1470._internals._oAuth2Provider
	
	
	// ----------------------------------------------------
	
	
Function _cleanGraphObject($ioObject : Object) : Object
	
	var $keys : Collection
	var $key : Text
	
	$keys:=OB Keys:C1719($ioObject)
	For each ($key; $keys)
		If ((Position:C15("@"; $key)=1) || ($ioObject[$key]=Null:C1517))
			OB REMOVE:C1226($ioObject; $key)
		End if 
	End for each 
	
	return $ioObject
	
	
	// ----------------------------------------------------
	
	
Function _copyGraphMessage($inMessage : Object) : Object
	
	If (OB Instance of:C1731($inMessage; cs:C1710.GraphMessage))
		
		var $message : Object
		var $keys : Collection
		var $key : Text
		var $iter; $attachment : Object
		
		$message:=New object:C1471
		If (OB Is defined:C1231($inMessage; "attachments") && ($inMessage.attachments#Null:C1517))
			$message.attachments:=New collection:C1472
		End if 
		$keys:=OB Keys:C1719($inMessage)
		For each ($key; $keys)
			
			Case of 
				: (($key="_internals") || (Position:C15("@"; $key)=1) || ($key="webLink"))
					// do not copy
					
				: ($key="attachments")
					For each ($iter; $inMessage.attachments)
						$attachment:=_convertToGraphAttachment($iter)
						$message.attachments.push($attachment)
					End for each 
					
				Else 
					$message[$key]:=$inMessage[$key]
					
			End case 
			
		End for each 
		
		return $message
		
	Else 
		
		return $inMessage
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromObject($inObject : Object)
	
	If (($inObject#Null:C1517) & (Not:C34(OB Is empty:C1297($inObject))))
		
		var $key : Text
		var $keys : Collection
		
		$keys:=OB Keys:C1719($inObject)
		
		For each ($key; $keys)
			This:C1470[$key]:=$inObject[$key]
		End for each 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
	
	var $urlParams; $delimiter : Text
	
	$urlParams:=""
	$delimiter:="?"
	If (Bool:C1537($inParameters.includeHiddenFolders))
		$urlParams+="/"+$delimiter+"includeHiddenFolders=true"
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.search))>0)
		$urlParams+=$delimiter+"$search="+$inParameters.search
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.filter))>0)
		$urlParams+=$delimiter+"$filter="+$inParameters.filter
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.select))>0)
		$urlParams+=$delimiter+"$select="+$inParameters.select
		$delimiter:="&"
	End if 
	If (Not:C34(Value type:C1509($inParameters.top)=Is undefined:K8:13))
		$urlParams+=$delimiter+"$top="+Choose:C955(Value type:C1509($inParameters.top)=Is text:K8:3; \
			$inParameters.top; String:C10($inParameters.top))
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.orderBy))>0)
		$urlParams+=$delimiter+"$orderBy="+$inParameters.orderBy
		$delimiter:="&"
	End if 
	
	return $urlParams
	