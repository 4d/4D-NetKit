Class extends _GoogleAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "GMail"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	
	
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
	
	var $headers; $response : Object
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
			
		: ((This:C1470.mailType="Google") && (Value type:C1509($inMail)=Is object:K8:27))
			$status:=This:C1470._postJSONMessage($inURL; $inMail; $inHeader)
			
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
	
	If (This:C1470.mailType="Google")
		$URL:=Replace string:C233($URL; "/gmail/v1/"; "/upload/gmail/v1/")
	End if 
	
	return This:C1470._postMessage("send"; $URL; $inMail)
	