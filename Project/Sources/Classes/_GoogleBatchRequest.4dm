Class extends _GoogleAPI

property verb : Text
property URL : Text
property headers : Object
property boundary : Text
property mailType : Text
property format : Text
property maxItemNumber : Integer:=100  // Google API cannot accept more than 100 batch requests
property _requestes : Collection
property _itemNumber : Integer:=0


Class constructor($inProvider : cs.OAuth2Provider; $inParam : Object)
	
	Super($inProvider)
	
	This.URL:="https://gmail.googleapis.com/batch/gmail/v1/"
	This.verb:=(OB Is defined($inParam; "verb")) ? String($inParam.verb) : "POST"
	This.boundary:=(OB Is defined($inParam; "boundary")) ? String($inParam.boundary) : "batch_"+Generate UUID
	This.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	This.headers["Content-Type"]:="multipart/mixed; boundary="+This.boundary

	This._requestes:=[]
	
	If (OB Is defined($inParam; "mailType"))
		// for Messages can be: "MIME" or "JMAP"
		This.mailType:=String($inParam.mailType)
	End if 
	If (OB Is defined($inParam; "format"))
		// for Messages can be: "minimal", "metadata" or "raw"
		// for Labels (and other incomming data) can be: "JSON"
		This.format:=String($inParam.format)
	End if 
	If (OB Is defined($inParam; "maxItemNumber"))
		This.maxItemNumber:=Num($inParam.maxItemNumber)
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function appendRequest($inParam : Object)
	
	var $request : Object:={}
	This._itemNumber+=1
	$request.id:="<item"+String(This._itemNumber)+">"
	$request.verb:=(Length(String($inParam.verb))>0) ? String($inParam.verb) : "GET"
	$request.URL:=String($inParam.URL)
	$request.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	$request.body:=(Value type($inParam.body)=Is text) ? $inParam.body : ""
	
	This._requestes.push({request: $request})
	
	
	// ----------------------------------------------------
	
	
Function sendRequestAndWaitResponse() : Collection
	
	var $collection : Collection:=[]
	var $startIndex : Integer:=0
	var $endIndex : Integer:=$startIndex+((This._requestes.length<=This.maxItemNumber) ? This._requestes.length : This.maxItemNumber)
	var $requests : Collection:=This._requestes.slice($startIndex; $endIndex)
	
	While ($requests.length>0)
		
		var $body : Text:=This._generateBody(This.boundary; $requests)
		var $response : Text:=This._sendRequestAndWaitResponse(This.verb; This.URL; This.headers; $body)
		
		If (Length($response)>0)
			
			var $message : Object:=HTTP Parse message($response)
			var $part; $subPart : Object
			
			For each ($part; $message.parts)
				
				$part:=HTTP Parse message(String($part.content))
				For each ($subPart; $part.parts)
					
					var $result : Variant:=Null
					If ($subPart.contentType="application/json")
						If (This.format="JSON")
							$result:=Try(JSON Parse($subPart.content))
						Else 
							$result:=This._extractRawMessage(Try(JSON Parse($subPart.content)); This.format; This.mailType)
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
		
		$startIndex+=$requests.length
		$endIndex:=$startIndex+(((This._requestes.length-$startIndex)<=This.maxItemNumber) ? (This._requestes.length-$startIndex) : This.maxItemNumber)
		$requests:=This._requestes.slice($startIndex; $endIndex)
		
	End while 
	
	return (Num($collection.length)>0) ? $collection : Null
	
	
	// ----------------------------------------------------
	
	
Function _generateBody($inBoundary : Text; $inRequests : Collection) : Text
	
	var $body : Text:=""
	
	If ($inRequests.length>0)
		
		var $request : Object
		For each ($request; $inRequests)
			
			$body+="--"+$inBoundary+"\r\n"
			$body+="Content-Type: application/http\r\n"
			$body+="Content-ID: "+String($request.request.id)+"\r\n\r\n"
			
			$body+=String($request.request.verb)+" "+String($request.request.URL)+" HTTP/1.1\r\n"
			
			If (Num($request.headers.length)>0)
				var $header : Object
				For each ($header; $request.headers)
					$body+=String($header.name)+": "+String($header.value)+"\r\n"
				End for each 
			End if 
			$body+="\r\n"
			If (Length(String($request.request.body))>0)
				$body+=String($request.request.body)+"\r\n"
			End if 
			$body+="\r\n"
		End for each 
		
		$body+="--"+$inBoundary+"--\r\n"
		
	End if 
	
	return $body
