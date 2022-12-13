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
	
	return This:C1470._postMessage("append"; $URL; $inMail; True:C214)
	
	
	// ----------------------------------------------------
	
	
Function reply($inMail : Variant; $inMailId : Text; $bReplyAll : Boolean) : Object
	
	Super:C1706._clearErrorStack()
	
	If ((Type:C295($inMailId)=Is text:K8:3) && (Length:C16(String:C10($inMailId))>0))
		
		var $URL : Text
		var $body : Object
		var $bUseCreateReply : Boolean
		
		$URL:=Super:C1706._getURL()
		If (Length:C16(String:C10(This:C1470.userId))>0)
			$URL+="users/"+This:C1470.userId
		Else 
			$URL+="me"
		End if 
		
		$URL+="/messages/"+$inMailId+(Bool:C1537($bReplyAll) ? "/replyAll" : "/reply")
		
		If ((This:C1470.mailType="MIME") || (This:C1470.mailType="JMAP"))
			If (OB Is defined:C1231($inMail; "message"))
				$body:=$inMail.message
			End if 
		Else 
			$body:=$inMail
		End if 
		
		return This:C1470._postMessage("reply"; $URL; $body; True:C214)
		
	Else 
		
		Super:C1706._pushError((Length:C16(String:C10($inMailId))=0) ? 9 : 10; New object:C1471("which"; "\"mailId\""; "function"; "reply"))
		return This:C1470._returnStatus()
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _postMessage($inFunction : Text; \
$inURL : Text; \
$inMail : Variant; \
$bSkipMessageEncapsulation : Boolean; \
$inHeader : Object) : Object
	
	var $status : Object
	
	Super:C1706._throwErrors(False:C215)
	
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
			$status:=This:C1470._postJSONMessage($inURL; $inMail; $bSkipMessageEncapsulation; $inHeader)
			
		Else 
			Super:C1706._pushError(10; New object:C1471("which"; 1; "function"; $inFunction))
			$status:=This:C1470._returnStatus()
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return $status
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
	var $headers : Object
	var $requestBody : Text
	
	$headers:=New object:C1471
	$headers["Content-Type"]:="text/plain"
	
/*
POST /me/mailFolders/{id}/messages with MIME format always returns UnableToDeserializePostBody 
An issue has already been registered.
See: https://github.com/microsoftgraph/microsoft-graph-docs/issues/16368
See also: https://learn.microsoft.com/en-us/answers/questions/544038/unabletodeserializepostbody-error-when-testing-wit.html
*/
	
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
Function _postJSONMessage($inURL : Text; \
$inMail : Object; \
$bSkipMessageEncapsulation : Boolean; \
$inHeader : Object) : Object
	
	If ($inMail#Null:C1517)
		var $headers : Object
		var $requestBody : Text
		var $message : Object
		
		$headers:=New object:C1471
		$headers["Content-Type"]:="application/json"
		If (($inHeader#Null:C1517) && (Value type:C1509($inHeader)=Is object:K8:27))
			var $keys : Collection
			var $key : Text
			$keys:=OB Keys:C1719($inHeader)
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		If (Not:C34(OB Is defined:C1231($inMail; "message")) && Not:C34($bSkipMessageEncapsulation))
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
	
	Super:C1706._clearErrorStack()
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
	
	Super:C1706._clearErrorStack()
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
	
	$urlParams:=Super:C1706._getURLParamsFromObject($inParameters)
	$URL+=$urlParams
	
	return cs:C1710.GraphMessageList.new(This:C1470; This:C1470._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	If ((Type:C295($inMailId)=Is text:K8:3) && (Length:C16(String:C10($inMailId))>0))
		
		var $URL : Text
		
		$URL:=Super:C1706._getURL()
		If (Length:C16(String:C10(This:C1470.userId))>0)
			$URL+="users/"+This:C1470.userId
		Else 
			$URL+="me"
		End if 
		$URL+="/messages/"+$inMailId
		
		Super:C1706._sendRequestAndWaitResponse("DELETE"; $URL)
		
	Else 
		
		Super:C1706._pushError((Length:C16(String:C10($inMailId))=0) ? 9 : 10; New object:C1471("which"; "\"mailId\""; "function"; "delete"))
	End if 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function move($inMailId : Text; $inFolderId : Text) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._pushError(10; New object:C1471("which"; "\"mailId\""; "function"; "copy"))
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._pushError(9; New object:C1471("which"; "\"mailId\""; "function"; "copy"))
			
		: (Type:C295($inFolderId)#Is text:K8:3)
			Super:C1706._pushError(10; New object:C1471("which"; "\"folderId\""; "function"; "move"))
			
		: (Length:C16(String:C10($inFolderId))=0)
			Super:C1706._pushError(9; New object:C1471("which"; "\"folderId\""; "function"; "copy"))
			
		Else 
			var $URL : Text
			var $headers; $body : Object
			
			$URL:=Super:C1706._getURL()
			If (Length:C16(String:C10(This:C1470.userId))>0)
				$URL+="users/"+This:C1470.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/messages/"+$inMailId+"/move"
			
			$headers:=New object:C1471("Content-Type"; "application/json")
			$body:=New object:C1471("destinationId"; $inFolderId)
			
			Super:C1706._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify:C1217($body))
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function copy($inMailId : Text; $inFolderId : Text) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._pushError(10; New object:C1471("which"; "\"mailId\""; "function"; "copy"))
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._pushError(9; New object:C1471("which"; "\"mailId\""; "function"; "copy"))
			
		: (Type:C295($inFolderId)#Is text:K8:3)
			Super:C1706._pushError(10; New object:C1471("which"; "\"folderId\""; "function"; "copy"))
			
		: (Length:C16(String:C10($inFolderId))=0)
			Super:C1706._pushError(9; New object:C1471("which"; "\"folderId\""; "function"; "copy"))
			
		Else 
			var $URL : Text
			var $headers; $body : Object
			
			$URL:=Super:C1706._getURL()
			If (Length:C16(String:C10(This:C1470.userId))>0)
				$URL+="users/"+This:C1470.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/messages/"+$inMailId+"/copy"
			
			$headers:=New object:C1471("Content-Type"; "application/json")
			$body:=New object:C1471("destinationId"; $inFolderId)
			
			Super:C1706._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify:C1217($body))
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text; $inOptions : Object)->$response : Variant
	
	Super:C1706._clearErrorStack()
	
	If ((Type:C295($inMailId)=Is text:K8:3) && (Length:C16(String:C10($inMailId))>0))
		
		var $URL; $format; $contentType : Text
		var $result : Variant
		var $headers : Object
		
		$URL:=Super:C1706._getURL()
		If (Length:C16(String:C10(This:C1470.userId))>0)
			$URL+="users/"+This:C1470.userId
		Else 
			$URL+="me"
		End if 
		$URL+="/messages/"+$inMailId
		
		$format:=(($inOptions#Null:C1517) && \
			(Length:C16(String:C10($inOptions.format))>0)) ? $inOptions.format : This:C1470.mailType
		If (($format="JMAP") || ($format="MIME"))
			$URL+="/$value"
		End if 
		
		$contentType:=(($inOptions#Null:C1517) && \
			(Length:C16(String:C10($inOptions.contentType))>0)) ? $inOptions.contentType : ""
		If (($contentType="text") || ($contentType="html"))
			$headers:=New object:C1471("Prefer"; $contentType)
		End if 
		
		$result:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL; $headers)
		If ($result#Null:C1517)
			If ($format="Microsoft")
				$response:=cs:C1710.GraphMessage.new(This:C1470._internals._OAuth2Provider; \
					New object:C1471("userId"; String:C10(This:C1470.userId)); \
					$result)
				
			Else 
				If (Value type:C1509($result)=Is text:K8:3)
					If ($format="JMAP")
						$response:=MAIL Convert from MIME:C1681($result)
					Else 
						$response:=$result
					End if 
				End if 
			End if 
			return $response
		End if 
		
	Else 
		
		Super:C1706._throwError((Length:C16(String:C10($inMailId))=0) ? 9 : 10; New object:C1471("which"; "\"mailId\""; "function"; "getMail"))
	End if 
	
	return Null:C1517
	