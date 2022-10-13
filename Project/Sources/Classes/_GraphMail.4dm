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
	
	
Function getFolderList($inParentFolderId : Text; $includeHiddenFolders : Boolean) : Collection
	
	var $response : Object
	var $urlParams; $URL : Text
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	$urlParams+="/mailFolders"
	If (Length:C16($inParentFolderId)>0)
		$urlParams+="/mailFolders/"+$inParentFolderId+"/childFolders"
	End if 
	If ($includeHiddenFolders)
		$urlParams+="/?includeHiddenFolders=true"
	End if 
	
	$URL:=Super:C1706._getURL()+$urlParams
	$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
	
	If ($response#Null:C1517)
		return $response["value"]
	End if 
	return Null:C1517
	
	
	// ----------------------------------------------------
	
	
Function getMails($inParameters : Object) : Object
	
	var $urlParams; $URL; $delimiter : Text
	var $headers : Object
	
	$delimiter:="?"
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	If (Length:C16(String:C10($inParameters.folderId))>0)
		$urlParams+="/mailFolders/"+$inParameters.folderId
	End if 
	$urlParams+="/messages"
	
	If (Length:C16(String:C10($inParameters.search))>0)
		$urlParams:=$urlParams+$delimiter+"$search="+$inParameters.search
		$delimiter:="&"
		$headers:=New object:C1471("ConsistencyLevel"; "eventual")
	End if 
	If (Length:C16(String:C10($inParameters.filter))>0)
		$urlParams:=$urlParams+$delimiter+"$filter="+$inParameters.filter
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.select))>0)
		$urlParams:=$urlParams+$delimiter+"$select="+$inParameters.select
		$delimiter:="&"
	End if 
	If (Not:C34(Value type:C1509($inParameters.top)=Is undefined:K8:13))
		$urlParams:=$urlParams+$delimiter+"$top="+Choose:C955(Value type:C1509($inParameters.top)=Is text:K8:3; \
			$inParameters.top; String:C10($inParameters.top))
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.orderBy))>0)
		$urlParams:=$urlParams+$delimiter+"$orderBy="+$inParameters.orderBy
		$delimiter:="&"
	End if 
	
	$URL:=Super:C1706._getURL()+$urlParams
	
	return cs:C1710._MailList.new(This:C1470._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function delete($mailId : Text) : Object
	
	var $urlParams; $URL : Text
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	$urlParams+="/messages/"+$mailId
	
	$URL:=Super:C1706._getURL()+$urlParams
	Super:C1706._sendRequestAndWaitResponse("DELETE"; $URL)
	
	return This:C1470._returnStatus()
	