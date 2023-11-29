Class extends _GoogleAPI

property mailType : Text
property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "JMAP"
	This.userId:=String($inParameters.userId)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _postJSONMessage($inURL : Text; \
$inMail : Object; \
$inHeader : Object) : Object
	
	If ($inMail#Null)
		var $headers; $message; $messageCopy; $response : Object
		
		$headers:={}
		$headers["Content-Type"]:="message/rfc822"
		If (($inHeader#Null) && (Value type($inHeader)=Is object))
			var $keys : Collection
			var $key : Text
			$keys:=OB Keys($inHeader)
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $inMail)
		This._internals._response:=OB Copy($response)
	Else 
		Super._throwError(1)
	End if 
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
	var $headers; $response : Object
	var $requestBody : Text
	
	$headers:={}
	$headers["Content-Type"]:="application/json"
	
	Case of 
		: (Value type($inMail)=Is BLOB)
			$requestBody:=Convert to text($inMail; "UTF-8")
			
		: (Value type($inMail)=Is object)
			$requestBody:=MAIL Convert to MIME($inMail)
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE($requestBody)
	
	$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; {raw: $requestBody})
	This._internals._response:=OB Copy($response)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; \
$inURL : Text; \
$inMail : Variant; \
$inHeader : Object) : Object
	
	var $status : Object
	
	Super._throwErrors(False)
	
	Case of 
		: ((This.mailType="MIME") && (\
			(Value type($inMail)=Is text) || \
			(Value type($inMail)=Is BLOB)))
			$status:=This._postMailMIMEMessage($inURL; $inMail)
			
		: ((This.mailType="JMAP") && (Value type($inMail)=Is object))
			$status:=This._postMailMIMEMessage($inURL; $inMail)
			
		Else 
			Super._throwError(10; {which: 1; function: $inFunction})
			$status:=This._returnStatus()
			
	End case 
	
	Super._throwErrors(True)
	
	return $status
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	var $URL; $userId : Text
	
	$URL:=Super._getURL()
	$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/send"
	
	return This._postMessage("send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function getLabelList() : Object
	
	var $URL; $userId : Text
	var $response : Object
	
	$URL:=Super._getURL()
	$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/labels"
	
	$response:=Super._sendRequestAndWaitResponse("GET"; $URL)
	
	return This._returnStatus(OB Copy($response))
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text; $permanently : Boolean) : Object
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailId)#Is text)
			Super._throwError(10; {which: "\"mailId\""; function: "delete"})
			
		: (Length(String($inMailId))=0)
			Super._throwError(9; {which: "\"mailId\""; function: "delete"})
			
		Else 
			
			var $URL; $verb; $userId : Text
			var $response : Object
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId
			If (Not(Bool($permanently)))
				$URL+="/trash"
			End if 
			$verb:=Bool($permanently) ? "DELETE" : "POST"
			
			$response:=Super._sendRequestAndWaitResponse($verb; $URL)
			This._internals._response:=OB Copy($response)
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
			
			var $URL; $userId : Text
			var $response : Object
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId+"/untrash"
			
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL)
			This._internals._response:=OB Copy($response)
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMailIds($inParameters : Object) : Object
	
	var $URL; $userId; $urlParams : Text
	
	$URL:=Super._getURL()
	$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
	$urlParams+="users/"+$userId+"/messages"+This._getURLParamsFromObject($inParameters)
	
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
			
			var $URL; $userId; $urlParams; $mailType; $format : Text
			var $result; $parameters : Object
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$mailType:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
			$format:=String($inParameters.format)
			$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
			$parameters:=(($inParameters#Null) && (Value type($inParameters)=Is object)) ? $inParameters : {format: $format}
			If ($parameters.format#$format)
				$parameters.format:=$format
			End if 
			$urlParams+="users/"+$userId+"/messages/"+String($inMailId)+This._getURLParamsFromObject($parameters)
			
			$result:=Super._sendRequestAndWaitResponse("GET"; $URL+$urlParams)
			$response:=This._extractRawMessage($result; $format; $mailType)
			
	End case 
	
	Super._throwErrors(True)
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function getMails($inMailIds : Collection; $inParameters : Object) : Collection
	
	Super._throwErrors(False)
	
	Case of 
		: (Type($inMailIds)#Is collection)
			Super._throwError(10; {which: "\"mailIds\""; function: "getMails"})
			
		: (Num($inMailIds.length)=0)
			Super._throwError(9; {which: "\"mailIds\""; function: "getMails"})
			
		Else 
			
			var $result : Collection:=Null
			
			If ($inMailIds.length=1)
				
				var $response : Variant:=This.getMail($inMailIds[0]; $inParameters)
				If ($response#Null)
					$result:=New collection($response)
				End if 
				
			Else 
				
				var $URL; $urlParams; $userId; $mailType; $mailId; $format : Text
				var $mailIds : Collection:=(Value type($inMailIds)=Is collection) ? $inMailIds : []
				var $parameters : Object
				
				If (($mailIds.length>0) && (Value type($mailIds[0])=Is object))
					$mailIds:=$mailIds.extract("id")
				End if 
				
				$URL:=Super._getURL()
				$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
				$mailType:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
				$format:=String($inParameters.format)
				$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
				$parameters:=(($inParameters#Null) && (Value type($inParameters)=Is object)) ? $inParameters : {format: $format}
				If ($parameters.format#$format)
					$parameters.format:=$format
				End if 
				
				var $i : Integer:=1
				var $batchRequestes : Collection:=[]
				
				For each ($mailId; $mailIds)
					var $item : Text:="<item"+String($i)+">"
					$i+=1
					$urlParams:="users/"+$userId+"/messages/"+$mailId+This._getURLParamsFromObject($parameters)
					$batchRequestes.push({request: {verb: "GET"; URL: $URL+$urlParams; id: $item}})
				End for each 
				
				var $batchParams : Object:={batchRequestes: $batchRequestes; mailType: $mailType; format: $format}
				var $batchRequest : cs._GoogleBatchRequest:=cs._GoogleBatchRequest.new(This._getOAuth2Provider(); $batchParams)
				$result:=$batchRequest.sendRequestAndWaitResponse()
				
			End if 
			
	End case 
	
	Super._throwErrors(True)
	
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
			
			var $URL; $userId : Text
			var $response : Object
			var $headers : Object:={}
			var $body : Object:={}
			var $mailIds : Collection:=(Value type($inMailIds)=Is collection) ? $inMailIds : []
			
			If (($mailIds.length>0) && (Value type($mailIds[0])=Is object))
				$mailIds:=$mailIds.extract("id")
			End if 
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/batchModify"
			
			$body.ids:=$mailIds
			$body.addLabelIds:=(Value type($inParameters.addLabelIds)=Is collection) ? $inParameters.addLabelIds : []
			$body.removeLabelIds:=(Value type($inParameters.removeLabelIds)=Is collection) ? $inParameters.removeLabelIds : []
			
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $body)
			This._internals._response:=OB Copy($response)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
