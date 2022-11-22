Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object; $inObject : Object)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? $inParameters.mailType : "Microsoft"
	This:C1470._internals._userId:=String:C10($inParameters.userId)
	This:C1470._internals._withAttachments:=String:C10($inParameters.withAttachments)
	This:C1470._internals._attachments:=Null:C1517
	Super:C1706._loadFromObject($inObject)
	
	
	// ----------------------------------------------------
	
	
Function get attachments() : Collection
	
	If (This:C1470._internals._withAttachments)
		
		If (This:C1470._internals._attachments=Null:C1517)
/*
Try to retrieve attachments even if .hasAttachments is False
See: https://learn.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0
		
".hasAttachments: This property doesn't include inline attachments, so if a message contains 
 only inline attachments, this property is false."
*/
			var $urlParams; $URL : Text
			
			If (Length:C16(String:C10(This:C1470._internals._userId))>0)
				$urlParams:="users/"+This:C1470._internals._userId
			Else 
				$urlParams:="me"
			End if 
			$urlParams+="/messages/"+String:C10(This:C1470.id)+\
				"/attachments/?select=id,contentType,isInline,name,size,lastModifiedDateTime&$top=999"
			
			$URL:=Super:C1706._getURL()+$urlParams
			var $response; $iter : Object
			$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
			
			This:C1470._internals._attachments:=New collection:C1472
			If ($response#Null:C1517)
				var $attachments : Collection
				$attachments:=$response["value"]
				For each ($iter; $attachments)
					var $attachment : Object
					$attachment:=cs:C1710._GraphAttachment.new(This:C1470._getOAuth2Provider(); \
						New object:C1471("userId"; String:C10(This:C1470._internals._userId); "messageId"; String:C10(This:C1470.id)); \
						$iter)
					This:C1470._internals._attachments.push($attachment)
				End for each 
			End if 
			
		End if 
		
	End if 
	
	return This:C1470._internals._attachments
	