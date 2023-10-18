Class extends _BaseAPI

property verb : Text
property URL : Text
property headers : Object
property batchRequestes : Collection
property _boundary : Text
property _body : Text

Class constructor($inParam : Object)
	
	This:C1470.verb:=(OB Is defined:C1231($inParam; "verb")) ? String:C10($inParam.verb) : "GET"
	This:C1470.URL:=(OB Is defined:C1231($inParam; "URL")) ? String:C10($inParam.URL) : ""
	This:C1470.headers:=(Value type:C1509($inParam.headers)=Is collection:K8:32) ? $inParam.headers : []
	This:C1470.batchRequestes:=(Value type:C1509($inParam.batchRequestes)=Is collection:K8:32) ? $inParam.batchRequestes : []
	
	This:C1470._boundary:=(OB Is defined:C1231($inParam; "boundary")) ? String:C10($inParam.boundary) : "batch"
	This:C1470._body:=""
	
	
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
			$body+="Content-ID: "+String:C10($batchRequest.id)+"\r\n\r\n"
			
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
	
	
Function sendRequestAndWaitResponse() : Object
	
	var $result : Object:={}
	var $response : Blob:=This:C1470._sendRequestAndWaitResponse(This:C1470.verb; This:C1470.URL; This:C1470.headers; This:C1470._body)
	
	If ($response#Null:C1517)
		$result:=Parse HTTP message:C1824($response)
	End if 
	
	return $result
	