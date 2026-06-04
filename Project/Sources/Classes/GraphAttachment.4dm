/**
 * @class GraphAttachment
 * @description Represents a Microsoft Graph file attachment on a message or calendar event.
 *   `contentBytes` is fetched lazily via `getContent()` when not already present.
 *   Can be built from a `4D.MailAttachment` via `fromMailAttachment()`.
 */

Class extends _GraphAPI

property id : Text
property contentBytes : Text
property size : Integer
property contentId : Text
property isInline : Boolean
property name : Text
property contentType : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParams : Object; $inObject : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParams - Context:
 *   - `userId` {Text} — Graph user ID or UPN
 *   - `messageId` {Text} — Parent message ID (exclusive with `eventId`)
 *   - `eventId` {Text} — Parent event ID (exclusive with `messageId`)
 * @param {Object} $inObject - Raw Graph API attachment object to hydrate from
 */
	
	Super($inProvider)
	
	This._internals._userId:=String($inParams.userId)
	Case of 
		: (Length(String($inParams.messageId))>0)
			This._internals._messageId:=String($inParams.messageId)
		: (Length(String(This._internals._eventId))>0)
			This._internals._eventId:=String($inParams.eventId)
	End case 
	Super._loadFromObject($inObject)
	If (Length(String(This["@odata.type"]))=0)
		This["@odata.type"]:="#microsoft.graph.fileAttachment"
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getContent() : 4D.Blob
/**
 * @function getContent
 * @returns {4D.Blob} Attachment content as a `4D.Blob`;
 *   `contentBytes` is fetched from the Graph API on first call when absent.
 *   For `itemAttachment` types, the item is JSON-stringified and base64-encoded.
 * @description Downloads attachment bytes via
 *   `GET /me/messages/{id}/attachments/{attachmentId}` or
 *   `GET /me/events/{id}/attachments/{attachmentId}`
 */
	
	If (Not(OB Is defined(This; "contentBytes")))
		
		var $urlParams : Text
		
		Case of 
			: (Length(String(This._internals._messageId))>0)
				If (Length(String(This._internals._userId))>0)
					$urlParams:="users/"+This._internals._userId
				Else 
					$urlParams:="me"
				End if 
				$urlParams+="/messages/"+This._internals._messageId
				$urlParams+="/attachments/"+This.id
			: (Length(String(This._internals._eventId))>0)
				If (Length(String(This._internals._userId))>0)
					$urlParams:="users/"+This._internals._userId
				Else 
					$urlParams:="me"
				End if 
				$urlParams+="/events/"+This._internals._eventId
				$urlParams+="/attachments/"+This.id
		End case 
		
		var $URL : Text:=Super._getURL()+$urlParams
		If (This["@odata.type"]="#microsoft.graph.itemAttachment")
			$URL+="/?$expand=microsoft.graph.itemattachment/item"
		End if 
		
		var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL)
		If ($response#Null)
			If (OB Is defined($response; "contentBytes"))
				This.contentBytes:=$response.contentBytes
			Else 
				If (OB Is defined($response; "item"))
					var $stringContent : Text
					BASE64 ENCODE(JSON Stringify($response.item); $stringContent)
					This.contentBytes:=$stringContent
				End if 
			End if 
			
		End if 
	End if 
	
	var $contentBytes : Blob
	If (OB Is defined(This; "contentBytes"))
		BASE64 DECODE(This.contentBytes; $contentBytes)
	End if 
	
	return 4D.Blob.new($contentBytes)
	
	
	// ----------------------------------------------------
	
	
Function setContent($inContent : 4D.Blob)
/**
 * @function setContent
 * @param {4D.Blob} $inContent - Binary content to attach
 * @description Base64-encodes `$inContent` and stores it in `contentBytes`;
 *   also updates `size`. No-op when the blob is empty.
 */
	
	If ($inContent.size>0)
		var $encodedContent : Text
		BASE64 ENCODE($inContent.slice(); $encodedContent)
		This.contentBytes:=$encodedContent
		This.size:=Length($encodedContent)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function fromMailAttachment($inObject : 4D.MailAttachment)
/**
 * @function fromMailAttachment
 * @param {4D.MailAttachment} $inObject - 4D mail attachment to convert
 * @description Populates `This` from a `4D.MailAttachment`; sets `@odata.type`,
 *   `contentId`, `isInline`, `name`, `contentType`, and `contentBytes`.
 *   No-op when `$inObject` is not a `4D.MailAttachment` instance.
 */
	
	If (OB Instance of($inObject; 4D.MailAttachment))
		
		This["@odata.type"]:="#microsoft.graph.fileAttachment"
		If (Length(String($inObject.cid))>0)
			This.contentId:=String($inObject.cid)
		End if 
		If (String($inObject.disposition)="inline")
			This.isInline:=True
		End if 
		If (Length(String($inObject.name))>0)
			This.name:=String($inObject.name)
		End if 
		If (Length(String($inObject.type))>0)
			This.contentType:=String($inObject.type)
		End if 
		
		This.setContent($inObject.getContent())
		
	End if 
