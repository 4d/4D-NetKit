Class extends _GoogleAPI

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "JMAP"
	This.userId:=String($inParameters.userId)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _postJSONMessage($inURL : Text; \
$inMail : Object; \
$inHeader : Object) : Object
	
	If ($inMail#Null)
		var $headers; $message; $messageCopy; $response : Object
		
		$headers:=New object
		$headers["Content-Type"]:="message/rfc822"
		If (($inHeader#Null) && (Value type($inHeader)=Is object))
			var $keys : Collection
			var $key : Text
			$keys:=OB Keys($inHeader)
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $inMail)
	Else 
		Super._pushError(1)
	End if 
	
	return This._returnStatus((Length(String($response.id))>0) ? New object("id"; $response.id) : Null)
	
	
	// ----------------------------------------------------
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
	var $headers : Object
	var $requestBody : Text
	
	$headers:=New object
	$headers["Content-Type"]:="application/json"
	
	Case of 
		: (Value type($inMail)=Is BLOB)
			$requestBody:=Convert to text($inMail; "UTF-8")
			
		: (Value type($inMail)=Is object)
			$requestBody:=MAIL Convert to MIME($inMail)
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE($requestBody)
	
	This._internals._response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; New object("raw"; $requestBody))
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; \
$inURL : Text; \
$inMail : Variant; \
$inHeader : Object) : Object
	
	var $status : Object
	
	Super._throwErrors(False)
	
	Case of 
		: ((This.mailType="MIME") && (\
			(Value type($inMail)=Is text) || \
			(Value type($inMail)=Is BLOB)))
			$status:=This._postMailMIMEMessage($inURL; $inMail)
			
		: ((This.mailType="JMAP") && (Value type($inMail)=Is object))
			$status:=This._postMailMIMEMessage($inURL; $inMail)
			
		Else 
			Super._pushError(10; New object("which"; 1; "function"; $inFunction))
			$status:=This._returnStatus()
			
	End case 
	
	Super._throwErrors(True)
	
	return $status
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $URL; $userId : Text
	
	$URL:=Super._getURL()
	$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/send"
	
	return This._postMessage("send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function getLabelList() : Object
	
	var $URL; $userId : Text
	var $response : Object
	
	$URL:=Super._getURL()
	$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/labels"
	
	$response:=Super._sendRequestAndWaitResponse("GET"; $URL)
	return This._returnStatus($response)
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text; $permanently : Boolean) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._pushError(10; New object("which"; "\"mailId\""; "function"; "delete"))
			
		: (Length(String($inMailId))=0)
			Super._pushError(9; New object("which"; "\"mailId\""; "function"; "delete"))
			
		Else 
			
			var $URL; $verb; $userId : Text
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId
			If (Not(Bool($permanently)))
				$URL+="/trash"
			End if 
			$verb:=Bool($permanently) ? "DELETE" : "POST"
			
			This._internals._response:=Super._sendRequestAndWaitResponse($verb; $URL)
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function untrash($inMailId : Text) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._pushError(10; New object("which"; "\"mailId\""; "function"; "untrash"))
			
		: (Length(String($inMailId))=0)
			Super._pushError(9; New object("which"; "\"mailId\""; "function"; "untrash"))
			
		Else 
			
			var $URL; $userId : Text
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId+"/untrash"
			
			This._internals._response:=Super._sendRequestAndWaitResponse("POST"; $URL)
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMailIds($inParameters : Object) : Object
	
	var $URL; $userId; $urlParams; $delimiter : Text
	
	$URL:=Super._getURL()
	$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
	$urlParams+="users/"+$userId+"/messages"
	$delimiter:="?"
	
	If (Length(String($inParameters.search))>0)
		$urlParams+=($delimiter+"q="+_urlEncode($inParameters.search))
		$delimiter:="&"
	End if 
	If (Value type($inParameters.top)#Is undefined)
		$urlParams+=($delimiter+"maxResults="+String($inParameters.top))
		$delimiter:="&"
	End if 
	If (Value type($inParameters.includeSpamTrash)=Is boolean)
		$urlParams+=($delimiter+"includeSpamTrash="+($inParameters.includeSpamTrash ? "true" : "false"))
		$delimiter:="&"
	End if 
	If (Value type($inParameters.labelIds)=Is collection)
		$urlParams+=($delimiter+"labelIds="+$inParameters.labelIds.join("&labelIds="; ck ignore null or empty))
		$delimiter:="&"
	End if 
	
	return cs.GoogleMailIdList.new(This._getOAuth2Provider(); $URL+$urlParams)
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text; $inParameters : Object)->$response : Variant
	
	var $result : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._pushError(10; New object("which"; "\"mailId\""; "function"; "getMail"))
			
		: (Length(String($inMailId))=0)
			Super._pushError(9; New object("which"; "\"mailId\""; "function"; "getMail"))
			
		Else 
			
			var $URL; $userId; $urlParams; $delimiter; $mailType; $format : Text
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$urlParams+="users/"+$userId+"/messages/"+String($inMailId)
			$delimiter:="?"
			
			$mailType:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
			$format:=String($inParameters.format)
			$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
			If (($format="metadata") && (Value type($inParameters.headers)=Is collection))
				$urlParams+=($delimiter+"metadataHeaders="+$inParameters.headers.join("&metadataHeaders="; ck ignore null or empty))
				$delimiter:="&"
			End if 
			$urlParams+=($delimiter+"format="+$format)
			
			$result:=Super._sendRequestAndWaitResponse("GET"; $URL+$urlParams)
			
			If ($result#Null)
				var $rawMessage : Text
				
				Case of 
					: (($format="raw") && (($mailType="MIME") || ($mailType="JMAP")))
						If (Value type($result.raw)=Is text)
							
							$rawMessage:=_base64UrlSafeDecode($result.raw)
							If ($mailType="JMAP")
								$response:=MAIL Convert from MIME($rawMessage)
								
							Else 
								$response:=(Length($rawMessage)>0) ? $rawMessage : $result.raw
								
							End if 
						End if 
						
					: (($format="minimal") || ($format="metadata"))
						$response:=$result
						
					Else 
						Super._pushError(10; New object("which"; 1; "function"; "getMail"))
						
				End case 
			End if 
			
	End case 
	
	Super._throwErrors(True)
	
	return $response
