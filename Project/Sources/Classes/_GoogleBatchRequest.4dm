Class extends _GoogleAPI

property verb : Text
property URL : Text
property headers : Object
property batchRequestes : Collection
property _boundary : Text
property _body : Text
property _mailType : Text
property _format : Text


Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParam : Object)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._URL:="https://gmail.googleapis.com/batch/gmail/v1/"
	
	This:C1470.verb:=(OB Is defined:C1231($inParam; "verb")) ? String:C10($inParam.verb) : "POST"
	This:C1470.headers:=(Value type:C1509($inParam.headers)=Is object:K8:27) ? $inParam.headers : {}
	This:C1470.batchRequestes:=(Value type:C1509($inParam.batchRequestes)=Is collection:K8:32) ? $inParam.batchRequestes : []
	
	This:C1470._boundary:=(OB Is defined:C1231($inParam; "boundary")) ? String:C10($inParam.boundary) : "batch_"+Generate UUID:C1066
	This:C1470.headers["Content-Type"]:="multipart/mixed; boundary="+This:C1470.boundary
	
	This:C1470._body:=""
	This:C1470._mailType:=(OB Is defined:C1231($inParam; "mailType")) ? String:C10($inParam.mailType) : "MIME"
	This:C1470._format:=(OB Is defined:C1231($inParam; "format")) ? String:C10($inParam.format) : "raw"
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get boundary() : Text
	
	return This:C1470._boundary
	
	
	// ----------------------------------------------------
	
	
Function get body() : Text
	
	If (Length:C16(This:C1470._body)=0)
		This:C1470._body:=This:C1470.generateBody()
	End if 
	
	return This:C1470._body
	
	
	// ----------------------------------------------------
	
	
Function generateBody() : Text
	
	var $body : Text:=""
	
	If (This:C1470.batchRequestes.length>0)
		
		var $batchRequest : Object
		For each ($batchRequest; This:C1470.batchRequestes)
			
			$body+="--"+This:C1470._boundary+"\r\n"
			$body+="Content-Type: application/http\r\n"
			$body+="Content-ID: "+String:C10($batchRequest.request.id)+"\r\n\r\n"
			
			$body+=String:C10($batchRequest.request.verb)+" "+String:C10($batchRequest.request.URL)+" HTTP/1.1\r\n"
			
			var $header : Object
			For each ($header; $batchRequest.headers)
				$body+=String:C10($header.name)+": "+String:C10($header.value)+"\r\n"
			End for each 
			$body+="\r\n"
			If (Length:C16(String:C10($batchRequest.request.body))>0)
				$body+=String:C10($batchRequest.request.body)+"\r\n"
			End if 
			$body+="\r\n"
		End for each 
		
		$body+="--"+This:C1470._boundary+"--\r\n"
	End if 
	
	return $body
	
	
	// ----------------------------------------------------
	
	
Function sendRequestAndWaitResponse() : Collection
	
	var $collection : Collection
	var $verb:=This:C1470.verb
	var $URL : Text:=This:C1470._internals._URL
	var $body : Text:=This:C1470.body
	var $headers : Object:=This:C1470.headers
	var $response : Text:=This:C1470._sendRequestAndWaitResponse($verb; $URL; $headers; $body)
	
	If (Length:C16($response)>0)
		
		var $message : Object:=HTTP Parse message:C1824($response)
		var $part; $subPart : Object
		
		$collection:=[]
		For each ($part; $message.parts)
			
			$part:=HTTP Parse message:C1824(String:C10($part.content))
			For each ($subPart; $part.parts)
				
				var $result : Variant:=Null:C1517
				If ($subPart.contentType="application/json")
					$result:=This:C1470._extractRawMessage(JSON Parse:C1218($subPart.content); This:C1470._format; This:C1470._mailType)
				Else 
					$result:=4D:C1709.Blob.new($subPart.content)
				End if 
				
				If ($result#Null:C1517)
					$collection.push($result)
				End if 
			End for each 
		End for each 
		
	End if 
	
	return ($collection.length>0) ? $collection : Null:C1517
	