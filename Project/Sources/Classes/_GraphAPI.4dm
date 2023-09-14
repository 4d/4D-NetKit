Class extends _BaseAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._URL:="https://graph.microsoft.com/v1.0/"
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _cleanGraphObject($ioObject : Object) : Object
	
	var $keys : Collection
	var $key : Text
	
	$keys:=OB Keys:C1719($ioObject)
	For each ($key; $keys)
		If ((Position:C15("@"; $key)=1) || ($ioObject[$key]=Null:C1517))
			OB REMOVE:C1226($ioObject; $key)
		End if 
	End for each 
	
	return $ioObject
	
	
	// ----------------------------------------------------
	
	
Function _copyGraphMessage($inMessage : Object) : Object
	
	If (OB Instance of:C1731($inMessage; cs:C1710.GraphMessage))
		
		var $message : Object
		var $keys : Collection
		var $key : Text
		var $iter; $attachment : Object
		
		$message:=New object:C1471
		If (OB Is defined:C1231($inMessage; "attachments") && ($inMessage.attachments#Null:C1517))
			$message.attachments:=New collection:C1472
		End if 
		$keys:=OB Keys:C1719($inMessage)
		For each ($key; $keys)
			
			Case of 
				: (($key="_internals") || (Position:C15("@"; $key)=1) || ($key="webLink"))
					// do not copy
					
				: ($key="attachments")
					For each ($iter; $inMessage.attachments)
						$attachment:=_convertToGraphAttachment($iter)
						$message.attachments.push($attachment)
					End for each 
					
				Else 
					$message[$key]:=$inMessage[$key]
					
			End case 
			
		End for each 
		
		return $message
		
	Else 
		
		return $inMessage
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromObject($inObject : Object)
	
	If (($inObject#Null:C1517) & (Not:C34(OB Is empty:C1297($inObject))))
		
		var $key : Text
		var $keys : Collection
		
		$keys:=OB Keys:C1719($inObject)
		
		For each ($key; $keys)
			This:C1470[$key]:=$inObject[$key]
		End for each 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
	
	var $urlParams; $delimiter : Text
	
	$urlParams:=""
	$delimiter:="?"
	If (Bool:C1537($inParameters.includeHiddenFolders))
		$urlParams+="/"+$delimiter+"includeHiddenFolders=true"
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.search))>0)
		$urlParams+=$delimiter+"$search="+$inParameters.search
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.filter))>0)
		$urlParams+=$delimiter+"$filter="+$inParameters.filter
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.select))>0)
		$urlParams+=$delimiter+"$select="+$inParameters.select
		$delimiter:="&"
	End if 
	If (Not:C34(Value type:C1509($inParameters.top)=Is undefined:K8:13))
		$urlParams+=$delimiter+"$top="+Choose:C955(Value type:C1509($inParameters.top)=Is text:K8:3; \
			$inParameters.top; String:C10($inParameters.top))
		$delimiter:="&"
	End if 
	If (Length:C16(String:C10($inParameters.orderBy))>0)
		$urlParams+=$delimiter+"$orderBy="+$inParameters.orderBy
		$delimiter:="&"
	End if 
	If (Bool($inCount))
		$urlParams+=$delimiter+"$count=true"
		$delimiter:="&"
	End if 
	
	return $urlParams
	