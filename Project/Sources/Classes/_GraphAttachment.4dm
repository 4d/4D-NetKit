Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inUserId : Text; $inMessageId : Text; $inObject : Object)
	
	Super:C1705($inProvider)
	
	This:C1470["@odata.type"]:="#microsoft.graph.fileAttachment"
	This:C1470.userId:=$inUserId
	This:C1470.messageId:=$inMessageId
	Super:C1706._loadFromObject($inObject)
	
	
	// ----------------------------------------------------
	
	
Function getContent() : 4D:C1709.Blob
	
	var $contentBytes : Blob
	
	If (OB Is defined:C1231(This:C1470; "contentBytes"))
		BASE64 DECODE:C896(This:C1470.contentBytes; $contentBytes)
	Else 
		If ((Length:C16(String:C10(This:C1470.messageId))>0) & \
			(Length:C16(String:C10(This:C1470.id))>0))
			
			var $response : Object
			var $urlParams; $URL : Text
			
			If (Length:C16(String:C10(This:C1470.userId))>0)
				$urlParams:="users/"+This:C1470.userId
			Else 
				$urlParams:="me"
			End if 
			$urlParams+="/messages/"+This:C1470.messageId
			$urlParams+="/attachments/"+This:C1470.id
			
			$URL:=Super:C1706._getURL()+$urlParams
			$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
			
			If ($response#Null:C1517)
				If (OB Is defined:C1231($response; "contentBytes"))
					BASE64 DECODE:C896($response.contentBytes; $contentBytes)
				End if 
			End if 
			
		End if 
	End if 
	
	return 4D:C1709.Blob.new($contentBytes)
	