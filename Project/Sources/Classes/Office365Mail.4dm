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

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `mailType` {Text} — Mail format: `"Microsoft"` (default), `"JMAP"`, or `"MIME"`
 *   - `userId` {Text} — Graph user ID or UPN; defaults to `""` (uses `me` endpoint)
 */
Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	This.mailType:=(Length(String($inParameters.mailType))>0) ? String($inParameters.mailType) : "Microsoft"
	This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
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
Function _postJSONMessage($inURL : Text; $inMail : Object; $bSkipMessageEncapsulation : Boolean; $inHeaders : Object) : Object
	
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
Function _postMailMIMEMessage($inURL : Text; $inMail : Variant) : Object
	
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
Function _postMessage($inFunction : Text; $inURL : Text; $inMail : Variant; $bSkipMessageEncapsulation : Boolean; $inHeader : Object) : Object
	
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
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
/**
 * @function append
 * @param {Variant} $inMail - Mail to save; type must match `mailType`
 * @param {Text} $inFolderId - Target folder ID; uses `me/messages` (draft) when empty
 * @returns {Object} Status object; includes `id` of the saved message
 * @description Saves a message to a mail folder without sending it via
 *   `POST /me/mailFolders/{id}/messages` (or `/users/{id}/...`)
 */
Function append($inMail : Variant; $inFolderId : Text) : Object
	
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
	
	
/**
 * @function copy
 * @param {Text} $inMailId - ID of the message to copy
 * @param {Text} $inFolderId - Destination folder ID
 * @returns {Object} Status object; includes `id` of the new copy
 * @description Copies a message to another folder via
 *   `POST /me/messages/{id}/copy`
 */
Function copy($inMailId : Text; $inFolderId : Text) : Object
	
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
	
	
/**
 * @function delete
 * @param {Text} $inMailId - ID of the message to delete permanently
 * @returns {Object} Status object
 * @description Permanently deletes a message via `DELETE /me/messages/{id}`
 */
Function delete($inMailId : Text) : Object
	
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
Function getMail($inMailId : Text; $inOptions : Object) : Variant
	
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
	
	
/**
 * @function getMails
 * @param {Object} $inParameters - Query options:
 *   - `folderId` {Text} — Folder ID to filter by
 *   - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`)
 *   - `filter`, `select`, `top`, `orderBy`, `skip` — standard OData parameters
 * @returns {cs.GraphMessageList} Pageable list of messages
 * @description Lists messages via `GET /me/messages` (or `/mailFolders/{id}/messages`)
 */
Function getMails($inParameters : Object) : Object
	
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
	
	
/**
 * @function move
 * @param {Text} $inMailId - ID of the message to move
 * @param {Text} $inFolderId - Destination folder ID
 * @returns {Object} Status object; includes `id` of the moved message
 * @description Moves a message to another folder via
 *   `POST /me/messages/{id}/move`
 */
Function move($inMailId : Text; $inFolderId : Text) : Object
	
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
	
	
/**
 * @function reply
 * @param {Object} $inMail - Reply body; for MIME/JMAP types, uses `$inMail.message`
 * @param {Text} $inMailId - ID of the message to reply to
 * @param {Boolean} $bReplyAll - When `True`, uses `replyAll`; otherwise uses `reply`
 * @returns {Object} Status object
 * @description Replies to a message via
 *   `POST /me/messages/{id}/reply` or `/replyAll`
 */
Function reply($inMail : Object; $inMailId : Text; $bReplyAll : Boolean) : Object
	
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
	
	
/**
 * @function send
 * @param {Variant} $inMail - Mail to send; type must match `mailType`
 * @returns {Object} Status object
 * @description Sends a mail message via `POST /me/sendMail`
 */
Function send($inMail : Variant) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	If (Length(String(This.userId))>0)
		$URL+="users/"+This.userId+"/sendMail"
	Else 
		$URL+="me/sendMail"
	End if 
	
	return This._postMessage("office365.mail.send"; $URL; $inMail)
	
	
	// ----------------------------------------------------
	
	
/**
 * @function update
 * @param {Text} $inMailId - ID of the message to update
 * @param {Object} $inMail - Partial message object with properties to update
 * @returns {Object} Status object
 * @description Updates message properties via `PATCH /me/messages/{id}`
 */
Function update($inMailId : Text; $inMail : Object) : Object
	
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
	
	
/**
 * @function createFolder
 * @param {Text} $inFolderName - Display name for the new folder
 * @param {Boolean} $bIsHidden - When `True`, the folder is hidden
 * @param {Text} $inParentFolderId - Parent folder ID; creates a top-level folder when empty
 * @returns {Object} Status object; includes `id` of the created folder
 * @description Creates a mail folder via `POST /me/mailFolders` (or `/childFolders`)
 */
Function createFolder($inFolderName : Text; $bIsHidden : Boolean; $inParentFolderId : Text) : Object
	
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
	
	
/**
 * @function deleteFolder
 * @param {Text} $inFolderId - ID of the folder to delete
 * @returns {Object} Status object
 * @description Permanently deletes a mail folder via `DELETE /me/mailFolders/{id}`
 */
Function deleteFolder($inFolderId : Text) : Object
	
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
	
	
/**
 * @function getFolder
 * @param {Text} $inFolderId - ID of the folder to retrieve
 * @returns {Object} Cleaned folder object, or `Null` on error
 * @description Fetches a single mail folder via `GET /me/mailFolders/{id}`
 */
Function getFolder($inFolderId : Text) : Object
	
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
	
	
/**
 * @function getFolderList
 * @param {Object} $inParameters - Query options:
 *   - `folderId` {Text} — Parent folder ID to list child folders
 *   - `search`, `filter`, `select`, `top`, `orderBy` — standard OData parameters
 * @returns {cs.GraphFolderList} Pageable list of mail folders
 * @description Lists mail folders via `GET /me/mailFolders`
 *   (or `/mailFolders/{id}/childFolders`)
 */
Function getFolderList($inParameters : Object) : Object
	
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
	
	
/**
 * @function renameFolder
 * @param {Text} $inFolderId - ID of the folder to rename
 * @param {Text} $inNewFolderName - New display name for the folder
 * @returns {Object} Status object; includes `id` of the renamed folder
 * @description Renames a mail folder via `PATCH /me/mailFolders/{id}`
 */
Function renameFolder($inFolderId : Text; $inNewFolderName : Text) : Object
	
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
Function notifier($inParameters : Object; $inFolderId : Text) : cs.GraphNotification
	
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
