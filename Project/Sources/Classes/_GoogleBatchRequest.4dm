Class extends _GoogleAPI

property verb : Text
property URL : Text
property headers : Object
property batchRequestes : Collection
property _boundary : Text
property _body : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParam : Object)
	
	Super($inProvider)
	
	This._internals._URL:="https://gmail.googleapis.com/batch/gmail/v1/"
	
	This.verb:=(OB Is defined($inParam; "verb")) ? String($inParam.verb) : "POST"
	This.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	This.batchRequestes:=(Value type($inParam.batchRequestes)=Is collection) ? $inParam.batchRequestes : []
	
	This._boundary:=(OB Is defined($inParam; "boundary")) ? String($inParam.boundary) : "batch_"+Generate UUID
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
	
	
Function sendRequestAndWaitResponse() : Collection
	
	var $result : Collection:=[]
	var $body : Text:=This.body
	var $response : Text:=This._sendRequestAndWaitResponse(This.verb; This._internals._URL; This.headers; $body)
	
	If (Length($response)>0)
		var $message : Object:=Parse HTTP message($response)
		var $part : Object
		For each ($part; $message.parts)
			$result.push(Parse HTTP message(String($part.content)))
		End for each 
		
	End if 
	
	return $result
