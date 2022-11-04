Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "Microsoft"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	This:C1470._internals._attachments:=Null:C1517
	
	
	// ----------------------------------------------------
	
	
Function get attachments() : Collection
	
	
	If (This:C1470._internals._attachments=Null:C1517)
		If (Bool:C1537(This:C1470.hasAttachments))
			var $urlParams; $URL : Text
			
			If (Length:C16(String:C10(This:C1470.userId))>0)
				$urlParams:="users/"+This:C1470.userId
			Else 
				$urlParams:="me"
			End if 
			$urlParams+="/messages/"+String:C10(This:C1470.id)+"/attachments/?$top=999"
			
			$URL:=Super:C1706._getURL()+$urlParams
			var $response; $iter : Object
			$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
			
			This:C1470._internals._attachments:=New collection:C1472
			If ($response#Null:C1517)
				var $attachments : Collection
				$attachments:=$response["value"]
				For each ($iter; $attachments)
					var $attachment : Object
					$attachment:=cs:C1710._GraphAttachment.new(This:C1470._getOAuth2Provider(); New object:C1471("userId"; This:C1470._internals._mail.userId))
					$attachment._loadFromObject($iter)
					This:C1470._internals._attachments.push($attachment)
				End for each 
			End if 
			
		End if 
	End if 
	
	return This:C1470._internals._attachments
	