/**
 * @class GoogleMail
 * @extends _GoogleAPI
 * @description Gmail API client; provides send, append, read, delete, label management,
 *   and change-notification operations. Supports both JMAP (4D mail object) and MIME
 *   (raw RFC 2822) output formats, controlled by the `mailType` property.
 */

Class extends _GoogleAPI

property mailType : Text
property userId : Text

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `mailType` {Text} — Default output format for received messages:
 *     `"JMAP"` (4D mail object, default) or `"MIME"` (raw RFC 2822 blob)
 *   - `userId` {Text} — Gmail user ID; defaults to `"me"` (the authenticated user)
 */
Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "JMAP"
	This.userId:=String($inParameters.userId)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
/**
 * @function _postJSONMessage
 * @private
 * @param {Text} $inURL - Target endpoint URL
 * @param {Object} $inMail - 4D mail object to send; passed directly to
 *   `Super._sendRequestAndWaitResponse` with `Content-Type: message/rfc822`
 * @param {Object} $inHeader - Additional HTTP headers to merge into the request
 * @returns {Object} Status object `{success; statusText; ?id}` where `id` is
 *   the Gmail message ID on success; pushes error 1 when `$inMail` is `Null`
 * @description Posts a mail message directly as RFC 2822 content (no base64 encoding);
 *   uses the Gmail media upload endpoint
 */
Function _postJSONMessage($inURL : Text; $inMail : Object; $inHeader : Object) : Object
	
	var $response : Object:=Null
	
	If ($inMail#Null)
		
		var $headers : Object:={}
		$headers["Content-Type"]:="message/rfc822"
		If (($inHeader#Null) && (Value type($inHeader)=Is object))
			var $keys : Collection:=OB Keys($inHeader)
			var $key : Text
			For each ($key; $keys)
				$headers[$key]:=$inHeader[$key]
			End for each 
		End if 
		
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $inMail)
		This._internals._response:=$response
	Else 
		Super._throwError(1)
	End if 
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _postMailMIMEMessage
 * @private
 * @param {Text} $inURL - Target endpoint URL
 * @param {Variant} $inMail - Mail content: BLOB (raw RFC 2822), Object (JMAP —
 *   converted via `MAIL Convert to MIME`), or Text (already serialised MIME)
 * @param {Collection} $inLabelIds - Label IDs to apply to the stored message;
 *   only used when appending (ignored when sending)
 * @returns {Object} Status object `{success; statusText}`
 * @description Base64-encodes the MIME content, wraps it in `{raw: ...}` JSON
 *   (plus optional `labelIds`), and POSTs it to the Gmail API
 */
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant; $inLabelIds : Collection) : Object
	
	var $requestBody : Text
	var $headers : Object:={}
	$headers["Content-Type"]:="application/json"
	
	Case of 
		: (Value type($inMail)=Is BLOB)
			$requestBody:=Try(Convert to text($inMail; "UTF-8"))
			
		: (Value type($inMail)=Is object)
			$requestBody:=Try(MAIL Convert to MIME($inMail; {includeBccHeaders: True}))
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE($requestBody)
	
	var $message : Object:={raw: $requestBody}
	If ((Value type($inLabelIds)=Is collection) && ($inLabelIds.length>0))
		$message.labelIds:=$inLabelIds
	End if 
	var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $message)
	This._internals._response:=$response
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _postMessage
 * @private
 * @param {Text} $inFunction - Internal function name for error reporting
 *   (e.g. `"google.mail.send"`, `"google.mail.append"`)
 * @param {Text} $inURL - Target endpoint URL
 * @param {Variant} $inMail - Mail content: BLOB or Text when `mailType` is `"MIME"`,
 *   Object when `mailType` is `"JMAP"`; pushes error 10 for unsupported combinations
 * @param {Collection} $inLabelIds - Label IDs for append operations; defaults to
 *   `["DRAFT"]` when the function is `"google.mail.append"` and no labels are provided
 * @returns {Object} Status object `{success; statusText}`
 * @description Dispatcher that routes mail POSTs to `_postMailMIMEMessage` based on
 *   `mailType`; validates the content type before dispatching
 */
Function _postMessage($inFunction : Text; $inURL : Text; $inMail : Variant; $inLabelIds : Collection) : Object
	
	var $status : Object
	var $labelIds : Collection:=Null
	
	Try
		
		If ($inFunction="google.mail.append")
			$labelIds:=((Value type($inLabelIds)=Is collection) && ($inLabelIds.length>0)) ? $inLabelIds : ["DRAFT"]
		End if 
		
		Case of 
			: ((This.mailType="MIME") && (\
				(Value type($inMail)=Is text) || \
				(Value type($inMail)=Is BLOB)))
				$status:=This._postMailMIMEMessage($inURL; $inMail; $labelIds)
				
			: ((This.mailType="JMAP") && (Value type($inMail)=Is object))
				$status:=This._postMailMIMEMessage($inURL; $inMail; $labelIds)
				
			Else 
				Super._throwError(10; {which: 1; function: $inFunction})
				$status:=This._returnStatus()
				
		End case 
	Catch
		$status:=This._returnStatus()
	End try
	
	return $status
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
/**
 * @function append
 * @param {Variant} $inMail - Mail to store; BLOB or Text (MIME) when `mailType` is
 *   `"MIME"`, Object (JMAP) when `mailType` is `"JMAP"`
 * @param {Collection} $inLabelIds - Label IDs to apply; defaults to `["DRAFT"]` when
 *   omitted or empty
 * @returns {Object} Status object `{success; statusText; ?id}` where `id` is the
 *   Gmail message ID of the stored message on success
 * @description Stores a mail message without sending it via
 *   `POST users/{userId}/messages/`; useful for importing existing messages or saving
 *   drafts with custom labels
 */
Function append($inMail : Variant; $inLabelIds : Collection) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/"
	
	var $status : Object:=This._postMessage("google.mail.append"; $URL; $inMail; $inLabelIds)
	If ((Value type(This._internals._response)=Is object) && (Length(String(This._internals._response.id))>0))
		$status.id:=String(This._internals._response.id)
	End if 
	
	return $status
	
	
	// ----------------------------------------------------
	
	
/**
 * @function send
 * @param {Variant} $inMail - Mail to send; BLOB or Text (MIME) when `mailType` is
 *   `"MIME"`, Object (JMAP) when `mailType` is `"JMAP"`
 * @returns {Object} Status object `{success; statusText}`
 * @description Sends a mail message via `POST users/{userId}/messages/send`
 */
Function send($inMail : Variant) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	$URL+="users/"+$userId+"/messages/send"
	
	return This._postMessage("google.mail.send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
/**
 * @function delete
 * @param {Text} $inMailId - Gmail message ID to delete; pushes error 10 when not a
 *   Text, error 9 when empty
 * @param {Boolean} $permanently - When True, permanently deletes the message via
 *   `DELETE`; when False (default), moves it to Trash via `POST .../trash`
 * @returns {Object} Status object `{success; statusText}`
 * @description Deletes a mail message, either permanently or by trashing it
 */
Function delete($inMailId : Text; $permanently : Boolean) : Object
	
	Super._clearErrorStack()
	
	Try
		
		Case of 
			: (Type($inMailId)#Is text)
				Super._throwError(10; {which: "\"mailId\""; function: "google.mail.delete"})
				
			: (Length(String($inMailId))=0)
				Super._throwError(9; {which: "\"mailId\""; function: "google.mail.delete"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				$URL+="users/"+$userId+"/messages/"+$inMailId
				If (Not(Bool($permanently)))
					$URL+="/trash"
				End if 
				var $verb : Text:=Bool($permanently) ? "DELETE" : "POST"
				
				This._internals._response:=Super._sendRequestAndWaitResponse($verb; $URL)
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
/**
 * @function untrash
 * @param {Text} $inMailId - Gmail message ID to restore; pushes error 10 when not a
 *   Text, error 9 when empty
 * @returns {Object} Status object `{success; statusText}`
 * @description Removes a message from Trash via `POST users/{userId}/messages/{id}/untrash`
 */
Function untrash($inMailId : Text) : Object
	
	Super._clearErrorStack()
	
	Try
		
		Case of 
			: (Type($inMailId)#Is text)
				Super._throwError(10; {which: "\"mailId\""; function: "google.mail.untrash"})
				
			: (Length(String($inMailId))=0)
				Super._throwError(9; {which: "\"mailId\""; function: "google.mail.untrash"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				$URL+="users/"+$userId+"/messages/"+$inMailId+"/untrash"
				
				This._internals._response:=Super._sendRequestAndWaitResponse("POST"; $URL)
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
/**
 * @function getMailIds
 * @param {Object} $inParameters - Query options forwarded to `_getURLParamsFromObject`;
 *   see the Gmail `users.messages.list` API for supported parameters
 *   (e.g. `q`, `labelIds`, `maxResults`, `pageToken`)
 * @returns {cs.GoogleMailIdList} Paginated list of Gmail message IDs;
 *   use `next()` / `previous()` to navigate pages
 * @description Returns a `GoogleMailIdList` for the first page of matching messages
 */
Function getMailIds($inParameters : Object) : Object
	
	Super._clearErrorStack()
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	var $urlParams : Text:="users/"+$userId+"/messages"+This._getURLParamsFromObject($inParameters)
	
	return cs.GoogleMailIdList.new(This._getOAuth2Provider(); $URL+$urlParams)
	
	
	// ----------------------------------------------------
	
	
/**
 * @function getMail
 * @param {Text} $inMailId - Gmail message ID to fetch; pushes error 10 when not a
 *   Text, error 9 when empty
 * @param {Object} $inParameters - Options; recognised properties:
 *   - `mailType` {Text} — Override instance `mailType` for this call
 *   - `format` {Text} — Gmail response format: `"raw"` (default), `"minimal"`, or
 *     `"metadata"`
 * @returns {Variant} JMAP object (4D mail), BLOB, or Text depending on `mailType`
 *   and `format`; `Null` on error or when required parameters are missing
 * @description Fetches a single message via `GET users/{userId}/messages/{id}` and
 *   converts the response via `_extractRawMessage`
 */
Function getMail($inMailId : Text; $inParameters : Object) : Variant
	
	Super._clearErrorStack()
	
	var $response : Variant:=Null
	
	Try
		
		Case of 
			: (Type($inMailId)#Is text)
				Super._throwError(10; {which: "\"mailId\""; function: "google.mail.getMail"})
				
			: (Length(String($inMailId))=0)
				Super._throwError(9; {which: "\"mailId\""; function: "google.mail.getMail"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				var $mailType : Text:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
				var $format : Text:=String($inParameters.format)
				$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
				var $parameters : Object:=(($inParameters#Null) && (Value type($inParameters)=Is object)) ? $inParameters : {format: $format}
				If ($parameters.format#$format)
					$parameters.format:=$format
				End if 
				var $urlParams : Text:="users/"+$userId+"/messages/"+String($inMailId)+This._getURLParamsFromObject($parameters)
				
				var $result : Object:=Super._sendRequestAndWaitResponse("GET"; $URL+$urlParams)
				$response:=This._extractRawMessage($result; $format; $mailType)
				
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return $response
	
	
	// ----------------------------------------------------
	
	
/**
 * @function getMails
 * @param {Collection} $inMailIds - Collection of Gmail message IDs (Text) or objects
 *   with an `id` property; pushes error 10 when not a Collection, error 9 when empty
 * @param {Object} $inParameters - Options forwarded to `getMail` or the batch request;
 *   same properties as `getMail.$inParameters`
 * @returns {Collection} Collection of mail items (JMAP objects, BLOBs, or Texts);
 *   `Null` on error
 * @description Fetches multiple messages: uses a single `getMail` call for one ID,
 *   or a `_GoogleBatchRequest` for multiple IDs to reduce round-trips
 */
Function getMails($inMailIds : Collection; $inParameters : Object) : Collection
	
	var $result : Collection:=Null
	
	Super._clearErrorStack()
	
	Case of 
		: (Type($inMailIds)#Is collection)
			Super._throwError(10; {which: "\"mailIds\""; function: "google.mail.getMails"})
			
		: (Num($inMailIds.length)=0)
			Super._throwError(9; {which: "\"mailIds\""; function: "google.mail.getMails"})
			
		Else 
			
			var $mailIds : Collection:=(Value type($inMailIds)=Is collection) ? $inMailIds : []
			
			If (($mailIds.length>0) && (Value type($mailIds[0])=Is object))
				$mailIds:=$mailIds.extract("id")
			End if 
			
			If ($mailIds.length=1)
				
				var $response : Variant:=This.getMail($mailIds[0]; $inParameters)
				If ($response#Null)
					$result:=New collection($response)
				End if 
				
			Else 
				
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				var $mailType : Text:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : This.mailType
				var $format : Text:=String($inParameters.format)
				$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
				var $parameters : Object:=(($inParameters#Null) && (Value type($inParameters)=Is object)) ? $inParameters : {format: $format}
				If ($parameters.format#$format)
					$parameters.format:=$format
				End if 
				
				var $batchRequest : cs._GoogleBatchRequest:=cs._GoogleBatchRequest.new(This._getOAuth2Provider(); {mailType: $mailType; format: $format})
				var $mailId : Text
				
				For each ($mailId; $mailIds)
					var $urlParams : Text:="users/"+$userId+"/messages/"+$mailId+This._getURLParamsFromObject($parameters)
					$batchRequest.appendRequest({verb: "GET"; URL: $URL+$urlParams})
				End for each 
				
				$result:=$batchRequest.sendRequestAndWaitResponse()
				
				If (($result=Null) || ($batchRequest._getLastError()#Null))
					var $stack : Collection:=$batchRequest._getErrorStack().reverse()
					var $error : Object
					
					For each ($error; $stack)
						This._getErrorStack().push($error)
						throw($error)
					End for each 
				End if 
				
			End if 
			
	End case 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
/**
 * @function update
 * @param {Collection} $inMailIds - Collection of Gmail message IDs (Text) or objects
 *   with an `id` property; pushes error 10 when not a Collection, error 9 when empty,
 *   error 13 when more than 1000 IDs are supplied
 * @param {Object} $inParameters - Modification options; recognised properties:
 *   - `addLabelIds` {Collection} — Label IDs to add to the messages
 *   - `removeLabelIds` {Collection} — Label IDs to remove from the messages
 *   Pushes error 10 when `$inParameters` is not an Object
 * @returns {Object} Status object `{success; statusText}`
 * @description Batch-modifies labels on up to 1000 messages via
 *   `POST users/{userId}/messages/batchModify`
 */
Function update($inMailIds : Collection; $inParameters : Object) : Object
	
	Super._clearErrorStack()
	
	Try
		
		Case of 
			: (Type($inMailIds)#Is collection)
				Super._throwError(10; {which: "\"mailIds\""; function: "google.mail.update"})
				
			: (Num($inMailIds.length)=0)
				Super._throwError(9; {which: "\"mailIds\""; function: "google.mail.update"})
				
			: (Num($inMailIds.length)>1000)
				Super._throwError(13; {which: "\"mailIds\""; function: "google.mail.update"; max: 1000})
				
			: (Type($inParameters)#Is object)
				Super._throwError(10; {which: "\"parameters\""; function: "google.mail.update"})
				
			Else 
				
				var $mailIds : Collection:=(Value type($inMailIds)=Is collection) ? $inMailIds : []
				
				If (($mailIds.length>0) && (Value type($mailIds[0])=Is object))
					$mailIds:=$mailIds.extract("id")
				End if 
				
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				$URL+="users/"+$userId+"/messages/batchModify"
				
				var $headers : Object:={}
				var $body : Object:={}
				$body.ids:=$mailIds
				$body.addLabelIds:=(Value type($inParameters.addLabelIds)=Is collection) ? $inParameters.addLabelIds : []
				$body.removeLabelIds:=(Value type($inParameters.removeLabelIds)=Is collection) ? $inParameters.removeLabelIds : []
				
				This._internals._response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $body)
				
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus()
	
	
	// Mark: - Labels
	// ----------------------------------------------------
	
	
/**
 * @function getLabelList
 * @param {Object} $inParameters - Options; recognised properties:
 *   - `ids` {Collection} — Specific label IDs to fetch (Text or objects with `id`);
 *     when omitted, fetches all labels via `GET users/{userId}/labels`
 *   - `withCounters` {Boolean} — When True, includes `threadsTotal`, `threadsUnread`,
 *     `messagesTotal`, and `messagesUnread` in each label (requires individual
 *     `GET users/{userId}/labels/{id}` requests via batch)
 * @returns {Object} Status object `{success; statusText; ?labels}` where `labels`
 *   is an array of label objects
 * @description Retrieves one or more labels; when `ids` are provided or `withCounters`
 *   is True, individual label details are fetched via a `_GoogleBatchRequest`
 */
Function getLabelList($inParameters : Object) : Object
	
	Super._clearErrorStack()
	var $URL : Text:=Super._getURL()
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	var $response : Object:=Null
	var $labelIds : Collection:=(Value type($inParameters.ids)=Is collection) ? $inParameters.ids : []
	var $bWithCounters : Boolean:=(Value type($inParameters.withCounters)=Is boolean) ? $inParameters.withCounters : False
	var $bSendBatchRequest : Boolean:=False
	
	If (($labelIds.length>0) && (Value type($labelIds[0])=Is object))
		$labelIds:=$labelIds.extract("id")
	End if 
	
	If ($labelIds.length=0)
		
		$response:=Super._sendRequestAndWaitResponse("GET"; $URL+"users/"+$userId+"/labels")
		If (Value type($response.labels)=Is collection)
			$labelIds:=$response.labels.extract("id")
		End if 
		$bSendBatchRequest:=$bWithCounters
		
	Else 
		
		$bSendBatchRequest:=True
	End if 
	
	If (($labelIds.length>0) && $bSendBatchRequest)
		
		var $batchRequest : cs._GoogleBatchRequest:=cs._GoogleBatchRequest.new(This._getOAuth2Provider(); {format: "JSON"; maxItemNumber: 10})
		var $labelId : Text
		
		For each ($labelId; $labelIds)
			var $urlParams : Text:="users/"+$userId+"/labels/"+$labelId
			$batchRequest.appendRequest({verb: "GET"; URL: $URL+$urlParams})
		End for each 
		
		var $result : Collection:=$batchRequest.sendRequestAndWaitResponse()
		
		If (($result=Null) || ($batchRequest._getLastError()#Null))
			
			var $stack : Collection:=$batchRequest._getErrorStack().reverse()
			var $error : Object
			
			For each ($error; $stack)
				This._getErrorStack().push($error)
				throw($error)
			End for each 
		End if 
		
		If (Not($bWithCounters))
			
			var $label : Object
			For each ($label; $result)
				OB REMOVE($label; "threadsTotal")
				OB REMOVE($label; "threadsUnread")
				OB REMOVE($label; "messagesTotal")
				OB REMOVE($label; "messagesUnread")
			End for each 
		End if 
		
		$response:={labels: $result}
		
	End if 
	
	return This._returnStatus($response)
	
	
	// ----------------------------------------------------
	
	
/**
 * @function getLabel
 * @param {Text} $inLabelId - Gmail label ID to fetch; pushes error 10 when not a
 *   Text, error 9 when empty
 * @returns {Object} Label resource object from the Gmail API, or `Null` when
 *   validation fails
 * @description Fetches a single label's details via `GET users/{userId}/labels/{labelId}`
 */
Function getLabel($inLabelId : Text) : Object
	
	Case of 
		: (Type($inLabelId)#Is text)
			Super._throwError(10; {which: "\"labelId\""; function: "google.mail.getLabel"})
			
		: (Length($inLabelId)=0)
			Super._throwError(9; {which: "\"labelId\""; function: "google.mail.getLabel"})
			
		Else 
			
			var $URL : Text:=Super._getURL()
			var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
			$URL+="users/"+$userId+"/labels/"+$inLabelId
			
			return Super._sendRequestAndWaitResponse("GET"; $URL)
			
	End case 
	
	return Null
	
	
	// ----------------------------------------------------
	
	
/**
 * @function createLabel
 * @param {Object} $inLabelInfo - Label properties to create (e.g. `name`,
 *   `messageListVisibility`, `labelListVisibility`); pushes error 10 when not an
 *   Object, error 9 when empty
 * @returns {Object} Status object `{success; statusText; ?label}` where `label`
 *   is the created label resource on success
 * @description Creates a new label via `POST users/{userId}/labels`
 */
Function createLabel($inLabelInfo : Object) : Object
	
	Super._clearErrorStack()
	
	var $response : Object:=Null
	
	Try
		
		Case of 
			: (Type($inLabelInfo)#Is object)
				Super._throwError(10; {which: "\"labelInfo\""; function: "google.mail.createLabel"})
				
			: (OB Is empty($inLabelInfo))
				Super._throwError(9; {which: "\"labelInfo\""; function: "google.mail.createLabel"})
				
			Else 
				
				var $headers : Object:={}
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				$URL+="users/"+$userId+"/labels"
				
				$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; $inLabelInfo)
				
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus(($response#Null) ? {label: $response} : Null)
	
	
	
	// ----------------------------------------------------
	
	
/**
 * @function deleteLabel
 * @param {Text} $inLabelId - Gmail label ID to delete; pushes error 10 when not a
 *   Text, error 9 when empty
 * @returns {Object} Status object `{success; statusText}`
 * @description Permanently deletes a label via `DELETE users/{userId}/labels/{labelId}`
 */
Function deleteLabel($inLabelId : Text) : Object
	
	Super._clearErrorStack()
	
	Try
		
		Case of 
			: (Type($inLabelId)#Is text)
				Super._throwError(10; {which: "\"labelId\""; function: "google.mail.deleteLabel"})
				
			: (Length($inLabelId)=0)
				Super._throwError(9; {which: "\"labelId\""; function: "google.mail.deleteLabel"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				$URL+="users/"+$userId+"/labels/"+$inLabelId
				
				This._internals._response:=Super._sendRequestAndWaitResponse("DELETE"; $URL)
				
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
/**
 * @function updateLabel
 * @param {Text} $inLabelId - Gmail label ID to update; pushes error 10 when not a
 *   Text, error 9 when empty
 * @param {Object} $inLabelInfo - Updated label properties; pushes error 10 when not
 *   an Object, error 9 when empty
 * @returns {Object} Status object `{success; statusText; ?label}` where `label`
 *   is the updated label resource on success
 * @description Fully replaces a label's properties via `PUT users/{userId}/labels/{labelId}`
 */
Function updateLabel($inLabelId : Text; $inLabelInfo : Object) : Object
	
	Super._clearErrorStack()
	
	var $response : Object:=Null
	
	Try
		
		Case of 
			: (Type($inLabelId)#Is text)
				Super._throwError(10; {which: "\"labelId\""; function: "google.mail.updateLabel"})
				
			: (Length($inLabelId)=0)
				Super._throwError(9; {which: "\"labelId\""; function: "google.mail.updateLabel"})
				
			: (Type($inLabelInfo)#Is object)
				Super._throwError(10; {which: "\"labelInfo\""; function: "google.mail.updateLabel"})
				
			: (OB Is empty($inLabelInfo))
				Super._throwError(9; {which: "\"labelInfo\""; function: "google.mail.updateLabel"})
				
			Else 
				
				var $headers : Object:={}
				var $URL : Text:=Super._getURL()
				var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
				$URL+="users/"+$userId+"/labels/"+$inLabelId
				
				$response:=Super._sendRequestAndWaitResponse("PUT"; $URL; $headers; $inLabelInfo)
				
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus(($response#Null) ? {label: $response} : Null)
	
	
	// Mark: - Notifications
	// ----------------------------------------------------
	
	
/**
 * @function notifier
 * @param {Object} $inParameters - Notification options (see inline documentation):
 *   `onCreate`, `onDelete`, `onModify` callbacks; optional `topicName` (Pub/Sub topic
 *   for push mode); optional `labelIds` filter; optional `timer` (seconds) for pull mode
 * @returns {cs.GoogleNotification} Notification object with `start()`, `stop()`,
 *   `expiration`, and `isStarted`; call `start()` to begin monitoring
 * @description Factory that creates a `GoogleNotification` for Gmail change monitoring.
 *   Push mode requires a Google Cloud Pub/Sub topic (`topicName`); pull mode polls
 *   the Gmail history API at a configurable interval.
 */
Function notifier($inParameters : Object) : cs.GoogleNotification
	
/*
	The notification object can be started and stopped. When started, it monitors
	Gmail for changes and dispatches callbacks when messages are created, deleted, or modified.
	
	Two modes:
	- Push: Requires a Google Cloud Pub/Sub topic. Set topicName parameter.
	  The user must configure a Pub/Sub push subscription pointing to {serverUrl}/4dnk-google-notification.
	- Pull: If no topicName is provided, polls the Gmail history API at a configurable interval.
	
	Parameters:
	    $inParameters.onCreate : 4D.Function - Called when a mail is created. Receives {eventType; IDs}.
	    $inParameters.onDelete : 4D.Function - Called when a mail is deleted. Receives {eventType; IDs}.
	    $inParameters.onModify : 4D.Function - Called when a mail is modified. Receives {eventType; IDs}.
	    $inParameters.topicName : Text - Google Cloud Pub/Sub topic name for push mode.
	    $inParameters.labelIds : Collection - Optional. Label IDs to filter notifications.
	    $inParameters.timer : Integer - Optional. Polling interval in seconds for pull mode (default: 30).
	
	Returns:
	    cs.GoogleNotification object with start(), stop(), expiration and isStarted.
	
	See: https://developers.google.com/gmail/api/guides/push
*/
	
	var $userId : Text:=(Length(String(This.userId))>0) ? This.userId : "me"
	
	return cs.GoogleNotification.new("mail"; This._getOAuth2Provider(); $inParameters; $userId; This)
