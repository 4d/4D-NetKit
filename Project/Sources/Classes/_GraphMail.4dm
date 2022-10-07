Class extends _GraphAPI

Class constructor($inOAuth2Provider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inOAuth2Provider; "https://graph.microsoft.com/v1.0/")
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "Microsoft"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	
	
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $savedMethod : Text
	var $status : Object
	
	$savedMethod:=Method called on error:C704
	ON ERR CALL:C155("_ErrorHandler")
	
	Super:C1706._throwErrors(False:C215)
	Super:C1706._getErrorStack().clear()
	
	var $urlParams; $URL : Text
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId+"/sendMail"
	Else 
		$urlParams:="me/sendMail"
	End if 
	
	$URL:=Super:C1706._getURL()+$urlParams
	If (Length:C16(String:C10(This:C1470.mailType))=0)
		This:C1470.mailType:="Microsoft"
	End if 
	
	Case of 
		: ((This:C1470.mailType="MIME") && (\
			(Value type:C1509($inMail)=Is text:K8:3) || \
			(Value type:C1509($inMail)=Is BLOB:K8:12)))
			$status:=This:C1470._sendMailMIMEMessage($URL; $inMail)
			
		: ((This:C1470.mailType="JMAP") && (Value type:C1509($inMail)=Is object:K8:27))
			$status:=This:C1470._sendMailMIMEMessage($URL; $inMail)
			
		: ((This:C1470.mailType="Microsoft") && (Value type:C1509($inMail)=Is object:K8:27))
			$status:=This:C1470._sendJSONMessage($URL; $inMail)
			
		Else 
			Super:C1706._pushError(10; New object:C1471("which"; 1; "function"; "send"))
			$status:=This:C1470._returnStatus()
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	ON ERR CALL:C155($savedMethod)
	
	return $status
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _sendMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
	var $headers : Object
	var $requestBody : Text
	
	$headers:=New object:C1471
	$headers["Content-Type"]:="text/plain"
	
	Case of 
		: (Value type:C1509($inMail)=Is BLOB:K8:12)
			$requestBody:=Convert to text:C1012($inMail; "UTF-8")
			
		: (Value type:C1509($inMail)=Is object:K8:27)
			$requestBody:=MAIL Convert to MIME:C1604($inMail)
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE:C895($requestBody)
	
	Super:C1706._sendRequestAndWaitResponse("POST"; $inURL; $headers; $requestBody)
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _sendJSONMessage($inURL : Text; $inMail : Object) : Object
	
	If ($inMail#Null:C1517)
		var $headers : Object
		var $requestBody : Text
		var $message : Object
		
		$headers:=New object:C1471
		$headers["Content-Type"]:="application/json"
		
		If (Not:C34(OB Is defined:C1231($inMail; "message")))
			$message:=New object:C1471("message"; $inMail)
		Else 
			$message:=$inMail
		End if 
		$requestBody:=JSON Stringify:C1217($message)
		
		Super:C1706._sendRequestAndWaitResponse("POST"; $inURL; $headers; $requestBody)
	Else 
		Super:C1706._pushError(1)
	End if 
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _returnStatus()->$status : Object
	
	var $errorStack : Collection
	$errorStack:=Super:C1706._getErrorStack()
	$status:=New object:C1471
	
	If ($errorStack.length>0)
		$status.success:=False:C215
		$status.errors:=$errorStack
		$status.statusText:=$errorStack[0].message
	Else 
		$status.success:=True:C214
		$status.statusText:=Super:C1706._getStatusLine()
	End if 
	
	
	// ----------------------------------------------------
	
	
Function getFolderList($includeHiddenFolders : Boolean) : Object
	
	var $response : Object
	var $urlParams; $URL : Text
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	$urlParams+="/mailFolders"
	If ($includeHiddenFolders)
		$urlParams+="/?includeHiddenFolders=true"
	End if 
	
	$URL:=Super:C1706._getURL()+$urlParams
	$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
	
	return $response["value"]
	
	
	// ----------------------------------------------------
	
	
Function delete($mailId : Text; $folderId : Text) : Object
	
	var $urlParams; $URL : Text
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	If (Length:C16($folderId)>0)
		$urlParams+="/mailFolder/"+$folderId
	End if 
	$urlParams+="/messages/"+$mailId
	
	$URL:=Super:C1706._getURL()+$urlParams
	Super:C1706._sendRequestAndWaitResponse("DELETE"; $URL)
	
	return This:C1470._returnStatus()
	