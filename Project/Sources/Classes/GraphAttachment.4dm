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
		
		If (Length:C16(String:C10(This:C1470._internals._messageId))>0)
			
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
				Else 
					If ($response["@odata.type"]="#microsoft.graph.itemAttachment")
						$URL+="/?$expand=microsoft.graph.itemattachment/item"
						$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
						If ($response#Null:C1517)
							If (OB Is defined:C1231($response; "contentBytes"))
								This:C1470.contentBytes:=$response.contentBytes
							End if 
						End if 
					End if 
				End if 
				
			End if 
		End if 
		
		If (OB Is defined:C1231(This:C1470; "contentBytes"))
			BASE64 DECODE:C896(This:C1470.contentBytes; $contentBytes)
		End if 
		
		return 4D:C1709.Blob.new($contentBytes)
		
		
		// ----------------------------------------------------
		
		
Function setContent($inContent : 4D:C1709.Blob)
	
	If ($inContent.size>0)
		var $encodedContent : Text
		BASE64 ENCODE:C895($inContent.slice(); $encodedContent)
		This:C1470.contentBytes:=$encodedContent
		This:C1470.size:=Length:C16($encodedContent)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function fromMailAttachment($inObject : 4D:C1709.MailAttachment)
	
	If (OB Instance of:C1731($inObject; 4D:C1709.MailAttachment))
		
		This:C1470["@odata.type"]:="#microsoft.graph.fileAttachment"
		If (Length:C16(String:C10($inObject.cid))>0)
			This:C1470.contentId:=String:C10($inObject.cid)
		End if 
		If (String:C10($inObject.disposition)="inline")
			This:C1470.isInline:=True:C214
		End if 
		If (Length:C16(String:C10($inObject.name))>0)
			This:C1470.name:=String:C10($inObject.name)
		End if 
		If (Length:C16(String:C10($inObject.type))>0)
			This:C1470.contentType:=String:C10($inObject.type)
		End if 
		
		This:C1470.setContent($inObject.getContent())
		
	End if 
	