Class extends _GoogleAPI

property mailType : Text
property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "JMAP"
	This.userId:=String($inParameters.userId)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _postJSONMessage($inURL : Text; $inMail : Object; $inHeader : Object) : Object
	
	var $response : Object:=Null
	
	If ($inMail#Null)
		
		var $headers : Object:={}
		$headers["Content-Type"]:="message/rfc822"
		If (($inHeader#Null) && (Value type($inHeader)=Is object))
			var $keys : Collection:=OB Keys($inHeader)
			var $key : Text
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $inMail)
		This._internals._response:=$response
	Else 
		Super._throwError(1)
	End if 
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant; $inLabelIds : Collection) : Object
	
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
	
	var $message : Object:={raw: $requestBody}
	If ((Value type($inLabelIds)=Is collection) && ($inLabelIds.length>0))
		$message.labelIds:=$inLabelIds
	End if 
	var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $message)
	This._internals._response:=$response
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; $inURL : Text; $inMail : Variant; $inLabelIds : Collection) : Object
	
	var $status : Object
	var $labelIds : Collection:=Null
	
	Super._throwErrors(False)
	
	If ($inFunction="append")
		$labelIds:=((Value type($inLabelIds)=Is collection) && ($inLabelIds.length>0)) ? $inLabelIds : ["DRAFT"]
	End if 
	
	Case of 
		: ((This.mailType="MIME") && (\
			(Value type($inMail)=Is text) || \
			(Value type($inMail)=Is BLOB)))
			$status:=This._postMailMIMEMessage($inURL; $inMail; $labelIds)
			
		: ((This.mailType="JMAP") && (Value type($inMail)=Is object))
			$status:=This._postMailMIMEMessage($inURL; $inMail; $labelIds)
			
		Else 
			Super._throwError(10; {which: 1; function: $inFunction})
			$status:=This._returnStatus()
			
	End case 
	
	Super._throwErrors(True)
	
	return $status
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function append($inMail : Variant; $inLabelIds : Collection) : Object
	
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/"
	
	var $status : Object:=This._postMessage("append"; $URL; $inMail; $inLabelIds)
	If ((Value type(This._internals._response)=Is object) && (Length(String(This._internals._response.id))>0))
		$status.id:=String(This._internals._response.id)
	End if 
	
	return $status
	
	
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/send"
	
	return This._postMessage("send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text; $permanently : Boolean) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._throwError(10; {which: "\"mailId\""; function: "delete"})
			
		: (Length(String($inMailId))=0)
			Super._throwError(9; {which: "\"mailId\""; function: "delete"})
			
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
			Super._throwError(10; {which: "\"mailId\""; function: "untrash"})
			
		: (Length(String($inMailId))=0)
			Super._throwError(9; {which: "\"mailId\""; function: "untrash"})
			
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
			Super._throwError(10; {which: "\"mailId\""; function: "getMail"})
			
		: (Length(String($inMailId))=0)
			Super._throwError(9; {which: "\"mailId\""; function: "getMail"})
			
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
			Super._throwError(10; {which: "\"mailIds\""; function: "getMails"})
			
		: (Num($inMailIds.length)=0)
			Super._throwError(9; {which: "\"mailIds\""; function: "getMails"})
			
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
			Super._throwError(10; {which: "\"mailIds\""; function: "update"})
			
		: (Num($inMailIds.length)=0)
			Super._throwError(9; {which: "\"mailIds\""; function: "update"})
			
		: (Num($inMailIds.length)>1000)
			Super._throwError(13; {which: "\"mailIds\""; function: "update"; max: 1000})
			
		: (Type($inParameters)#Is object)
			Super._throwError(10; {which: "\"parameters\""; function: "update"})
			
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
			Super._throwError(10; {which: "\"labelId\""; function: "getLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "getLabel"})
			
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
			Super._throwError(10; {which: "\"labelInfo\""; function: "createLabel"})
			
		: (OB Is empty($inLabelInfo))
			Super._throwError(9; {which: "\"labelInfo\""; function: "createLabel"})
			
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
			Super._throwError(10; {which: "\"labelId\""; function: "deleteLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "deleteLabel"})
			
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
			Super._throwError(10; {which: "\"labelId\""; function: "updateLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "updateLabel"})
			
		: (Type($inLabelInfo)#Is object)
			Super._throwError(10; {which: "\"labelInfo\""; function: "updateLabel"})
			
		: (OB Is empty($inLabelInfo))
			Super._throwError(9; {which: "\"labelInfo\""; function: "updateLabel"})
			
		Else 
			
			var $headers : Object:={}
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels/"+$inLabelId
			
			$response:=Super._sendRequestAndWaitResponse("PUT"; $URL; $headers; $inLabelInfo)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus(($response#Null) ? {label: $response} : Null)
