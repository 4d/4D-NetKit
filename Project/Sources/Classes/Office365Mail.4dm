/**
 * @class Office365Mail
 * @description Microsoft Graph API client for mail operations.
 *   Supports reading, sending, moving, copying, replying, updating, and deleting messages,
 *   as well as managing mail folders and setting up change notifications.
 *   Accepts messages in Microsoft Graph JSON (`"Microsoft"`), JMAP (`"JMAP"`), or MIME
 *   (`"MIME"`) format, controlled by the `mailType` property.
 */

Class extends _GraphAPI

property mailType : Text
property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `mailType` {Text} — Mail format: `"Microsoft"` (default), `"JMAP"`, or `"MIME"`
 *   - `userId` {Text} — Graph user ID or UPN; defaults to `""` (uses `me` endpoint)
 */
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "Microsoft"
	This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _postJSONMessage($inURL : Text; $inMail : Object; $bSkipMessageEncapsulation : Boolean; $inHeaders : Object) : Object
/**
 * @function _postJSONMessage
 * @private
 * @param {Text} $inURL - Target Graph API endpoint URL
 * @param {Object} $inMail - Mail object in Microsoft Graph JSON format
 * @param {Boolean} $bSkipMessageEncapsulation - When `True`, sends `$inMail` as-is;
 *   otherwise wraps it in a `{message: ...}` envelope
 * @param {Object} $inHeaders - Additional HTTP headers merged into the request
 * @returns {Object} Status object; includes `id` when the server returns one
 * @description Posts a mail message as JSON to the Graph API
 */
	
	var $response : Object
	
	If ($inMail#Null)
		
		var $headers : Object:={}
		If (($inHeaders#Null) && (Value type($inHeaders)=Is object))
			$headers:=OB Copy($inHeaders)
		End if 
		$headers["Content-Type"]:="application/json"
		
		var $message : Object
		var $messageCopy : Object:=This._copyGraphMessage($inMail)
		If (Not(OB Is defined($inMail; "message")) && Not($bSkipMessageEncapsulation))
			$message:={message: $messageCopy}
		Else 
			$message:=$messageCopy
		End if 
		var $requestBody : Text:=JSON Stringify($message)
		
		$response:=Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $requestBody)
	Else 
		Super._throwError(1)
	End if 
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
/**
 * @function _postMailMIMEMessage
 * @private
 * @param {Text} $inURL - Target Graph API endpoint URL
 * @param {Variant} $inMail - Mail content: BLOB (raw MIME), Object (JMAP — converted via
 *   `MAIL Convert to MIME`), or Text (raw MIME string)
 * @returns {Object} Status object
 * @description Posts a mail message in MIME format (`Content-Type: text/plain`, base64-encoded).
 *   Note: appending to a folder with MIME always returns `UnableToDeserializePostBody`
 *   (known Microsoft Graph issue — see inline comment for issue links)
 */
	
/*
 *	POST /me/mailFolders/{id}/messages with MIME format always returns UnableToDeserializePostBody 
 *	An issue has already been registered.
 *	See: https://github.com/microsoftgraph/microsoft-graph-docs/issues/16368
 *	See also: https://learn.microsoft.com/en-us/answers/questions/544038/unabletodeserializepostbody-error-when-testing-wit.html
 */
	
	var $requestBody : Text
	var $headers : Object:={}
	$headers["Content-Type"]:="text/plain"
	
	Case of 
		: (Value type($inMail)=Is BLOB)
			$requestBody:=Try(Convert to text($inMail; "UTF-8"))
			
		: (Value type($inMail)=Is object)
			$requestBody:=Try(MAIL Convert to MIME($inMail; {includeBccHeaders: True}))
			
		Else 
			$requestBody:=$inMail
	End case 
	BASE64 ENCODE($requestBody)
	
	Super._sendRequestAndWaitResponse("POST"; $inURL; $headers; $requestBody)
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function _postMessage($inFunction : Text; $inURL : Text; $inMail : Variant; $bSkipMessageEncapsulation : Boolean; $inHeader : Object) : Object
/**
 * @function _postMessage
 * @private
 * @param {Text} $inFunction - Caller name for error reporting (e.g. `"office365.mail.send"`)
 * @param {Text} $inURL - Target Graph API endpoint URL
 * @param {Variant} $inMail - Mail content; type must match `mailType`
 * @param {Boolean} $bSkipMessageEncapsulation - Forwarded to `_postJSONMessage`
 * @param {Object} $inHeader - Additional HTTP headers forwarded to `_postJSONMessage`
 * @returns {Object} Status object
 * @description Dispatches to `_postJSONMessage` or `_postMailMIMEMessage` based on `mailType`
 *   and the actual type of `$inMail`; throws error 10 on type mismatch
 */
	
	var $status : Object
	
	Try
		
		If (Length(String(This.mailType))=0)
			This.mailType:="Microsoft"
		End if 
		
		Case of 
			: ((This.mailType="MIME") && (\
				(Value type($inMail)=Is text) || \
				(Value type($inMail)=Is BLOB)))
				$status:=This._postMailMIMEMessage($inURL; $inMail)
				
			: ((This.mailType="JMAP") && (Value type($inMail)=Is object))
				$status:=This._postMailMIMEMessage($inURL; $inMail)
				
			: ((This.mailType="Microsoft") && (Value type($inMail)=Is object))
				$status:=This._postJSONMessage($inURL; $inMail; $bSkipMessageEncapsulation; $inHeader)
				
			Else 
				Super._throwError(10; {which: 1; function: $inFunction})
				$status:=This._returnStatus()
				
		End case 
	Catch
		$status:=This._returnStatus()
	End try
	
	return $status
	
	
	// ----------------------------------------------------
	
	
Function _computeBase64BinarySize($inBase64 : Text) : Integer
/**
 * @function _computeBase64BinarySize
 * @private
 * @param {Text} $inBase64 - Base64 content (optionally containing CR/LF)
 * @returns {Integer} Decoded binary size in bytes
 */
	
	var $encoded : Text:=Replace string(String($inBase64); "\r"; ""; *)
	$encoded:=Replace string($encoded; "\n"; ""; *)
	
	var $encodedLength : Integer:=Length($encoded)
	If ($encodedLength=0)
		return 0
	End if 
	
	var $padding : Integer:=0
	If (($encodedLength>=2) && (Substring($encoded; $encodedLength-1; 2)="=="))
		$padding:=2
	Else 
		If (Substring($encoded; $encodedLength; 1)="=")
			$padding:=1
		End if 
	End if 
	
	return Int(($encodedLength/4)*3)-$padding
	
	
	// ----------------------------------------------------
	
	
Function _extractGraphMessageForSend($inMail : Object) : Object
/**
 * @function _extractGraphMessageForSend
 * @private
 * @param {Object} $inMail - Message payload (with or without `message` envelope)
 * @returns {Object} Graph message object ready to be posted to `/messages`
 */
	
	var $mailCopy : Object:=This._copyGraphMessage($inMail)
	If (OB Is defined($mailCopy; "message") && (Value type($mailCopy.message)=Is object))
		return $mailCopy.message
	End if 
	
	return $mailCopy
	
	
	// ----------------------------------------------------
	
	
Function _isLargeFileAttachment($inAttachment : Object) : Boolean
/**
 * @function _isLargeFileAttachment
 * @private
 * @param {Object} $inAttachment - Graph attachment object
 * @returns {Boolean} `True` when a file attachment exceeds 3 MiB
 */
	
	If (Value type($inAttachment)#Is object)
		return False
	End if 
	
	var $odataType : Text:=Lowercase(String($inAttachment["@odata.type"]))
	If (($odataType#"") && ($odataType#"#microsoft.graph.fileattachment"))
		return False
	End if 
	
	var $contentBytes : Text:=String($inAttachment.contentBytes)
	If (Length($contentBytes)=0)
		return False
	End if 
	
	var $maxSimpleAttachmentSize : Integer:=3*1024*1024
	return (This._computeBase64BinarySize($contentBytes)>$maxSimpleAttachmentSize)
	
	
	// ----------------------------------------------------
	
	
Function _hasLargeFileAttachment($inMail : Object) : Boolean
/**
 * @function _hasLargeFileAttachment
 * @private
 * @param {Object} $inMail - Message payload (with or without `message` envelope)
 * @returns {Boolean} `True` when at least one attachment is larger than 3 MiB
 */
	
	var $message : Object:=This._extractGraphMessageForSend($inMail)
	If (Not(OB Is defined($message; "attachments")) || (Value type($message.attachments)#Is collection))
		return False
	End if 
	
	var $attachment : Object
	For each ($attachment; $message.attachments)
		If (This._isLargeFileAttachment($attachment))
			return True
		End if 
	End for each 
	
	return False
	
	
	// ----------------------------------------------------
	
	
Function _uploadLargeFileAttachment($inMessageId : Text; $inAttachment : Object)
/**
 * @function _uploadLargeFileAttachment
 * @private
 * @param {Text} $inMessageId - Draft message ID
 * @param {Object} $inAttachment - Graph fileAttachment object containing `contentBytes`
 * @description Uploads an attachment through Graph upload session with chunked PUT requests.
 */
	
	var $base64Content : Text:=Replace string(String($inAttachment.contentBytes); "\r"; ""; *)
	$base64Content:=Replace string($base64Content; "\n"; ""; *)
	var $totalSize : Integer:=This._computeBase64BinarySize($base64Content)
	
	If ($totalSize<=0)
		This._throwError(13; {function: "office365.mail.send"; message: "Invalid attachment content."})
	End if 
	
	var $URL : Text:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId
	Else 
		$URL+="me"
	End if 
	$URL+="/messages/"+$inMessageId+"/attachments/createUploadSession"
	
	var $headers : Object:={}
	$headers["Content-Type"]:="application/json"
	var $body : Object:={AttachmentItem: {attachmentType: "file"; name: String($inAttachment.name); size: $totalSize}}
	If (Length(String($inAttachment.contentType))>0)
		$body.AttachmentItem.contentType:=String($inAttachment.contentType)
	End if 
	
	var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify($body))
	var $uploadURL : Text:=String($response.uploadUrl)
	If (Length($uploadURL)=0)
		This._throwError(13; {function: "office365.mail.send"; message: "Unable to create upload session for attachment."})
	End if 
	
	var $chunkSize : Integer:=983040  // 960 KiB, multiple of 320 KiB and 3 bytes for safe Base64 chunking
	var $base64ChunkSize : Integer:=1310720
	var $offset : Integer:=0
	var $base64Pos : Integer:=1
	
	While ($offset<$totalSize)
		
		var $currentChunkBase64 : Text
		var $currentChunkSize : Integer
		If (($offset+$chunkSize)<$totalSize)
			$currentChunkBase64:=Substring($base64Content; $base64Pos; $base64ChunkSize)
			$currentChunkSize:=$chunkSize
			$base64Pos+=$base64ChunkSize
		Else 
			$currentChunkBase64:=Substring($base64Content; $base64Pos)
			$currentChunkSize:=This._computeBase64BinarySize($currentChunkBase64)
		End if 
		
		var $chunkBlob : Blob
		BASE64 DECODE($currentChunkBase64; $chunkBlob)
		
		var $chunkHeaders : Object:={}
		$chunkHeaders["Content-Type"]:="application/octet-stream"
		$chunkHeaders["Content-Length"]:=String($currentChunkSize)
		$chunkHeaders["Content-Range"]:="bytes "+String($offset)+"-"+String($offset+$currentChunkSize-1)+"/"+String($totalSize)
		
		// uploadUrl already contains an auth token; do not add Authorization header.
		var $putRequest : 4D.HTTPRequest:=Try(4D.HTTPRequest.new($uploadURL; {method: "PUT"; headers: $chunkHeaders; body: $chunkBlob; dataType: "auto"}).wait())
		var $putStatus : Integer:=Num($putRequest.response.status)
		If (Int($putStatus/100)#2)
			var $statusText : Text:=String($putRequest.response.statusText)
			var $message : Text
			If (Value type($putRequest.response.body)=Is text)
				$message:=$putRequest.response.body
			Else 
				If (Value type($putRequest.response.body)=Is object)
					$message:=Try(JSON Stringify($putRequest.response.body))
				Else 
					$message:=Try(Convert to text($putRequest.response.body; "UTF-8"))
				End if 
			End if 
			This._throwError(8; {status: $putStatus; explanation: $statusText; message: $message})
		End if 
		$offset+=$currentChunkSize
		
	End while 
	
	
	// ----------------------------------------------------
	
	
Function _sendMailWithLargeAttachments($inMail : Object) : Object
/**
 * @function _sendMailWithLargeAttachments
 * @private
 * @param {Object} $inMail - Microsoft Graph mail object (with or without `message` envelope)
 * @returns {Object} Status object
 * @description Sends messages containing large attachments by creating a draft,
 *   uploading big files with upload sessions, then calling `/messages/{id}/send`.
 */
	
	Try
		var $message : Object:=This._extractGraphMessageForSend($inMail)
		
		var $attachments : Collection:=[]
		If (OB Is defined($message; "attachments") && (Value type($message.attachments)=Is collection))
			$attachments:=$message.attachments
		End if 
		
		var $smallAttachments : Collection:=[]
		var $largeAttachments : Collection:=[]
		var $attachment : Object
		For each ($attachment; $attachments)
			If (This._isLargeFileAttachment($attachment))
				$largeAttachments.push($attachment)
			Else 
				$smallAttachments.push($attachment)
			End if 
		End for each 
		
		var $draftMessage : Object:=OB Copy($message)
		If ($attachments.length>0)
			$draftMessage.attachments:=$smallAttachments
		End if 
		
		var $draftStatus : Object:=This.append($draftMessage; "")
		If (Not(Bool($draftStatus.success)))
			return This._returnStatus()
		End if 
		
		var $messageId : Text:=String($draftStatus.id)
		If (Length($messageId)=0)
			This._throwError(13; {function: "office365.mail.send"; message: "Draft message creation failed."})
		End if 
		
		For each ($attachment; $largeAttachments)
			This._uploadLargeFileAttachment($messageId; $attachment)
		End for each 
		
		var $URL : Text:=Super._getURL()
		If (Length(String(This.userId))>0)
			$URL+="users/"+This.userId
		Else 
			$URL+="me"
		End if 
		$URL+="/messages/"+$messageId+"/send"
		Super._sendRequestAndWaitResponse("POST"; $URL)
		
		return This._returnStatus({id: $messageId})
	Catch
		return This._returnStatus()
	End try
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function append($inMail : Variant; $inFolderId : Text) : Object
/**
 * @function append
 * @param {Variant} $inMail - Mail to save; type must match `mailType`
 * @param {Text} $inFolderId - Target folder ID; uses `me/messages` (draft) when empty
 * @returns {Object} Status object; includes `id` of the saved message
 * @description Saves a message to a mail folder without sending it via
 *   `POST /me/mailFolders/{id}/messages` (or `/users/{id}/...`)
 */
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId
	Else 
		$URL+="me"
	End if 
	If (Length($inFolderId)>0)
		$URL+="/mailFolders/"+$inFolderId
	End if 
	$URL+="/messages"
	
	return This._postMessage("office365.mail.append"; $URL; $inMail; True)
	
	
	// ----------------------------------------------------
	
	
Function copy($inMailId : Text; $inFolderId : Text) : Object
/**
 * @function copy
 * @param {Text} $inMailId - ID of the message to copy
 * @param {Text} $inFolderId - Destination folder ID
 * @returns {Object} Status object; includes `id` of the new copy
 * @description Copies a message to another folder via
 *   `POST /me/messages/{id}/copy`
 */
	
	Super._clearErrorStack()
	
	var $response : Object
	
	Try
		
		Case of 
			: (Type($inMailId)#Is text)
				Super._throwError(10; {which: "\"mailId\""; function: "office365.mail.copy"})
				
			: (Length(String($inMailId))=0)
				Super._throwError(9; {which: "\"mailId\""; function: "office365.mail.copy"})
				
			: (Type($inFolderId)#Is text)
				Super._throwError(10; {which: "\"folderId\""; function: "office365.mail.copy"})
				
			: (Length(String($inFolderId))=0)
				Super._throwError(9; {which: "\"folderId\""; function: "office365.mail.copy"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				If (Length(String(This.userId))>0)
					$URL+="users/"+This.userId
				Else 
					$URL+="me"
				End if 
				$URL+="/messages/"+$inMailId+"/copy"
				
				var $headers : Object:={}
				var $body : Object:={destinationId: $inFolderId}
				
				$headers["Content-Type"]:="application/json"
				$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify($body))
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function delete($inMailId : Text) : Object
/**
 * @function delete
 * @param {Text} $inMailId - ID of the message to delete permanently
 * @returns {Object} Status object
 * @description Permanently deletes a message via `DELETE /me/messages/{id}`
 */
	
	Super._clearErrorStack()
	
	Try
		
		If ((Type($inMailId)=Is text) && (Length(String($inMailId))>0))
			
			var $URL : Text:=Super._getURL()
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/messages/"+$inMailId
			
			Super._sendRequestAndWaitResponse("DELETE"; $URL)
			
		Else 
			
			Super._throwError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "office365.mail.delete"})
		End if 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getMail($inMailId : Text; $inOptions : Object) : Variant
/**
 * @function getMail
 * @param {Text} $inMailId - ID of the message to retrieve
 * @param {Object} $inOptions - Optional overrides:
 *   - `mailType` {Text} — `"Microsoft"` (Graph object), `"JMAP"` (converted via
 *     `MAIL Convert from MIME`), or `"MIME"` (raw MIME text)
 *   - `contentType` {Text} — `"text"` or `"html"` (sets `Prefer: outlook.body-content-type`)
 * @returns {Variant} `GraphMessage` object, JMAP Object, or MIME Text depending on `mailType`;
 *   `Null` on error or when not found
 * @description Fetches a single message via `GET /me/messages/{id}` (or `/$value` for MIME)
 */
	
	Super._clearErrorStack()
	
	If ((Type($inMailId)=Is text) && (Length(String($inMailId))>0))
		
		var $URL : Text:=Super._getURL()
		If (Length(String(This.userId))>0)
			$URL+="users/"+This.userId
		Else 
			$URL+="me"
		End if 
		$URL+="/messages/"+$inMailId
		
		var $mailType : Text:=(($inOptions#Null) && \
			(Length(String($inOptions.mailType))>0)) ? $inOptions.mailType : This.mailType
		If (($mailType="JMAP") || ($mailType="MIME"))
			$URL+="/$value"
		End if 
		
		var $headers : Object
		var $contentType : Text:=(($inOptions#Null) && \
			(Length(String($inOptions.contentType))>0)) ? $inOptions.contentType : ""
		If (($contentType="text") || ($contentType="html"))
			$headers:={Prefer: String("outlook.body-content-type=\""+$contentType+"\"")}
		End if 
		
		var $response : Variant:=Null
		var $result : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
		If ($result#Null)
			If ($mailType="Microsoft")
				$response:=cs.GraphMessage.new(This._internals._oAuth2Provider; {userId: String(This.userId)}; $result)
				
			Else 
				If (Value type($result)=Is text)
					If ($mailType="JMAP")
						$response:=MAIL Convert from MIME($result)
					Else 
						$response:=$result
					End if 
				End if 
			End if 
			return $response
		End if 
		
	Else 
		
		Super._throwError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "office365.mail.getMail"})
	End if 
	
	return Null
	
	
	// ----------------------------------------------------
	
	
Function getMails($inParameters : Object) : cs.GraphMessageList
/**
 * @function getMails
 * @param {Object} $inParameters - Query options:
 *   - `folderId` {Text} — Folder ID to filter by
 *   - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`)
 *   - `filter`, `select`, `top`, `orderBy`, `skip` — standard OData parameters
 * @returns {cs.GraphMessageList} Pageable list of messages
 * @description Lists messages via `GET /me/messages` (or `/mailFolders/{id}/messages`)
 */
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId
	Else 
		$URL+="me"
	End if 
	If (Length(String($inParameters.folderId))>0)
		$URL+="/mailFolders/"+$inParameters.folderId
	End if 
	$URL+="/messages"
	
	var $headers : Object
	If (Length(String($inParameters.search))>0)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	
	var $urlParams : Text:=Super._getURLParamsFromObject($inParameters; True)
	$URL+=$urlParams
	
	return cs.GraphMessageList.new(This; This._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function move($inMailId : Text; $inFolderId : Text) : Object
/**
 * @function move
 * @param {Text} $inMailId - ID of the message to move
 * @param {Text} $inFolderId - Destination folder ID
 * @returns {Object} Status object; includes `id` of the moved message
 * @description Moves a message to another folder via
 *   `POST /me/messages/{id}/move`
 */
	
	Super._clearErrorStack()
	
	var $response : Object
	
	Try
		
		Case of 
			: (Type($inMailId)#Is text)
				Super._throwError(10; {which: "\"mailId\""; function: "office365.mail.move"})
				
			: (Length(String($inMailId))=0)
				Super._throwError(9; {which: "\"mailId\""; function: "office365.mail.move"})
				
			: (Type($inFolderId)#Is text)
				Super._throwError(10; {which: "\"folderId\""; function: "office365.mail.move"})
				
			: (Length(String($inFolderId))=0)
				Super._throwError(9; {which: "\"folderId\""; function: "office365.mail.move"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				If (Length(String(This.userId))>0)
					$URL+="users/"+This.userId
				Else 
					$URL+="me"
				End if 
				$URL+="/messages/"+$inMailId+"/move"
				
				var $headers : Object:={}
				var $body : Object:={destinationId: $inFolderId}
				
				$headers["Content-Type"]:="application/json"
				$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify($body))
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function reply($inMail : Object; $inMailId : Text; $bReplyAll : Boolean) : Object
/**
 * @function reply
 * @param {Object} $inMail - Reply body; for MIME/JMAP types, uses `$inMail.message`
 * @param {Text} $inMailId - ID of the message to reply to
 * @param {Boolean} $bReplyAll - When `True`, uses `replyAll`; otherwise uses `reply`
 * @returns {Object} Status object
 * @description Replies to a message via
 *   `POST /me/messages/{id}/reply` or `/replyAll`
 */
	
	Super._clearErrorStack()
	
	If ((Type($inMail)=Is object) && (Type($inMailId)=Is text) && (Length(String($inMailId))>0))
		
		var $URL : Text:=Super._getURL()
		If (Length(String(This.userId))>0)
			$URL+="users/"+This.userId
		Else 
			$URL+="me"
		End if 
		
		$URL+="/messages/"+$inMailId+(Bool($bReplyAll) ? "/replyAll" : "/reply")
		
		var $body : Variant
		If ((This.mailType="MIME") || (This.mailType="JMAP"))
			If (OB Is defined($inMail; "message"))
				$body:=$inMail.message
			End if 
		Else 
			$body:=$inMail
		End if 
		
		return This._postMessage("office365.mail.reply"; $URL; $body; True)
		
	Else 
		
		Try
			If (Type($inMail)#Is object)
				Super._throwError(10; {which: "\"reply\""; function: "office365.mail.reply"})
			Else 
				Super._throwError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "office365.mail.reply"})
			End if 
		Catch
			// Errors are already in _errorStack via _throwError
		End try
		
		return This._returnStatus()
	End if 
	
	
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
/**
 * @function send
 * @param {Variant} $inMail - Mail to send; type must match `mailType`
 * @returns {Object} Status object
 * @description Sends a mail message via `POST /me/sendMail`.
 *   For Microsoft Graph JSON payloads, attachments larger than 3 MiB are sent
 *   through draft + upload session workflow before final send.
 */
	
	Super._clearErrorStack()
	
	If ((This.mailType="Microsoft") && (Value type($inMail)=Is object) && This._hasLargeFileAttachment($inMail))
		return This._sendMailWithLargeAttachments($inMail)
	End if 
	
	var $URL : Text:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId+"/sendMail"
	Else 
		$URL+="me/sendMail"
	End if 
	
	return This._postMessage("office365.mail.send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
Function update($inMailId : Text; $inMail : Object) : Object
/**
 * @function update
 * @param {Text} $inMailId - ID of the message to update
 * @param {Object} $inMail - Partial message object with properties to update
 * @returns {Object} Status object
 * @description Updates message properties via `PATCH /me/messages/{id}`
 */
	
	Super._clearErrorStack()
	
	Try
		
		If ((Type($inMail)=Is object) && (Type($inMailId)=Is text) && (Length(String($inMailId))>0))
			
			var $response : Object
			var $URL : Text:=Super._getURL()
			
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/messages/"+$inMailId
			
			var $headers : Object:={}
			$headers["Content-Type"]:="application/json"
			$response:=Super._sendRequestAndWaitResponse("PATCH"; $URL; $headers; JSON Stringify($inMail))
			
		Else 
			
			If (Type($inMail)#Is object)
				
				Super._throwError(10; {which: "\"mail\""; function: "office365.mail.update"})
			Else 
				
				Super._throwError((Length(String($inMailId))=0) ? 9 : 10; {which: "\"mailId\""; function: "office365.mail.update"})
			End if 
		End if 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus()
	
	
	// Mark: - Folders
	// ----------------------------------------------------
	
	
Function createFolder($inFolderName : Text; $bIsHidden : Boolean; $inParentFolderId : Text) : Object
/**
 * @function createFolder
 * @param {Text} $inFolderName - Display name for the new folder
 * @param {Boolean} $bIsHidden - When `True`, the folder is hidden
 * @param {Text} $inParentFolderId - Parent folder ID; creates a top-level folder when empty
 * @returns {Object} Status object; includes `id` of the created folder
 * @description Creates a mail folder via `POST /me/mailFolders` (or `/childFolders`)
 */
	
	Super._clearErrorStack()
	
	var $response : Object
	
	Try
		
		Case of 
			: (Type($inFolderName)#Is text)
				Super._throwError(10; {which: "\"folderName\""; function: "office365.mail.createFolder"})
				
			: (Length(String($inFolderName))=0)
				Super._throwError(9; {which: "\"folderName\""; function: "office365.mail.createFolder"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				
				If (Length(String(This.userId))>0)
					$URL+="users/"+This.userId
				Else 
					$URL+="me"
				End if 
				$URL+="/mailFolders"
				If (Length(String($inParentFolderId))>0)
					$URL+="/"+$inParentFolderId+"/childFolders"
				End if 
				
				var $headers : Object:={}
				var $body : Object:={displayName: $inFolderName; isHidden: ($bIsHidden ? "true" : "false")}
				
				$headers["Content-Type"]:="application/json"
				$response:=Super._sendRequestAndWaitResponse("POST"; $URL; $headers; JSON Stringify($body))
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// ----------------------------------------------------
	
	
Function deleteFolder($inFolderId : Text) : Object
/**
 * @function deleteFolder
 * @param {Text} $inFolderId - ID of the folder to delete
 * @returns {Object} Status object
 * @description Permanently deletes a mail folder via `DELETE /me/mailFolders/{id}`
 */
	
	Super._clearErrorStack()
	
	Try
		
		Case of 
			: (Type($inFolderId)#Is text)
				Super._throwError(10; {which: "\"folderId\""; function: "office365.mail.deleteFolder"})
				
			: (Length(String($inFolderId))=0)
				Super._throwError(9; {which: "\"folderId\""; function: "office365.mail.deleteFolder"})
				
			Else 
				
				var $URL : Text:=Super._getURL()
				
				If (Length(String(This.userId))>0)
					$URL+="users/"+This.userId
				Else 
					$URL+="me"
				End if 
				$URL+="/mailFolders/"+$inFolderId
				
				Super._sendRequestAndWaitResponse("DELETE"; $URL)
				
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus()
	
	
	// ----------------------------------------------------
	
	
Function getFolder($inFolderId : Text) : Object
/**
 * @function getFolder
 * @param {Text} $inFolderId - ID of the folder to retrieve
 * @returns {Object} Cleaned folder object, or `Null` on error
 * @description Fetches a single mail folder via `GET /me/mailFolders/{id}`
 */
	
	var $response : Object
	
	Super._clearErrorStack()
	
	Case of 
		: (Type($inFolderId)#Is text)
			Super._throwError(10; {which: "\"folderId\""; function: "office365.mail.getFolder"})
			
		: (Length(String($inFolderId))=0)
			Super._throwError(9; {which: "\"folderId\""; function: "office365.mail.getFolder"})
			
		Else 
			
			var $URL : Text:=Super._getURL()
			
			If (Length(String(This.userId))>0)
				$URL+="users/"+This.userId
			Else 
				$URL+="me"
			End if 
			$URL+="/mailFolders/"+$inFolderId
			
			$response:=Super._sendRequestAndWaitResponse("GET"; $URL)
			
	End case 
	
	return cs._Tools.me.cleanGraphObject($response)
	
	
	// ----------------------------------------------------
	
	
Function getFolderList($inParameters : Object) : cs.GraphFolderList
/**
 * @function getFolderList
 * @param {Object} $inParameters - Query options:
 *   - `folderId` {Text} — Parent folder ID to list child folders
 *   - `search`, `filter`, `select`, `top`, `orderBy` — standard OData parameters
 * @returns {cs.GraphFolderList} Pageable list of mail folders
 * @description Lists mail folders via `GET /me/mailFolders`
 *   (or `/mailFolders/{id}/childFolders`)
 */
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId
	Else 
		$URL+="me"
	End if 
	$URL+="/mailFolders"
	If (Length(String($inParameters.folderId))>0)
		$URL+="/"+$inParameters.folderId+"/childFolders"
	End if 
	
	If (Length(String($inParameters.search))>0)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	
	var $headers : Object
	var $urlParams : Text:=Super._getURLParamsFromObject($inParameters; True)
	$URL+=$urlParams
	
	return cs.GraphFolderList.new(This._getOAuth2Provider(); $URL; $headers)
	
	
	// ----------------------------------------------------
	
	
Function renameFolder($inFolderId : Text; $inNewFolderName : Text) : Object
/**
 * @function renameFolder
 * @param {Text} $inFolderId - ID of the folder to rename
 * @param {Text} $inNewFolderName - New display name for the folder
 * @returns {Object} Status object; includes `id` of the renamed folder
 * @description Renames a mail folder via `PATCH /me/mailFolders/{id}`
 */
	
	Super._clearErrorStack()
	
	var $response : Object
	
	Try
		
		Case of 
			: (Type($inFolderId)#Is text)
				Super._throwError(10; {which: "\"folderId\""; function: "office365.mail.renameFolder"})
				
			: (Length(String($inFolderId))=0)
				Super._throwError(9; {which: "\"folderId\""; function: "office365.mail.renameFolder"})
				
			: (Type($inNewFolderName)#Is text)
				Super._throwError(10; {which: "\"folderName\""; function: "office365.mail.renameFolder"})
				
			: (Length(String($inNewFolderName))=0)
				Super._throwError(9; {which: "\"folderName\""; function: "office365.mail.renameFolder"})
			Else 
				
				var $URL : Text:=Super._getURL()
				
				If (Length(String(This.userId))>0)
					$URL+="users/"+This.userId
				Else 
					$URL+="me"
				End if 
				$URL+="/mailFolders/"+$inFolderId
				
				var $headers : Object:={}
				var $body : Object:={displayName: $inNewFolderName}
				
				$headers["Content-Type"]:="application/json"
				$response:=Super._sendRequestAndWaitResponse("PATCH"; $URL; $headers; JSON Stringify($body))
				
		End case 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return This._returnStatus((Length(String($response.id))>0) ? {id: $response.id} : Null)
	
	
	// Mark: - Notifications
	// ----------------------------------------------------
	
	
Function notifier($inParameters : Object; $inFolderId : Text) : cs.GraphNotification
/**
 * @function notifier
 * @param {Object} $inParameters - Notification callbacks and options:
 *   - `onCreate` {4D.Function} — Called when a mail is created; receives the `mailId`
 *   - `onDelete` {4D.Function} — Called when a mail is deleted; receives the `mailId`
 *   - `onModify` {4D.Function} — Called when a mail is modified; receives the `mailId`
 *   - `endPoint` {Text} — Webhook URL for push mode; omit to use pull (delta query) mode
 * @param {Text} $inFolderId - Folder to subscribe to; defaults to `inbox` when empty
 * @returns {cs.GraphNotification} Notification object with `start()`, `stop()`,
 *   `expiration`, and `isStarted`
 * @description Creates a `GraphNotification` for mail change notifications via the
 *   Microsoft Graph subscription API. See inline comment for full parameter details.
 */
	
/*
	Creates a notification object for mail change notifications.
	
	The notification object can be started and stopped. When started, it creates
	a Microsoft Graph subscription and dispatches callbacks when changes are detected.
	The subscription is automatically renewed before expiration.
	
	Parameters:
	    $inParameters.onCreate : 4D.Function - Called when a mail is created. Receives the mailId.
	    $inParameters.onDelete : 4D.Function - Called when a mail is deleted. Receives the mailId.
	    $inParameters.onModify : 4D.Function - Called when a mail is modified. Receives the mailId.
	    $inParameters.endPoint : Text - Optional. Webhook URL for push mode. If omitted, uses pull (delta query) mode.
	    $inFolderId : Text - Optional. Folder ID to subscribe to. If omitted, subscribes to all folders.
	
	Returns:
	    cs.GraphNotification object with start(), stop(), expiration and isStarted.
	
	See: https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions
*/
	
	// Build the resource path for the subscription
	var $resource : Text
	If (Length(String(This.userId))>0)
		$resource:="users/"+This.userId
	Else 
		$resource:="me"
	End if 
	If (Length(String($inFolderId))>0)
		$resource+="/mailFolders/"+$inFolderId
	Else 
		$resource+="/mailFolders/inbox"
	End if 
	$resource+="/messages"
	
	return cs.GraphNotification.new("mail"; This._getOAuth2Provider(); $inParameters; $resource; This.userId; This)
