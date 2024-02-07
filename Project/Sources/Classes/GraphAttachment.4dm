Class extends _GraphAPI

property id : Text
property contentBytes : Text
property size : Integer
property contentId : Text
property isInline : Boolean
property name : Text
property contentType : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParams : Object; $inObject : Object)
	
	Super($inProvider)
	
	This._internals._userId:=String($inParams.userId)
	This._internals._messageId:=String($inParams.messageId)
	Super._loadFromObject($inObject)
	If (Length(String(This["@odata.type"]))=0)
		This["@odata.type"]:="#microsoft.graph.fileAttachment"
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getContent() : 4D.Blob
	
	If (Not(OB Is defined(This; "contentBytes")))
		
		If (Length(String(This._internals._messageId))>0)
			
			var $urlParams : Text
			
			If (Length(String(This._internals._userId))>0)
				$urlParams:="users/"+This._internals._userId
			Else 
				$urlParams:="me"
			End if 
			$urlParams+="/messages/"+This._internals._messageId
			$urlParams+="/attachments/"+This.id
			
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
	End if 
	
	var $contentBytes : Blob
	If (OB Is defined(This; "contentBytes"))
		BASE64 DECODE(This.contentBytes; $contentBytes)
	End if 
	
	return 4D.Blob.new($contentBytes)
	
	
	// ----------------------------------------------------
	
	
Function setContent($inContent : 4D.Blob)
	
	If ($inContent.size>0)
		var $encodedContent : Text
		BASE64 ENCODE($inContent.slice(); $encodedContent)
		This.contentBytes:=$encodedContent
		This.size:=Length($encodedContent)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function fromMailAttachment($inObject : 4D.MailAttachment)
	
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
