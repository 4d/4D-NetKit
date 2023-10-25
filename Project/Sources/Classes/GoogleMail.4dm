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
	
	
	// ----------------------------------------------------
	
	
Function _convertMailObjectToJMAP($inMail : Object) : Object
	
	var $result : Object
	var $keys : Collection
	var $key; $name; $string : Text
	var $email : cs.EmailAddress
	
	$result:={}
	$keys:=OB Keys($inMail)
	For each ($key; $keys)
		$name:=_getJMAPAttribute($key)
		If (Length($name)>0)
			If ($key="labelIds")
				If (Num($inMail.labelIds.length)>0)
					$string:=$inMail.labelIds.join("=true,"; ck ignore null or empty)+"=true"
					$result[$name]:=Split string($string; ","; sk trim spaces)
				End if 
			Else 
				$result[$name]:=$inMail[$key]
			End if 
		End if 
	End for each 
	
	If (OB Is defined($inMail; "payload"))
		$keys:=OB Keys($inMail.payload)
		For each ($key; $keys)
			If ($key="headers")
				var $header : Object
				For each ($header; $inMail.payload.headers)
					$name:=_getJMAPAttribute($header.name)
					If (Length($name)>0)
						Case of 
							: ($header.name="Keywords")
								If (Length($header.value)>0)
									$string:=$header.value.join("=true,"; ck ignore null or empty)+"=true"
									$result[$name]:=Split string($string; ","; sk trim spaces)
								End if 
							: (_IsEmailAddressHeader($header.name))
								If (Length($header.value)>0)
									$email:=cs.EmailAddress.new($header.value)
									$result[$name]:=OB Copy($email)
								End if 
							Else 
								$result[$name]:=$header.value
						End case 
					End if 
				End for each 
			End if 
		End for each 
	End if 
	
	return $result
	
	
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
			var $result : Object
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$mailType:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
			$format:=String($inParameters.format)
			$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
			
			$urlParams+="users/"+$userId+"/messages/"+String($inMailId)+This._getURLParamsFromObject($inParameters)
			
			$result:=Super._sendRequestAndWaitResponse("GET"; $URL+$urlParams)
			
			If ($result#Null)
				
				var $rawMessage : Text
				
				Case of 
					: (($format="raw") && (($mailType="MIME") || ($mailType="JMAP")))
						If (Value type($result.raw)=Is text)
							
							$rawMessage:=_base64UrlSafeDecode($result.raw)
							If ($mailType="JMAP")
								
								var $copy : Object
								
								$copy:=OB Copy($result)
								$response:=MAIL Convert from MIME($rawMessage)
								$response.id:=String($copy.id)
								$response.threadId:=String($copy.threadId)
								$response.labelIds:=OB Is defined($copy; "labelIds") ? $copy.labelIds : []
							Else 
								
								$response:=(Length($rawMessage)>0) ? $rawMessage : $result.raw
							End if 
						End if 
						
					: (($format="minimal") || ($format="metadata"))
						$response:=This._convertMailObjectToJMAP($result)
						
					Else 
						Super._throwError(10; {which: 1; function: "getMail"})
						
				End case 
				
			End if 
			
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
			
			var $result : Collection:=[]
			var $response : Variant
			
			If ($inMailIds.length=1)
				
				$response:=This.getMail($inMailIds[0]; $inParameters)
				$result.push($response)
				
			Else 
				
				// TODO use cs._batchRequest Object
				ASSERT(False; "Unimplemented")
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
			var $mailIds : Collection:=(Type($inMailIds[0])=Is object) ? $inMailIds.extract("id") : $inMailIds
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/messages/batchModify"
			
			$body.ids:=$mailIds
			$body.addLabelIds:=(Type($inParameters.addLabelIds)=Is collection) ? $inParameters.addLabelIds : []
			$body.removeLabelIds:=(Type($inParameters.removeLabelIds)=Is collection) ? $inParameters.removeLabelIds : []
			
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $body)
			This._internals._response:=OB Copy($response)
			
	End case 
	
	Super._throwErrors(True)
	
	return This._returnStatus()
	
	
	// Mark: - Labels
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
	
	
Function getLabel($inLabelId : Text) : Object
	
	Case of 
		: (Type($inLabelId)#Is text)
			Super._throwError(10; {which: "\"labelId\""; function: "getLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "getLabel"})
			
		Else 
			
			var $URL; $userId : Text
			var $response : Object
			
			Super._throwErrors(False)
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels"+$inLabelId
			
			$response:=Super._sendRequestAndWaitResponse("GET"; $URL)
			This._internals._response:=OB Copy($response)
			
			Super._throwErrors(True)
			
			return OB Copy($response)
			
	End case 
	
	return Null
	
	
	// ----------------------------------------------------
	
	
Function createLabel($inLabelInfo : Object) : Object
	
	Case of 
		: (Type($inLabelInfo)#Is object)
			Super._throwError(10; {which: "\"labelInfo\""; function: "createLabel"})
			
		: (OB Is empty($inLabelInfo))
			Super._throwError(9; {which: "\"labelInfo\""; function: "createLabel"})
			
		Else 
			
			var $URL; $userId : Text
			var $response : Object
			var $headers : Object:={}
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels"
			
			$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $inLabelInfo)
			This._internals._response:=OB Copy($response)
			
	End case 
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function deleteLabel($inLabelId : Text) : Object
	
	Case of 
		: (Type($inLabelId)#Is text)
			Super._throwError(10; {which: "\"labelId\""; function: "deleteLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "deleteLabel"})
			
		Else 
			
			var $URL; $userId : Text
			var $response : Object
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels"+$inLabelId
			
			$response:=Super._sendRequestAndWaitResponse("DELETE"; $URL)
			This._internals._response:=OB Copy($response)
			
	End case 
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function updateLabel($inLabelId : Text; $inLabelInfo : Object) : Object
	
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
			
			var $URL; $userId : Text
			var $response : Object
			var $headers : Object:={}
			
			$URL:=Super._getURL()
			$userId:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels"+$inLabelId
			
			$response:=Super._sendRequestAndWaitResponse("PUT"; $URL; $headers; $inLabelInfo)
			This._internals._response:=OB Copy($response)
			
	End case 
	
	return This._returnStatus()
