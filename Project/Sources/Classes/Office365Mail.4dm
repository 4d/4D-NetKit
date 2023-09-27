Class extends _GraphAPI

property mailType : Text
property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "Microsoft"
	This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _postJSONMessage($inURL : Text; $inMail : Object; $bSkipMessageEncapsulation : Boolean; $inHeader : Object) : Object
	
	If ($inMail#Null)
		var $headers; $message; $messageCopy; $response : Object
		var $requestBody : Text
		
		$headers:={}
		$headers["Content-Type"]:="application/json"
		If (($inHeader#Null) && (Value type($inHeader)=Is object))
			var $keys : Collection
			var $key : Text
			$keys:=OB Keys($inHeader)
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		$messageCopy:=This._copyGraphMessage($inMail)
		If (Not(OB Is defined($inMail; "message")) && Not($bSkipMessageEncapsulation))
			$message:={message: $messageCopy}
		Else 
			$message:=$messageCopy
		End if 
		$requestBody:=JSON Stringify($message)
		
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $requestBody)
	Else 
		Super._pushError(1)
	End if 
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
	var $headers : Object
	var $requestBody : Text
	
	$headers:={}
	$headers["Content-Type"]:="text/plain"
	
	/*
		POST /me/mailFolders/{id}/messages with MIME format always returns UnableToDeserializePostBody 
		An issue has already been registered.
		See: https://github.com/microsoftgraph/microsoft-graph-docs/issues/16368
		See also: https://learn.microsoft.com/en-us/answers/questions/544038/unabletodeserializepostbody-error-when-testing-wit.html
	*/
	
	Case of 
		: (Value type($inMail)=Is BLOB)
			$requestBody:=Convert to text($inMail; "UTF-8")
			
		: (Value type($inMail)=Is object)
			$requestBody:=MAIL Convert to MIME($inMail)
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE($requestBody)
	
	Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $requestBody)
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; $inURL : Text; $inMail : Variant; $bSkipMessageEncapsulation : Boolean; $inHeader : Object) : Object
	
	var $status : Object
	
	Super._throwErrors(False)
	
	If (Length(String(This.mailType))=0)
		This.mailType:="Microsoft"
	End if 
	
	Case of 
		: ((This.mailType="MIME") && (\
			(Value type($inMail)=Is text) || \
			(Value type($inMail)=Is BLOB)))
			$status:=This._postMailMIMEMessage($inURL; $inMail)
			
		: ((This.mailType="JMAP") && (Value type($inMail)=Is object))
			$status:=This._postMailMIMEMessage($inURL; $inMail)
			
		: ((This.mailType="Microsoft") && (Value type($inMail)=Is object))
			$status:=This._postJSONMessage($inURL; $inMail; $bSkipMessageEncapsulation; $inHeader)
			
		Else 
			Super._pushError(10; {which: 1; function: $inFunction})
			$status:=This._returnStatus()
			
	End case 
	
	Super._throwErrors(True)
	
	return $status
	
	
	// ----------------------------------------------------
	
	
Function _returnStatus($inAdditionalInfo : Object)->$status : Object
	
	var $errorStack : Collection
	$errorStack:=Super._getErrorStack()
	$status:={}
	
	If (Not(OB Is empty($inAdditionalInfo)))
		var $keys : Collection
		var $key : Text
		
		$keys:=OB Keys($inAdditionalInfo)
		For each ($key; $keys)
			$status[$key]:=$inAdditionalInfo[$key]
		End for each 
	End if 
	
	If ($errorStack.length>0)
		$status.success:=False
		$status.errors:=$errorStack
		$status.statusText:=$errorStack[0].message
	Else 
		$status.success:=True
		$status.statusText:=Super._getStatusLine()
	End if 
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function append($inMail : Variant; $inFolderId : Text) : Object
	
	var $URL : Text
	
	$URL:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId
	Else 
		$URL+="me"
	End if 
	If (Length($inFolderId)>0)
		$URL+="/mailFolders/"+$inFolderId
	End if 
	$URL+="/messages"
	
	return This._postMessage("append"; $URL; $inMail; True)
	
	
	// ----------------------------------------------------
	
	
Function copy($inMailId : Text; $inFolderId : Text) : Object
	
	var $response : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._pushError(10; {which: "\"mailId\""; function: "copy"})
			
		: (Length(String($inMailId))=0)
			Super._pushError(9; {which: "\"mailId\""; function: "copy"})
			
		: (Type($inFolderId)#Is text)
			Super._pushError(10; {which: "\"folderId\""; function: "copy"})
			
		: (Length(String($inFolderId))=0)
			Super._pushError(9; {which: "\"folderId\""; function: "copy"})
			
		Else 
			var $URL : Text
			var $headers; $body : Object
			
			$URL:=Super._getURL()
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/messages/"+$inMailId+"/copy"
			
			$headers:={}
			$headers["Content-Type"]:="application/json"
			$body:={destinationId: $inFolderId}
			
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify($body))
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text) : Object
	
	Super._throwErrors(False)
	
	If ((Type($inMailId)=Is text) && (Length(String($inMailId))>0))
		
		var $URL : Text
		
		$URL:=Super._getURL()
		If (Length(String(This.userId))>0)
			$URL+="users/"+This.userId
		Else 
			$URL+="me"
		End if 
		$URL+="/messages/"+$inMailId
		
		Super._sendRequestAndWaitResponse("DELETE"; $URL)
		
	Else 
		
		Super._pushError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "delete"})
	End if 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text; $inOptions : Object)->$response : Variant
	
	Super._clearErrorStack()
	
	If ((Type($inMailId)=Is text) && (Length(String($inMailId))>0))
		
		var $URL; $mailType; $contentType : Text
		var $result : Variant
		var $headers : Object
		
		$URL:=Super._getURL()
		If (Length(String(This.userId))>0)
			$URL+="users/"+This.userId
		Else 
			$URL+="me"
		End if 
		$URL+="/messages/"+$inMailId
		
		$mailType:=(($inOptions#Null) && \
			(Length(String($inOptions.mailType))>0)) ? $inOptions.mailType : This.mailType
		If (($mailType="JMAP") || ($mailType="MIME"))
			$URL+="/$value"
		End if 
		
		$contentType:=(($inOptions#Null) && \
			(Length(String($inOptions.contentType))>0)) ? $inOptions.contentType : ""
		If (($contentType="text") || ($contentType="html"))
			$headers:={Prefer: "outlook.body-content-type=\""+$contentType+"\""}
		End if 
		
		$result:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
		If ($result#Null)
			If ($mailType="Microsoft")
				$response:=cs.GraphMessage.new(This._internals._oAuth2Provider; \
					{userId: String(This.userId)}; \
					$result)
				
			Else 
				If (Value type($result)=Is text)
					If ($mailType="JMAP")
						$response:=MAIL Convert from MIME($result)
					Else 
						$response:=$result
					End if 
				End if 
			End if 
			return $response
		End if 
		
	Else 
		
		Super._throwError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "getMail"})
	End if 
	
	return Null
	
	
	// ----------------------------------------------------
	
	
Function getMails($inParameters : Object) : Object
	
	var $urlParams; $URL : Text
	var $headers : Object
	
	Super._clearErrorStack()
	$URL:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId
	Else 
		$URL+="me"
	End if 
	If (Length(String($inParameters.folderId))>0)
		$URL+="/mailFolders/"+$inParameters.folderId
	End if 
	$URL+="/messages"
	
	If (Length(String($inParameters.search))>0)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	
	$urlParams:=Super._getURLParamsFromObject($inParameters; True)
	$URL+=$urlParams
	
	return cs.GraphMessageList.new(This; This._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function move($inMailId : Text; $inFolderId : Text) : Object
	
	var $response : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._pushError(10; {which: "\"mailId\""; function: "copy"})
			
		: (Length(String($inMailId))=0)
			Super._pushError(9; {which: "\"mailId\""; function: "copy"})
			
		: (Type($inFolderId)#Is text)
			Super._pushError(10; {which: "\"folderId\""; function: "move"})
			
		: (Length(String($inFolderId))=0)
			Super._pushError(9; {which: "\"folderId\""; function: "copy"})
			
		Else 
			var $URL : Text
			var $headers; $body : Object
			
			$URL:=Super._getURL()
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/messages/"+$inMailId+"/move"
			
			$headers:={}
			$headers["Content-Type"]:="application/json"
			$body:={destinationId: $inFolderId}
			
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify($body))
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function reply($inMail : Object; $inMailId : Text; $bReplyAll : Boolean) : Object
	
	Super._clearErrorStack()
	
	If ((Type($inMail)=Is object) && (Type($inMailId)=Is text) && (Length(String($inMailId))>0))
		
		var $URL : Text
		var $body : Variant
		var $bUseCreateReply : Boolean
		
		$URL:=Super._getURL()
		If (Length(String(This.userId))>0)
			$URL+="users/"+This.userId
		Else 
			$URL+="me"
		End if 
		
		$URL+="/messages/"+$inMailId+(Bool($bReplyAll) ? "/replyAll" : "/reply")
		
		If ((This.mailType="MIME") || (This.mailType="JMAP"))
			If (OB Is defined($inMail; "message"))
				$body:=$inMail.message
			End if 
		Else 
			$body:=$inMail
		End if 
		
		return This._postMessage("reply"; $URL; $body; True)
		
	Else 
		
		If (Type($inMail)#Is object)
			Super._pushError(10; {which: "\"reply\""; function: "reply"})
		Else 
			Super._pushError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "reply"})
		End if 
		return This._returnStatus()
	End if 
	
	
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $URL : Text
	
	$URL:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId+"/sendMail"
	Else 
		$URL+="me/sendMail"
	End if 
	
	return This._postMessage("send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function update($inMailId : Text; $inMail : Object) : Object
	
	Super._throwErrors(False)
	
	If ((Type($inMail)=Is object) && (Type($inMailId)=Is text) && (Length(String($inMailId))>0))
		
		var $URL : Text
		var $response : Object
		var $bUseCreateReply : Boolean
		
		$URL:=Super._getURL()
		If (Length(String(This.userId))>0)
			$URL+="users/"+This.userId
		Else 
			$URL+="me"
		End if 
		$URL+="/messages/"+$inMailId
		
		If (This.mailType="Microsoft")
			
			var $headers : Object
			$headers:={}
			$headers["Content-Type"]:="application/json"
			$response:=Super._sendRequestAndWaitResponse("PATCH"; $URL; $headers; JSON Stringify($inMail))
			
		Else 
			
			Super._pushError(3; {attribute: "\"mail\""})
		End if 
		
	Else 
		
		If (Type($inMail)#Is object)
			
			Super._pushError(10; {which: "\"mail\""; function: "update"})
		Else 
			
			Super._pushError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "update"})
		End if 
	End if 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// Mark: - Folders
	// ----------------------------------------------------
	
	
Function createFolder($inFolderName : Text; $bIsHidden : Boolean; $inParentFolderId : Text) : Object
	
	var $response : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inFolderName)#Is text)
			Super._pushError(10; {which: "\"folderName\""; function: "createFolder"})
			
		: (Length(String($inFolderName))=0)
			Super._pushError(9; {which: "\"folderName\""; function: "createFolder"})
			
		Else 
			var $URL : Text
			var $headers; $body : Object
			
			$URL:=Super._getURL()
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/mailFolders"
			If (Length(String($inParentFolderId))>0)
				$URL+="/"+$inParentFolderId+"/childFolders"
			End if 
			
			$headers:={}
			$headers["Content-Type"]:="application/json"
			$body:={displayName: $inFolderName; isHidden: ($bIsHidden ? "true" : "false")}
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify($body))
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function deleteFolder($inFolderId : Text) : Object
	
	var $response : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inFolderId)#Is text)
			Super._pushError(10; {which: "\"folderId\""; function: "deleteFolder"})
			
		: (Length(String($inFolderId))=0)
			Super._pushError(9; {which: "\"folderId\""; function: "deleteFolder"})
			
		Else 
			var $URL : Text
			
			$URL:=Super._getURL()
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/mailFolders/"+$inFolderId
			
			Super._sendRequestAndWaitResponse("DELETE"; $URL)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getFolder($inFolderId : Text) : Object
	
	var $response : Object
	
	Super._clearErrorStack()
	
	Case of 
		: (Type($inFolderId)#Is text)
			Super._pushError(10; {which: "\"folderId\""; function: "getFolder"})
			
		: (Length(String($inFolderId))=0)
			Super._pushError(9; {which: "\"folderId\""; function: "getFolder"})
			
		Else 
			var $URL : Text
			
			$URL:=Super._getURL()
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/mailFolders/"+$inFolderId
			
			$response:=Super._sendRequestAndWaitResponse("GET"; $URL)
			
	End case 
	
	return Super._cleanGraphObject($response)
	
	
	// ----------------------------------------------------
	
	
Function getFolderList($inParameters : Object) : Object
	
	var $response : Object
	var $urlParams; $URL : Text
	var $headers : Object
	
	Super._clearErrorStack()
	$URL:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId
	Else 
		$URL+="me"
	End if 
	$URL+="/mailFolders"
	If (Length(String($inParameters.folderId))>0)
		$URL+="/"+$inParameters.folderId+"/childFolders"
	End if 
	
	If (Length(String($inParameters.search))>0)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	
	$urlParams:=Super._getURLParamsFromObject($inParameters; True)
	$URL+=$urlParams
	
	return cs.GraphFolderList.new(This._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function renameFolder($inFolderId : Text; $inNewFolderName : Text) : Object
	
	var $response : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inFolderId)#Is text)
			Super._pushError(10; {which: "\"folderId\""; function: "renameFolder"})
			
		: (Length(String($inFolderId))=0)
			Super._pushError(9; {which: "\"folderId\""; function: "renameFolder"})
			
		: (Type($inNewFolderName)#Is text)
			Super._pushError(10; {which: "\"folderName\""; function: "renameFolder"})
			
		: (Length(String($inNewFolderName))=0)
			Super._pushError(9; {which: "\"folderName\""; function: "renameFolder"})
		Else 
			var $URL : Text
			var $headers; $body : Object
			
			$URL:=Super._getURL()
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/mailFolders/"+$inFolderId
			
			$headers:={}
			$headers["Content-Type"]:="application/json"
			$body:={displayName: $inNewFolderName}
			$response:=Super._sendRequestAndWaitResponse("PATCH"; $URL; $headers; JSON Stringify($body))
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
