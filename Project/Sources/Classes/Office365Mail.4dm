Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "Microsoft"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	
	
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $URL : Text
	
	$URL:=Super:C1706._getURL()
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$URL+="users/"+This:C1470.userId+"/sendMail"
	Else 
		$URL+="me/sendMail"
	End if 
	
	return This:C1470._postMessage("send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function append($inMail : Variant; $inFolderId : Text) : Object
	
	var $URL : Text
	
	$URL:=Super:C1706._getURL()
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$URL+="users/"+This:C1470.userId
	Else 
		$URL+="me"
	End if 
	If (Length:C16($inFolderId)>0)
		$URL+="/mailFolders/"+$inFolderId
	End if 
	$URL+="/messages"
	
	return This:C1470._postMessage("append"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function reply($inMail : Variant; $inMailId : Text; $bReplyAll : Boolean) : Object
	
	var $URL : Text
	var $body : Object
	
	$URL:=Super:C1706._getURL()
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$URL+="users/"+This:C1470.userId
	Else 
		$URL+="me"
	End if 
	$URL+="/messages/"+$inMail+(Bool:C1537($bReplyAll) ? "/replyAll" : "/reply")
	
	If ((This:C1470.mailType="MIME") || (This:C1470.mailType="JMAP"))
		If (OB Is defined:C1231($inMail; "message"))
			$body:=$inMail.message
		End if 
	Else 
		$body:=$inMail
	End if 
	
	return This:C1470._postMessage("reply"; $URL; $body)
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _postMessage($inFunction : Text; $inURL : Text; $inMail : Variant) : Object
	
	var $status : Object
	var $savedMethod : Text
	
	$savedMethod:=Method called on error:C704
	ON ERR CALL:C155("_ErrorHandler")
	
	Super:C1706._throwErrors(False:C215)
	Super:C1706._getErrorStack().clear()
	
	If (Length:C16(String:C10(This:C1470.mailType))=0)
		This:C1470.mailType:="Microsoft"
	End if 
	
	Case of 
		: ((This:C1470.mailType="MIME") && (\
			(Value type:C1509($inMail)=Is text:K8:3) || \
			(Value type:C1509($inMail)=Is BLOB:K8:12)))
			$status:=This:C1470._postMailMIMEMessage($inURL; $inMail)
			
		: ((This:C1470.mailType="JMAP") && (Value type:C1509($inMail)=Is object:K8:27))
			$status:=This:C1470._postMailMIMEMessage($inURL; $inMail)
			
		: ((This:C1470.mailType="Microsoft") && (Value type:C1509($inMail)=Is object:K8:27))
			$status:=This:C1470._postJSONMessage($inURL; $inMail)
			
		Else 
			Super:C1706._pushError(10; New object:C1471("which"; 1; "function"; $inFunction))
			$status:=This:C1470._returnStatus()
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	ON ERR CALL:C155($savedMethod)
	
	return $status
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
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
Function _postJSONMessage($inURL : Text; $inMail : Object) : Object
	
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
	
	
Function getFolderList($inParameters : Object) : Object
	
	var $response : Object
	var $urlParams; $URL : Text
	var $headers : Object
	
	$URL:=Super:C1706._getURL()
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$URL+="users/"+This:C1470.userId
	Else 
		$URL+="me"
	End if 
	$URL+="/mailFolders"
	If (Length:C16(String:C10($inParameters.folderId))>0)
		$URL+="/"+$inParameters.folderId+"/childFolders"
	End if 
	
	If (Length:C16(String:C10($inParameters.search))>0)
		$headers:=New object:C1471("ConsistencyLevel"; "eventual")
	End if 
	
	$urlParams:=Super:C1706._getURLParamsFromObject($inParameters)
	$URL+=$urlParams
	
	return cs:C1710.GraphFolderList.new(This:C1470._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function getMails($inParameters : Object) : Object
	
	var $urlParams; $URL : Text
	var $headers : Object
	
	$URL:=Super:C1706._getURL()
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$URL+="users/"+This:C1470.userId
	Else 
		$URL+="me"
	End if 
	If (Length:C16(String:C10($inParameters.folderId))>0)
		$URL+="/mailFolders/"+$inParameters.folderId
	End if 
	$URL+="/messages"
	
	If (Length:C16(String:C10($inParameters.search))>0)
		$headers:=New object:C1471("ConsistencyLevel"; "eventual")
	End if 
	This:C1470.withAttachments:=(OB Is defined:C1231($inParameters; "withAttachments")) ? $inParameters.withAttachments : True:C214
	
	$urlParams:=Super:C1706._getURLParamsFromObject($inParameters)
	$URL+=$urlParams
	
	return cs:C1710.GraphMailList.new(This:C1470; This:C1470._getOAuth2Provider(); $URL; $headers)
	
	
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
	
	
	// ----------------------------------------------------
	
	
Function move($mailId : Text; $folderId : Text) : Object
	
	var $urlParams; $URL : Text
	var $body : Object
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	$urlParams+="/messages/"+$mailId+"/move"
	
	$body:=New object:C1471("destinationId"; $folderId)
	
	$URL:=Super:C1706._getURL()+$urlParams
	Super:C1706._sendRequestAndWaitResponse("POST"; $URL; Null:C1517; JSON Stringify:C1217($body))
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function copy($mailId : Text; $folderId : Text) : Object
	
	var $urlParams; $URL : Text
	var $body : Object
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	$urlParams+="/messages/"+$mailId+"/copy"
	
	$body:=New object:C1471("destinationId"; $folderId)
	
	$URL:=Super:C1706._getURL()+$urlParams
	Super:C1706._sendRequestAndWaitResponse("POST"; $URL; Null:C1517; JSON Stringify:C1217($body))
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text; $inFormat : Text)->$response : Variant
	
	var $urlParams; $URL; $format : Text
	var $result : Variant
	
	If (Length:C16(String:C10(This:C1470.userId))>0)
		$urlParams:="users/"+This:C1470.userId
	Else 
		$urlParams:="me"
	End if 
	$urlParams+="/messages/"+$inMailId
	
	$format:=(Length:C16($inFormat)>0) ? $inFormat : This:C1470.mailType
	If (($format="JMAP") || ($format="MIME"))
		$urlParams+="/$value"
	End if 
	
	$URL:=Super:C1706._getURL()+$urlParams
	$result:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
	If ($format="Microsoft")
		$response:=Super:C1706._cleanResponseObject($result)
	Else 
		If (Length:C16($result)>0)
			If ($format="JMAP")
				$response:=MAIL Convert from MIME:C1681($result)
			Else 
				$response:=$result
			End if 
		End if 
	End if 
	
	return $response
	