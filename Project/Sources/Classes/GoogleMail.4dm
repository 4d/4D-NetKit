Class extends _GoogleAPI

property mailType : Text
property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "JMAP"
	This.userId:=String($inParameters.userId)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant; $inLabelIds : Collection; $bIsDraft : Boolean) : Object
	
	var $requestBody : Text
	var $headers : Object:={}
	$headers["Content-Type"]:="application/json"
	
	Case of 
		: (Value type($inMail)=Is BLOB)
			$requestBody:=Try(Convert to text($inMail; "UTF-8"))
			
		: (Value type($inMail)=Is object)
			$requestBody:=Try(MAIL Convert to MIME($inMail))
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE($requestBody)
	
	var $response : Object:=Null
	var $message : Object:={raw: $requestBody}
	If ((Value type($inLabelIds)=Is collection) && ($inLabelIds.length>0))
		$message.labelIds:=$inLabelIds
	End if 
	If (Bool($bIsDraft))
		var $draft : Object:={id: Generate UUID; message: $message}
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $draft)
	Else 
		$message.raw:=$requestBody
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $message)
	End if 
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; $inURL : Text; $inMail : Variant; $inLabelIds : Collection) : Object
	
	var $response : Object:=Null
	var $labelIds : Collection:=Null
	
	Super._throwErrors(False)
	
	If ($inFunction="append")
		$labelIds:=((Value type($inLabelIds)=Is collection) && ($inLabelIds.length>0)) ? $inLabelIds : ["DRAFT"]
	End if 
	
	Case of 
		: ((This.mailType="MIME") && (\
			(Value type($inMail)=Is text) || \
			(Value type($inMail)=Is BLOB)))
			$response:=This._postMailMIMEMessage($inURL; $inMail; $labelIds)
			
		: ((This.mailType="JMAP") && (Value type($inMail)=Is object))
			$response:=This._postMailMIMEMessage($inURL; $inMail; $labelIds)
			
		Else 
			Super._throwError(10; {which: 1; function: $inFunction})
			
	End case 
	
	Super._throwErrors(True)
	
	If ($response#Null)
		This._internals._response:=$response
	End if 
	
	return This._returnStatus()
	
	
	// Mark: - Mails
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function append($inMail : Variant; $inLabelIds : Collection) : Object
	
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/"
	
	var $status : Object:=This._postMessage("google.mail.append"; $URL; $inMail; $inLabelIds)
	If ((Value type(This._internals._response)=Is object) && (Length(String(This._internals._response.id))>0))
		$status.id:=String(This._internals._response.id)
	End if 
	
	return $status
	
	
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/send"
	
	return This._postMessage("google.mail.send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text; $permanently : Boolean) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._throwError(10; {which: "\"mailId\""; function: "google.mail.delete"})
			
		: (Length(String($inMailId))=0)
			Super._throwError(9; {which: "\"mailId\""; function: "google.mail.delete"})
			
		Else 
			
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId
			If (Not(Bool($permanently)))
				$URL+="/trash"
			End if 
			var $verb : Text:=Bool($permanently) ? "DELETE" : "POST"
			
			This._internals._response:=Super._sendRequestAndWaitResponse($verb; $URL)
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function untrash($inMailId : Text) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._throwError(10; {which: "\"mailId\""; function: "google.mail.untrash"})
			
		: (Length(String($inMailId))=0)
			Super._throwError(9; {which: "\"mailId\""; function: "google.mail.untrash"})
			
		Else 
			
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId+"/untrash"
			
			This._internals._response:=Super._sendRequestAndWaitResponse("POST"; $URL)
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMailIds($inParameters : Object) : Object
	
	Super._clearErrorStack()
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	var $urlParams : Text:="users/"+$userId+"/messages"+This._getURLParamsFromObject($inParameters)
	
	return cs.GoogleMailIdList.new(This._getOAuth2Provider(); $URL+$urlParams)
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text; $inParameters : Object)->$response : Variant
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._throwError(10; {which: "\"mailId\""; function: "google.mail.getMail"})
			
		: (Length(String($inMailId))=0)
			Super._throwError(9; {which: "\"mailId\""; function: "google.mail.getMail"})
			
		Else 
			
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			var $mailType : Text:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
			var $format : Text:=String($inParameters.format)
			$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
			var $parameters : Object:=(($inParameters#Null) && (Value type($inParameters)=Is object)) ? $inParameters : {format: $format}
			If ($parameters.format#$format)
				$parameters.format:=$format
			End if 
			var $urlParams : Text:="users/"+$userId+"/messages/"+String($inMailId)+This._getURLParamsFromObject($parameters)
			
			var $result : Object:=Super._sendRequestAndWaitResponse("GET"; $URL+$urlParams)
			$response:=This._extractRawMessage($result; $format; $mailType)
			
	End case 
	
	Super._throwErrors(True)
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function getMails($inMailIds : Collection; $inParameters : Object) : Collection
	
	Super._clearErrorStack()
	
	Case of 
		: (Type($inMailIds)#Is collection)
			Super._throwError(10; {which: "\"mailIds\""; function: "google.mail.getMails"})
			
		: (Num($inMailIds.length)=0)
			Super._throwError(9; {which: "\"mailIds\""; function: "google.mail.getMails"})
			
		Else 
			
			var $result : Collection:=Null
			var $mailIds : Collection:=(Value type($inMailIds)=Is collection) ? $inMailIds : []
			
			If (($mailIds.length>0) && (Value type($mailIds[0])=Is object))
				$mailIds:=$mailIds.extract("id")
			End if 
			
			If ($mailIds.length=1)
				
				var $response : Variant:=This.getMail($mailIds[0]; $inParameters)
				If ($response#Null)
					$result:=New collection($response)
				End if 
				
			Else 
				
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				var $mailType : Text:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
				var $format : Text:=String($inParameters.format)
				$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
				var $parameters : Object:=(($inParameters#Null) && (Value type($inParameters)=Is object)) ? $inParameters : {format: $format}
				If ($parameters.format#$format)
					$parameters.format:=$format
				End if 
				
				var $i : Integer:=1
				var $batchRequestes : Collection:=[]
				var $mailId : Text
				
				For each ($mailId; $mailIds)
					var $item : Text:="<item"+String($i)+">"
					$i+=1
					var $urlParams : Text:="users/"+$userId+"/messages/"+$mailId+This._getURLParamsFromObject($parameters)
					$batchRequestes.push({request: {verb: "GET"; URL: $URL+$urlParams; id: $item}})
				End for each 
				
				var $batchParams : Object:={batchRequestes: $batchRequestes; mailType: $mailType; format: $format}
				var $batchRequest : cs._GoogleBatchRequest:=cs._GoogleBatchRequest.new(This._getOAuth2Provider(); $batchParams)
				$result:=$batchRequest.sendRequestAndWaitResponse()
				
				If (($result=Null) || ($batchRequest._getLastError()#Null))
					var $stack : Collection:=$batchRequest._getErrorStack().reverse()
					var $error : Object
					
					For each ($error; $stack)
						This._getErrorStack().push($error)
						throw($error)
					End for each 
				End if 
				
			End if 
			
	End case 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function update($inMailIds : Collection; $inParameters : Object) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailIds)#Is collection)
			Super._throwError(10; {which: "\"mailIds\""; function: "google.mail.update"})
			
		: (Num($inMailIds.length)=0)
			Super._throwError(9; {which: "\"mailIds\""; function: "google.mail.update"})
			
		: (Num($inMailIds.length)>1000)
			Super._throwError(13; {which: "\"mailIds\""; function: "google.mail.update"; max: 1000})
			
		: (Type($inParameters)#Is object)
			Super._throwError(10; {which: "\"parameters\""; function: "google.mail.update"})
			
		Else 
			
			var $mailIds : Collection:=(Value type($inMailIds)=Is collection) ? $inMailIds : []
			
			If (($mailIds.length>0) && (Value type($mailIds[0])=Is object))
				$mailIds:=$mailIds.extract("id")
			End if 
			
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/batchModify"
			
			var $headers : Object:={}
			var $body : Object:={}
			$body.ids:=$mailIds
			$body.addLabelIds:=(Value type($inParameters.addLabelIds)=Is collection) ? $inParameters.addLabelIds : []
			$body.removeLabelIds:=(Value type($inParameters.removeLabelIds)=Is collection) ? $inParameters.removeLabelIds : []
			
			This._internals._response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $body)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// Mark: - Labels
	// ----------------------------------------------------
	
	
Function getLabelList() : Object
	
	Super._clearErrorStack()
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/labels"
	
	var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL)
	
	return This._returnStatus($response)
	
	
	// ----------------------------------------------------
	
	
Function getLabel($inLabelId : Text) : Object
	
	Case of 
		: (Type($inLabelId)#Is text)
			Super._throwError(10; {which: "\"labelId\""; function: "google.mail.getLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "google.mail.getLabel"})
			
		Else 
			
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels/"+$inLabelId
			
			return Super._sendRequestAndWaitResponse("GET"; $URL)
			
	End case 
	
	return Null
	
	
	// ----------------------------------------------------
	
	
Function createLabel($inLabelInfo : Object) : Object
	
	var $response : Object:=Null
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inLabelInfo)#Is object)
			Super._throwError(10; {which: "\"labelInfo\""; function: "google.mail.createLabel"})
			
		: (OB Is empty($inLabelInfo))
			Super._throwError(9; {which: "\"labelInfo\""; function: "google.mail.createLabel"})
			
		Else 
			
			var $headers : Object:={}
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels"
			
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $inLabelInfo)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus(($response#Null) ? {label: $response} : Null)
	
	
	
	// ----------------------------------------------------
	
	
Function deleteLabel($inLabelId : Text) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inLabelId)#Is text)
			Super._throwError(10; {which: "\"labelId\""; function: "google.mail.deleteLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "google.mail.deleteLabel"})
			
		Else 
			
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels/"+$inLabelId
			
			This._internals._response:=Super._sendRequestAndWaitResponse("DELETE"; $URL)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function updateLabel($inLabelId : Text; $inLabelInfo : Object) : Object
	
	var $response : Object:=Null
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inLabelId)#Is text)
			Super._throwError(10; {which: "\"labelId\""; function: "google.mail.updateLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "google.mail.updateLabel"})
			
		: (Type($inLabelInfo)#Is object)
			Super._throwError(10; {which: "\"labelInfo\""; function: "google.mail.updateLabel"})
			
		: (OB Is empty($inLabelInfo))
			Super._throwError(9; {which: "\"labelInfo\""; function: "google.mail.updateLabel"})
			
		Else 
			
			var $headers : Object:={}
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels/"+$inLabelId
			
			$response:=Super._sendRequestAndWaitResponse("PUT"; $URL; $headers; $inLabelInfo)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus(($response#Null) ? {label: $response} : Null)
	
	
	// Mark: - Drafts
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _postDraft($inFunction : Text; $inURL : Text; $inDraft : Variant) : Object
	
	var $response : Object:=Null
	
	Super._throwErrors(False)
	
	Case of 
		: ((This.mailType="MIME") && (\
			(Value type($inDraft)=Is text) || \
			(Value type($inDraft)=Is BLOB)))
			$response:=This._postMailMIMEMessage($inURL; $inDraft; Null; True)
			
		: ((This.mailType="JMAP") && (Value type($inDraft)=Is object))
			$response:=This._postMailMIMEMessage($inURL; $inDraft; Null; True)
			
		Else 
			Super._throwError(10; {which: 1; function: $inFunction})
			
	End case 
	
	Super._throwErrors(True)
	
	return $response
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function createDraft($inDraft : Variant) : Object
	
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	var $URL : Text:=Super._getURL()+"users/"+$userId+"/drafts"
	
	return This._postDraft("mail.createDraft"; $URL; $inDraft)
	
	
	// ----------------------------------------------------
	
	
Function getDraft($inDraftId : Text) : Object
	
	var $response : Object:=Null
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inDraftId)#Is text)
			Super._throwError(10; {which: "\"draftId\""; function: "google.mail.getDraft"})
			
		: (Length(String($inDraftId))=0)
			Super._throwError(9; {which: "\"draftId\""; function: "google.mail.getDraft"})
			
		Else 
			
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			var $URL : Text:=Super._getURL()+"users/"+$userId+"/drafts/"+$inDraftId+"?format=raw"
			var $mailType : Text:=This.mailType
			var $format : Text:="raw"
			var $result : Object:=Super._sendRequestAndWaitResponse("GET"; $URL)
			var $message:=This._extractRawMessage($result.raw; $format; $mailType)
			$response:={id: $result.id; message: $message}
			
	End case 
	
	Super._throwErrors(True)
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function deleteDraft($inDraftId : Text) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inDraftId)#Is text)
			Super._throwError(10; {which: "\"draftId\""; function: "google.mail.deleteDraft"})
			
		: (Length(String($inDraftId))=0)
			Super._throwError(9; {which: "\"draftId\""; function: "google.mail.deleteDraft"})
			
		Else 
			
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			var $URL : Text:=Super._getURL()+"users/"+$userId+"/drafts/"+$inDraftId
			
			This._internals._response:=Super._sendRequestAndWaitResponse("DELETE"; $URL)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function updateDraft($inDraftId : Text; $inDraft : Variant) : Object
	
	var $response : Object:=Null
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inDraftId)#Is text)
			Super._throwError(10; {which: "\"draftId\""; function: "google.mail.updateDraft"})
			
		: (Length(String($inDraftId))=0)
			Super._throwError(9; {which: "\"draftId\""; function: "google.mail.updateDraft"})
			
		Else 
			
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			var $URL : Text:=Super._getURL()+"users/"+$userId+"/drafts/"+$inDraftId
			$response:=This._postMailMIMEMessage($URL; $inDraft; Null; True)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus(($response#Null) ? {draft: $response} : Null)
	
	
	// ----------------------------------------------------
	
	
Function sendDraft($inDraft : Variant) : Object
	
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	var $URL : Text:=Super._getURL()+"users/"+$userId+"/drafts/send"
	
	return This._postDraft("google.mail.sendDraft"; $URL; $inDraft)
	
	
	// ----------------------------------------------------
	
	
Function getDraftList($inParameters : Object) : Object
	
	Super._clearErrorStack()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	var $URL : Text:=Super._getURL()+"users/"+$userId+"/drafts"+This._getURLParamsFromObject($inParameters)
	
	var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL)
	
	return This._returnStatus($response)
	
	
	// ----------------------------------------------------	
