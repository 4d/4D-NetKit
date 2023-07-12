Class extends _GoogleAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "JMAP"
	This:C1470.userId:=String:C10($inParameters.userId)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _postJSONMessage($inURL : Text; \
$inMail : Object; \
$inHeader : Object) : Object
	
	If ($inMail#Null:C1517)
		var $headers; $message; $messageCopy; $response : Object
		
		$headers:=New object:C1471
		$headers["Content-Type"]:="message/rfc822"
		If (($inHeader#Null:C1517) && (Value type:C1509($inHeader)=Is object:K8:27))
			var $keys : Collection
			var $key : Text
			$keys:=OB Keys:C1719($inHeader)
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		$response:=Super:C1706._sendRequestAndWaitResponse("POST"; $inURL; $headers; $inMail)
	Else 
		Super:C1706._pushError(1)
	End if 
	
	return This:C1470._returnStatus((Length:C16(String:C10($response.id))>0) ? New object:C1471("id"; $response.id) : Null:C1517)
	
	
	// ----------------------------------------------------
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
	var $headers : Object
	var $requestBody : Text
	
	$headers:=New object:C1471
	$headers["Content-Type"]:="application/json"
	
	Case of 
		: (Value type:C1509($inMail)=Is BLOB:K8:12)
			$requestBody:=Convert to text:C1012($inMail; "UTF-8")
			
		: (Value type:C1509($inMail)=Is object:K8:27)
			$requestBody:=MAIL Convert to MIME:C1604($inMail)
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE:C895($requestBody)
	
	This:C1470._internals._response:=Super:C1706._sendRequestAndWaitResponse("POST"; $inURL; $headers; New object:C1471("raw"; $requestBody))
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; \
$inURL : Text; \
$inMail : Variant; \
$inHeader : Object) : Object
	
	var $status : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: ((This:C1470.mailType="MIME") && (\
			(Value type:C1509($inMail)=Is text:K8:3) || \
			(Value type:C1509($inMail)=Is BLOB:K8:12)))
			$status:=This:C1470._postMailMIMEMessage($inURL; $inMail)
			
		: ((This:C1470.mailType="JMAP") && (Value type:C1509($inMail)=Is object:K8:27))
			$status:=This:C1470._postMailMIMEMessage($inURL; $inMail)
			
		Else 
			Super:C1706._pushError(10; New object:C1471("which"; 1; "function"; $inFunction))
			$status:=This:C1470._returnStatus()
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return $status
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $URL; $userId : Text
	
	$URL:=Super:C1706._getURL()
	$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
	$URL+="users/"+$userId+"/messages/send"
	
	return This:C1470._postMessage("send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function getLabelList() : Object
	
	var $URL; $userId : Text
	var $response : Object
	
	$URL:=Super:C1706._getURL()
	$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
	$URL+="users/"+$userId+"/labels"
	
	$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
	return This:C1470._returnStatus($response)
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text; $permanently : Boolean) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._pushError(10; New object:C1471("which"; "\"mailId\""; "function"; "delete"))
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._pushError(9; New object:C1471("which"; "\"mailId\""; "function"; "delete"))
			
		Else 
			
			var $URL; $verb; $userId : Text
			
			$URL:=Super:C1706._getURL()
			$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId
			If (Not:C34(Bool:C1537($permanently)))
				$URL+="/trash"
			End if 
			$verb:=Bool:C1537($permanently) ? "DELETE" : "POST"
			
			This:C1470._internals._response:=Super:C1706._sendRequestAndWaitResponse($verb; $URL)
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function untrash($inMailId : Text) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._pushError(10; New object:C1471("which"; "\"mailId\""; "function"; "untrash"))
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._pushError(9; New object:C1471("which"; "\"mailId\""; "function"; "untrash"))
			
		Else 
			
			var $URL; $userId : Text
			
			$URL:=Super:C1706._getURL()
			$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId+"/untrash"
			
			This:C1470._internals._response:=Super:C1706._sendRequestAndWaitResponse("POST"; $URL)
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMailIds($inOptions : Object) : Object
	
	var $URL; $userId : Text
	
	$URL:=Super:C1706._getURL()
	$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
	$URL+="users/"+$userId+"/messages"
	
	return cs:C1710.GoogleMailIdList.new(This:C1470._getOAuth2Provider(); $URL)
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text)->$response : Variant
	
	var $result : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._pushError(10; New object:C1471("which"; "\"mailId\""; "function"; "getMail"))
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._pushError(9; New object:C1471("which"; "\"mailId\""; "function"; "getMail"))
			
		Else 
			
			var $URL; $userId : Text
			
			$URL:=Super:C1706._getURL()
			$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
			$URL+="users/"+$userId+"/messages/"+String:C10($inMailId)+"?format=raw"
			
			$result:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
			
			If ($result#Null:C1517)
				var $mailType; $rawMessage : Text
				$mailType:=This:C1470.mailType
				
				If (($mailType="MIME") || ($mailType="JMAP"))
					If (Value type:C1509($result.raw)=Is text:K8:3)
						
						BASE64 DECODE:C896($result.raw; $rawMessage; *)
						If ($mailType="JMAP")
							$response:=MAIL Convert from MIME:C1681($rawMessage)
							
						Else 
							$response:=$rawMessage
							
						End if 
					End if 
				Else 
					Super:C1706._pushError(10; New object:C1471("which"; 1; "function"; "getMail"))
					
				End if 
			End if 
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return $response
	