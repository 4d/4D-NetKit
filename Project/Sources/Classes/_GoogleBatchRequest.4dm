Class extends _GoogleAPI

property verb : Text
property URL : Text
property headers : Object
property _requestes : Collection
property _boundary : Text
property _body : Text
property _mailType : Text
property _format : Text
property _itemNumber : Integer:=1


Class constructor($inProvider : cs.OAuth2Provider; $inParam : Object)
	
	Super($inProvider)
	
	This._internals._URL:="https://gmail.googleapis.com/batch/gmail/v1/"
	
	This.verb:=(OB Is defined($inParam; "verb")) ? String($inParam.verb) : "POST"
	This.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	This._requestes:=[]
	
	This._boundary:=(OB Is defined($inParam; "boundary")) ? String($inParam.boundary) : "batch_"+Generate UUID
	This.headers["Content-Type"]:="multipart/mixed; boundary="+This.boundary
	
	This._body:=""
	If (OB Is defined($inParam; "mailType"))
		// for Messages can be: "MIME" or "JMAP"
		This._mailType:=String($inParam.mailType)
	End if 
	If (OB Is defined($inParam; "format"))
		// for Messages can be: "minimal", "metadata" or "raw"
		// for Labels (and other incomming data) can be: "JSON"
		This._format:=String($inParam.format)
	End if 
	
	
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
	
	
Function appendRequest($inParam : Object)
	
	var $request : Object:={}
	$request.id:="<item"+String(This._itemNumber)+">"
	$request.verb:=(Length(String($inParam.verb))>0) ? String($inParam.verb) : "GET"
	$request.URL:=String($inParam.URL)
	$request.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	$request.body:=(Value type($inParam.body)=Is text) ? $inParam.body : ""
	
	This._requestes.push({request: $request})
	This._itemNumber+=1
	
	
	// ----------------------------------------------------
	
	
Function generateBody() : Text
	
	var $body : Text:=""
	
	If (This._requestes.length>0)
		
		var $batchRequest : Object
		For each ($batchRequest; This._requestes)
			
			$body+="--"+This._boundary+"\r\n"
			$body+="Content-Type: application/http\r\n"
			$body+="Content-ID: "+String($batchRequest.request.id)+"\r\n\r\n"
			
			$body+=String($batchRequest.request.verb)+" "+String($batchRequest.request.URL)+" HTTP/1.1\r\n"
			
			If (Num($batchRequest.headers.length)>0)
				var $header : Object
				For each ($header; $batchRequest.headers)
					$body+=String($header.name)+": "+String($header.value)+"\r\n"
				End for each 
			End if 
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
	
	var $collection : Collection
	var $verb : Text:=This.verb
	var $URL : Text:=This._internals._URL
	var $body : Text:=This.body
	var $headers : Object:=This.headers
	var $response : Text:=This._sendRequestAndWaitResponse($verb; $URL; $headers; $body)
	
	If (Length($response)>0)
		
		var $message : Object:=HTTP Parse message($response)
		var $part; $subPart : Object
		
		$collection:=[]
		For each ($part; $message.parts)
			
			$part:=HTTP Parse message(String($part.content))
			For each ($subPart; $part.parts)
				
				var $result : Variant:=Null
				If ($subPart.contentType="application/json")
					If (This._format="JSON")
						$result:=Try(JSON Parse($subPart.content))
					Else 
						$result:=This._extractRawMessage(Try(JSON Parse($subPart.content)); This._format; This._mailType)
					End if 
				Else 
					$result:=4D.Blob.new($subPart.content)
				End if 
				
				If ($result#Null)
					$collection.push($result)
				End if 
			End for each 
		End for each 
		
	End if 
	
	return (Num($collection.length)>0) ? $collection : Null
