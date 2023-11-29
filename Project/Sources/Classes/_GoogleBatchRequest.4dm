Class extends _GoogleAPI

property verb : Text
property URL : Text
property headers : Object
property batchRequestes : Collection
property _boundary : Text
property _body : Text
property _mailType : Text
property _format : Text


Class constructor($inProvider : cs.OAuth2Provider; $inParam : Object)
	
	Super($inProvider)
	
	This._internals._URL:="https://gmail.googleapis.com/batch/gmail/v1/"
	
	This.verb:=(OB Is defined($inParam; "verb")) ? String($inParam.verb) : "POST"
	This.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	This.batchRequestes:=(Value type($inParam.batchRequestes)=Is collection) ? $inParam.batchRequestes : []
	
	This._boundary:=(OB Is defined($inParam; "boundary")) ? String($inParam.boundary) : "batch_"+Generate UUID
	This.headers["Content-Type"]:="multipart/mixed; boundary="+This.boundary
	
	This._body:=""
	This._mailType:=(OB Is defined($inParam; "mailType")) ? String($inParam.mailType) : "MIME"
	This._format:=(OB Is defined($inParam; "format")) ? String($inParam.format) : "raw"
	
	
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
	
	var $collection : Collection:=Null
	var $verb:=This.verb
	var $URL : Text:=This._internals._URL
	var $body : Text:=This.body
	var $headers : Object:=This.headers
	var $response : Text:=This._sendRequestAndWaitResponse($verb; $URL; $headers; $body)
	
	If (Length($response)>0)
		
		var $message : Object:=Parse HTTP message($response)
		var $part; $subPart : Object
		
		$collection:=[]
		For each ($part; $message.parts)
			
			$part:=Parse HTTP message(String($part.content))
			For each ($subPart; $part.parts)
				
				var $result : Variant:=Null
				If ($subPart.contentType="application/json")
					$result:=This._extractRawMessage(JSON Parse($subPart.content); This._format; This._mailType)
				Else 
					$result:=4D.Blob.new($subPart.content)
				End if 
				
				If ($result#Null)
					$collection.push($result)
				End if 
			End for each 
		End for each 
		
	End if 
	
	return $collection
