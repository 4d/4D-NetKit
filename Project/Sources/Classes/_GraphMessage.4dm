Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "Microsoft"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	This:C1470._internals._attachments:=Null:C1517
	
	
	// ----------------------------------------------------
	
	
Function get attachments() : Object
	
	
	If (This:C1470._attachments=Null:C1517)
		If (Bool:C1537(This:C1470.hasAttachments))
			var $urlParams; $URL : Text
			
			If (Length:C16(String:C10(This:C1470.userId))>0)
				$urlParams:="users/"+This:C1470.userId
			Else 
				$urlParams:="me"
			End if 
			$urlParams+="/messages/"+String:C10(This:C1470.id)+"/attachments/"
			
			$URL:=Super:C1706._getURL()+$urlParams
			This:C1470._attachments:=cs:C1710._GraphAttachmentList.new(This:C1470; This:C1470._getOAuth2Provider(); $URL)
			
		End if 
	End if 
	
	return This:C1470._attachments
	