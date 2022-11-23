Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParams : Object; $inObject : Object)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._userId:=String:C10($inParams.userId)
	This:C1470._internals._messageId:=String:C10($inParams.messageId)
	Super:C1706._loadFromObject(Super:C1706._cleanResponseObject($inObject))
	This:C1470["@odata.type"]:="#microsoft.graph.fileAttachment"
	
	
	// ----------------------------------------------------
	
	
Function getContent() : 4D:C1709.Blob
	
	var $contentBytes : Blob
	
	If (Not:C34(OB Is defined:C1231(This:C1470; "contentBytes")))
		
		If ((Length:C16(String:C10(This:C1470._internals._messageId))>0) & \
			(Length:C16(String:C10(This:C1470._internals._userId))>0))
			
			var $response : Object
			var $urlParams; $URL : Text
			
			If (Length:C16(String:C10(This:C1470._internals._userId))>0)
				$urlParams:="users/"+This:C1470._internals._userId
			Else 
				$urlParams:="me"
			End if 
			$urlParams+="/messages/"+This:C1470._internals._messageId
			$urlParams+="/attachments/"+This:C1470.id
			
			$URL:=Super:C1706._getURL()+$urlParams
			$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
			
			If ($response#Null:C1517)
				If (OB Is defined:C1231($response; "contentBytes"))
					This:C1470.contentBytes:=$response.contentBytes
				End if 
			End if 
			
		End if 
	End if 
	
	If (OB Is defined:C1231(This:C1470; "contentBytes"))
		BASE64 DECODE:C896(This:C1470.contentBytes; $contentBytes)
	End if 
	
	return 4D:C1709.Blob.new($contentBytes)
	