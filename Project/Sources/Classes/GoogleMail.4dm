Class extends _GoogleAPI

property mailType : Text
property userId : Text

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "JMAP"
	This:C1470.userId:=String:C10($inParameters.userId)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _postJSONMessage($inURL : Text; \
$inMail : Object; \
$inHeader : Object) : Object
	
	If ($inMail#Null:C1517)
		var $headers; $message; $messageCopy; $response : Object
		
		$headers:={}
		$headers["Content-Type"]:="message/rfc822"
		If (($inHeader#Null:C1517) && (Value type:C1509($inHeader)=Is object:K8:27))
			var $keys : Collection
			var $key : Text
			$keys:=OB Keys:C1719($inHeader)
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		$response:=Super:C1706._sendRequestAndWaitResponse("POST"; $inURL; $headers; $inMail)
		This:C1470._internals._response:=OB Copy:C1225($response)
	Else 
		Super:C1706._throwError(1)
	End if 
	
	return This:C1470._returnStatus((Length:C16(String:C10($response.id))>0) ? {id: $response.id} : Null:C1517)
	
	
	// ----------------------------------------------------
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
	var $headers; $response : Object
	var $requestBody : Text
	
	$headers:={}
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
	
	$response:=Super:C1706._sendRequestAndWaitResponse("POST"; $inURL; $headers; {raw: $requestBody})
	This:C1470._internals._response:=OB Copy:C1225($response)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; \
$inURL : Text; \
$inMail : Variant; \
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
			
		Else 
			Super:C1706._throwError(10; {which: 1; function: $inFunction})
			$status:=This:C1470._returnStatus()
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return $status
	
	
	// ----------------------------------------------------
	
	
Function _convertMailObjectToJMAP($inMail : Object) : Object
	
	var $result : Object
	var $keys : Collection
	var $key; $name; $string : Text
	var $email : cs:C1710.EmailAddress
	
	$result:={}
	$keys:=OB Keys:C1719($inMail)
	For each ($key; $keys)
		$name:=_getJMAPAttribute($key)
		If (Length:C16($name)>0)
			If ($key="labelIds")
				If (Num:C11($inMail.labelIds.length)>0)
					$string:=$inMail.labelIds.join("=true,"; ck ignore null or empty:K85:5)+"=true"
					$result[$name]:=Split string:C1554($string; ","; sk trim spaces:K86:2)
				End if 
			Else 
				$result[$name]:=$inMail[$key]
			End if 
		End if 
	End for each 
	
	If (OB Is defined:C1231($inMail; "payload"))
		$keys:=OB Keys:C1719($inMail.payload)
		For each ($key; $keys)
			If ($key="headers")
				var $header : Object
				For each ($header; $inMail.payload.headers)
					$name:=_getJMAPAttribute($header.name)
					If (Length:C16($name)>0)
						Case of 
							: ($header.name="Keywords")
								If (Length:C16($header.value)>0)
									$string:=$header.value.join("=true,"; ck ignore null or empty:K85:5)+"=true"
									$result[$name]:=Split string:C1554($string; ","; sk trim spaces:K86:2)
								End if 
							: (_IsEmailAddressHeader($header.name))
								If (Length:C16($header.value)>0)
									$email:=cs:C1710.EmailAddress.new($header.value)
									$result[$name]:=OB Copy:C1225($email)
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
	
	$URL:=Super:C1706._getURL()
	$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
	$URL+="users/"+$userId+"/messages/send"
	
	return This:C1470._postMessage("send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function getLabelList() : Object
	
	var $URL; $userId : Text
	var $response : Object
	
	$URL:=Super:C1706._getURL()
	$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
	$URL+="users/"+$userId+"/labels"
	
	$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
	
	return This:C1470._returnStatus(OB Copy:C1225($response))
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text; $permanently : Boolean) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._throwError(10; {which: "\"mailId\""; function: "delete"})
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._throwError(9; {which: "\"mailId\""; function: "delete"})
			
		Else 
			
			var $URL; $verb; $userId : Text
			var $response : Object
			
			$URL:=Super:C1706._getURL()
			$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId
			If (Not:C34(Bool:C1537($permanently)))
				$URL+="/trash"
			End if 
			$verb:=Bool:C1537($permanently) ? "DELETE" : "POST"
			
			$response:=Super:C1706._sendRequestAndWaitResponse($verb; $URL)
			This:C1470._internals._response:=OB Copy:C1225($response)
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function untrash($inMailId : Text) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._throwError(10; {which: "\"mailId\""; function: "untrash"})
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._throwError(9; {which: "\"mailId\""; function: "untrash"})
			
		Else 
			
			var $URL; $userId : Text
			var $response : Object
			
			$URL:=Super:C1706._getURL()
			$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
			$URL+="users/"+$userId+"/messages/"+$inMailId+"/untrash"
			
			$response:=Super:C1706._sendRequestAndWaitResponse("POST"; $URL)
			This:C1470._internals._response:=OB Copy:C1225($response)
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMailIds($inParameters : Object) : Object
	
	var $URL; $userId; $urlParams : Text
	
	$URL:=Super:C1706._getURL()
	$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
	$urlParams+="users/"+$userId+"/messages"+This:C1470._getURLParamsFromObject($inParameters)
	
	return cs:C1710.GoogleMailIdList.new(This:C1470._getOAuth2Provider(); $URL+$urlParams)
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text; $inParameters : Object)->$response : Variant
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailId)#Is text:K8:3)
			Super:C1706._throwError(10; {which: "\"mailId\""; function: "getMail"})
			
		: (Length:C16(String:C10($inMailId))=0)
			Super:C1706._throwError(9; {which: "\"mailId\""; function: "getMail"})
			
		Else 
			
			var $URL; $userId; $urlParams; $mailType; $format : Text
			var $result : Object
			
			$URL:=Super:C1706._getURL()
			$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
			$mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? $inParameters.mailType : This:C1470.mailType
			$format:=String:C10($inParameters.format)
			$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
			
			$urlParams+="users/"+$userId+"/messages/"+String:C10($inMailId)+This:C1470._getURLParamsFromObject($inParameters)
			
			$result:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL+$urlParams)
			
			If ($result#Null:C1517)
				
				var $rawMessage : Text
				
				Case of 
					: (($format="raw") && (($mailType="MIME") || ($mailType="JMAP")))
						If (Value type:C1509($result.raw)=Is text:K8:3)
							
							$rawMessage:=_base64UrlSafeDecode($result.raw)
							If ($mailType="JMAP")
								
								var $copy : Object
								
								$copy:=OB Copy:C1225($result)
								$response:=MAIL Convert from MIME:C1681($rawMessage)
								$response.id:=String:C10($copy.id)
								$response.threadId:=String:C10($copy.threadId)
								$response.labelIds:=OB Is defined:C1231($copy; "labelIds") ? $copy.labelIds : []
							Else 
								
								$response:=(Length:C16($rawMessage)>0) ? $rawMessage : $result.raw
							End if 
						End if 
						
					: (($format="minimal") || ($format="metadata"))
						$response:=This:C1470._convertMailObjectToJMAP($result)
						
					Else 
						Super:C1706._throwError(10; {which: 1; function: "getMail"})
						
				End case 
				
			End if 
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function getMails($inMailIds : Collection; $inParameters : Object) : Collection
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailIds)#Is collection:K8:32)
			Super:C1706._throwError(10; {which: "\"mailIds\""; function: "getMails"})
			
		: (Num:C11($inMailIds.length)=0)
			Super:C1706._throwError(9; {which: "\"mailIds\""; function: "getMails"})
			
		Else 
			
			var $result : Collection:=[]
			var $response : Variant
			
			If ($inMailIds.length=1)
				
				$response:=This:C1470.getMail($inMailIds[0]; $inParameters)
				$result.push($response)
				
			Else 
				
				// TODO use cs._batchRequest Object
				ASSERT:C1129(False:C215; "Unimplemented")
			End if 
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function update($inMailIds : Collection; $inParameters : Object) : Object
	
	Super:C1706._throwErrors(False:C215)
	
	Case of 
		: (Type:C295($inMailIds)#Is collection:K8:32)
			Super:C1706._throwError(10; {which: "\"mailIds\""; function: "update"})
			
		: (Num:C11($inMailIds.length)=0)
			Super:C1706._throwError(9; {which: "\"mailIds\""; function: "update"})
			
		: (Num:C11($inMailIds.length)>1000)
			Super:C1706._throwError(13; {which: "\"mailIds\""; function: "update"; max: 1000})
			
		: (Type:C295($inParameters)#Is object:K8:27)
			Super:C1706._throwError(10; {which: "\"parameters\""; function: "update"})
			
		Else 
			
			var $URL; $userId : Text
			var $response : Object
			var $headers : Object:={}
			var $body : Object:={}
			var $mailIds : Collection:=(Value type($inMailIds[0])=Is object:K8:27 && OB Is defined($inMailIds[0]; "id")) ? $inMailIds.extract("id") : $inMailIds
			
			$URL:=Super:C1706._getURL()
			$userId:=(Length:C16(String:C10(This:C1470.userId))>0) ? This:C1470.userId : "me"
			$URL+="users/"+$userId+"/messages/batchModify"
			
			$body.ids:=$mailIds
			$body.addLabelIds:=(Value type:C1509($inParameters.addLabelIds)=Is collection:K8:32) ? $inParameters.addLabelIds : []
			$body.removeLabelIds:=(Value type:C1509($inParameters.removeLabelIds)=Is collection:K8:32) ? $inParameters.removeLabelIds : []
			
			$response:=Super:C1706._sendRequestAndWaitResponse("POST"; $URL; $headers; $body)
			This:C1470._internals._response:=OB Copy:C1225($response)
			
	End case 
	
	Super:C1706._throwErrors(True:C214)
	
	return This:C1470._returnStatus()
	