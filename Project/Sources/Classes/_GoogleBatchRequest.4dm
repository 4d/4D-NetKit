/**
 * @class _GoogleBatchRequest
 * @extends _GoogleAPI
 * @description Builds and dispatches a multipart/mixed Gmail Batch API request;
 *   accumulates individual sub-requests via `appendRequest`, then sends them all in
 *   chunks of at most `maxItemNumber` (Google's hard limit of 100 per batch call).
 *   Each chunk is serialised as a MIME multipart body, sent to the batch endpoint,
 *   and the response parts are parsed and converted according to `format` / `mailType`.
 */

Class extends _GoogleAPI

property verb : Text
property URL : Text
property headers : Object
property boundary : Text
property mailType : Text
property format : Text
property maxItemNumber : Integer:=100  // Google API cannot accept more than 100 batch requests
property _requests : Collection
property _itemNumber : Integer:=0


Class constructor($inProvider : cs.OAuth2Provider; $inParam : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Object} $inParam - Configuration object; recognised properties:
 *   - `verb` {Text} — HTTP verb for each sub-request (defaults to `"POST"`)
 *   - `boundary` {Text} — MIME boundary string; auto-generated (`"batch_" + UUID`) if omitted
 *   - `headers` {Object} — Additional headers merged into the outer batch request
 *     (`Content-Type: multipart/mixed; boundary=…` is always set automatically)
 *   - `mailType` {Text} — Output type for message sub-requests: `"MIME"` or `"JMAP"`
 *   - `format` {Text} — Message format: `"minimal"`, `"metadata"`, `"raw"`, or `"JSON"`
 *     (use `"JSON"` for non-mail resources such as labels)
 *   - `maxItemNumber` {Integer} — Override the 100-request-per-batch ceiling
 */
	
	Super($inProvider)
	
	This.URL:="https://gmail.googleapis.com/batch/gmail/v1/"
	This.verb:=(OB Is defined($inParam; "verb")) ? String($inParam.verb) : "POST"
	This.boundary:=(OB Is defined($inParam; "boundary")) ? String($inParam.boundary) : "batch_"+Generate UUID
	This.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	This.headers["Content-Type"]:="multipart/mixed; boundary="+This.boundary
	
	This._requests:=[]
	
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
/**
 * @function appendRequest
 * @param {Object} $inParam - Sub-request descriptor; recognised properties:
 *   - `verb` {Text} — HTTP verb (defaults to `"GET"`)
 *   - `URL` {Text} — Relative or absolute URL of the sub-request
 *   - `headers` {Object} — Headers specific to this sub-request
 *   - `body` {Text} — Optional request body
 * @description Appends one sub-request to the internal queue; assigns a
 *   sequential `Content-ID` (`<item1>`, `<item2>`, …) used to correlate
 *   responses. Call `sendRequestAndWaitResponse` after all sub-requests are queued.
 */
	
	var $request : Object:={}
	This._itemNumber+=1
	$request.id:="<item"+String(This._itemNumber)+">"
	$request.verb:=(Length(String($inParam.verb))>0) ? String($inParam.verb) : "GET"
	$request.URL:=String($inParam.URL)
	$request.headers:=(Value type($inParam.headers)=Is object) ? $inParam.headers : {}
	$request.body:=(Value type($inParam.body)=Is text) ? $inParam.body : ""
	
	This._requests.push({request: $request})
	
	
	// ----------------------------------------------------
	
	
Function sendRequestAndWaitResponse() : Collection
/**
 * @function sendRequestAndWaitResponse
 * @returns {Collection} Flat collection of converted results from all sub-requests,
 *   or `Null` when no results were produced
 * @description Sends all queued sub-requests to the Gmail batch endpoint in chunks of
 *   at most `maxItemNumber` items. Each chunk is serialised as a MIME multipart body,
 *   posted to `https://gmail.googleapis.com/batch/gmail/v1/`, and the multipart response
 *   is parsed recursively: each part is converted via `_extractRawMessage` (or returned
 *   as a raw `4D.Blob` for non-JSON parts) and appended to the result collection.
 * @note This method shares its name with the private `_BaseAPI._sendRequestAndWaitResponse`
 *   but is a distinct public method — it orchestrates chunked batch dispatch whereas the
 *   inherited private method performs a single HTTP call.
 */
	
	var $collection : Collection:=[]
	var $startIndex : Integer:=0
	var $endIndex : Integer:=$startIndex+((This._requests.length<=This.maxItemNumber) ? This._requests.length : This.maxItemNumber)
	var $requests : Collection:=This._requests.slice($startIndex; $endIndex)
	
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
		$endIndex:=$startIndex+(((This._requests.length-$startIndex)<=This.maxItemNumber) ? (This._requests.length-$startIndex) : This.maxItemNumber)
		$requests:=This._requests.slice($startIndex; $endIndex)
		
	End while 
	
	return (Num($collection.length)>0) ? $collection : Null
	
	
	// ----------------------------------------------------
	
	
Function _generateBody($inBoundary : Text; $inRequests : Collection) : Text
/**
 * @function _generateBody
 * @private
 * @param {Text} $inBoundary - MIME boundary string (without `--` prefix)
 * @param {Collection} $inRequests - Slice of queued request objects to serialise
 * @returns {Text} Complete MIME multipart body string ready to send as the HTTP request body
 * @description Formats each sub-request as a `application/http` MIME part separated by
 *   `--<boundary>` markers, including verb, URL, optional headers, and optional body;
 *   terminates with the `--<boundary>--` closing delimiter.
 */
	
	var $body : Text:=""
	
	If ($inRequests.length>0)
		
		var $request : Object
		For each ($request; $inRequests)
			
			$body+="--"+$inBoundary+"\r\n"
			$body+="Content-Type: application/http\r\n"
			$body+="Content-ID: "+String($request.request.id)+"\r\n\r\n"
			
			$body+=String($request.request.verb)+" "+String($request.request.URL)+" HTTP/1.1\r\n"
			
			If (Not(OB Is empty($request.request.headers)))
				var $hKeys : Collection:=OB Keys($request.request.headers)
				var $hKey : Text
				For each ($hKey; $hKeys)
					$body+=$hKey+": "+String($request.request.headers[$hKey])+"\r\n"
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
