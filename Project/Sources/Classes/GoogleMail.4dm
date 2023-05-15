Class extends _GoogleAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "GMail"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
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
$bSkipMessageEncapsulation : Boolean; \
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
			
			//: ((This.mailType="Google") && (Value type($inMail)=Is object))
			//$status:=This._postJSONMessage($inURL; $inMail; $bSkipMessageEncapsulation; $inHeader)
			
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
	