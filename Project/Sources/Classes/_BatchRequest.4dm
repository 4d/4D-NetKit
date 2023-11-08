Class extends _BaseAPI

property verb : Text
property URL : Text
property headers : Object
property batchRequestes : Collection
property _boundary : Text
property _body : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParam : Object)
	
	Super($inProvider)
	
	This.verb:=(OB Is defined($inParam; "verb")) ? String($inParam.verb) : "GET"
	This.URL:=(OB Is defined($inParam; "URL")) ? String($inParam.URL) : ""
	This.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	This.batchRequestes:=(Value type($inParam.batchRequestes)=Is collection) ? $inParam.batchRequestes : []
	
	This._boundary:=(OB Is defined($inParam; "boundary")) ? String($inParam.boundary) : "batch"
	This.headers["Content-Type"]:="multipart/mixed; boundary="+This.boundary
	
	This._body:=""
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get boundary() : Text
	
	return This._boundary
	
	
	// ----------------------------------------------------
	
	
Function get body() : Text
	
	If (Length(This._body)=0)
		This._body:=This.generateBody()
	End if 
	
	return This._body
	
	
	// ----------------------------------------------------
	
	
Function generateBody() : Text
	
	var $body : Text:=""
	
	If (This.batchRequestes.length>0)
		
		var $batchRequest : Object
		For each ($batchRequest; This.batchRequestes)
			
			$body+="--"+This._boundary+"\r\n"
			$body+="Content-Type: application/http\r\n"
			$body+="Content-ID: "+String($batchRequest.request.id)+"\r\n\r\n"
			
			$body+=String($batchRequest.request.verb)+" "+String($batchRequest.request.URL)+" HTTP/1.1\r\n"
			
			var $header : Object
			For each ($header; $batchRequest.headers)
				$body+=String($header.name)+": "+String($header.value)+"\r\n"
			End for each 
			$body+="\r\n"
			If (Length(String($batchRequest.request.body))>0)
				$body+=String($batchRequest.request.body)+"\r\n"
			End if 
			$body+="\r\n"
		End for each 
		
		$body+="--"+This._boundary+"--\r\n"
	End if 
	
	return $body
	
	
	// ----------------------------------------------------
	
	
Function sendRequestAndWaitResponse() : Object
	
	var $result : Object:={}
	var $response : Blob:=This._sendRequestAndWaitResponse(This.verb; This.URL; This.headers; This._body)
	
	If ($response#Null)
		$result:=Parse HTTP message($response)
	End if 
	
	return $result
