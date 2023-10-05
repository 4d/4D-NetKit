Class extends _GraphAPI

property id : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object; $inObject : Object)
	
	Super($inProvider)
	
	This._internals._mailType:=(Length(String($inParameters.mailType))>0) ? $inParameters.mailType : "Microsoft"
	This._internals._userId:=String($inParameters.userId)
	This._internals._attachments:=Null
	Super._loadFromObject($inObject)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get attachments() : Collection
	
	If (This._internals._attachments=Null)
/*
	Try to retrieve attachments even if .hasAttachments is False
	See: https://learn.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0
		
	".hasAttachments: This property doesn't include inline attachments, so if a message contains 
	 only inline attachments, this property is false."
*/
		var $urlParams; $URL : Text
		
		If (Length(String(This._internals._userId))>0)
			$urlParams:="users/"+This._internals._userId
		Else 
			$urlParams:="me"
		End if 
		$urlParams+="/messages/"+String(This.id)+\
			"/attachments/?select=id,contentType,isInline,name,size,lastModifiedDateTime&$top=999"
		
		$URL:=Super._getURL()+$urlParams
		var $response; $iter : Object
		$response:=Super._sendRequestAndWaitResponse("GET"; $URL)
		
		This._internals._attachments:=[]
		If ($response#Null)
			var $attachments : Collection
			$attachments:=$response["value"]
			For each ($iter; $attachments)
				var $attachment : Object
				$attachment:=cs.GraphAttachment.new(This._getOAuth2Provider(); \
					{userId: String(This._internals._userId); messageId: String(This.id)}; \
					$iter)
				This._internals._attachments.push($attachment)
			End for each 
		End if 
		
	End if 
	
	return This._internals._attachments
