Class extends _BaseAPI

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	This._internals._URL:="https://graph.microsoft.com/v1.0/"
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _cleanGraphObject($ioObject : Object) : Object
	
	var $keys : Collection
	var $key : Text
	
	$keys:=OB Keys($ioObject)
	For each ($key; $keys)
		If ((Position("@"; $key)=1) || ($ioObject[$key]=Null))
			OB REMOVE($ioObject; $key)
		End if 
	End for each 
	
	return $ioObject
	
	
	// ----------------------------------------------------
	
	
Function _copyGraphMessage($inMessage : Object) : Object
	
	If (OB Instance of($inMessage; cs.GraphMessage))
		
		var $message : Object
		var $keys : Collection
		var $key : Text
		var $iter; $attachment : Object
		
		$message:=New object
		If (OB Is defined($inMessage; "attachments") && ($inMessage.attachments#Null))
			$message.attachments:=New collection
		End if 
		$keys:=OB Keys($inMessage)
		For each ($key; $keys)
			
			Case of 
				: (($key="_internals") || (Position("@"; $key)=1) || ($key="webLink"))
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
	
	If (($inObject#Null) & (Not(OB Is empty($inObject))))
		
		var $key : Text
		var $keys : Collection
		
		$keys:=OB Keys($inObject)
		
		For each ($key; $keys)
			This[$key]:=$inObject[$key]
		End for each 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
	
	var $urlParams; $delimiter : Text
	
	$urlParams:=""
	$delimiter:="?"
	If (Bool($inParameters.includeHiddenFolders))
		$urlParams+="/"+$delimiter+"includeHiddenFolders=true"
		$delimiter:="&"
	End if 
	If (Length(String($inParameters.search))>0)
		$urlParams+=$delimiter+"$search="+$inParameters.search
		$delimiter:="&"
	End if 
	If (Length(String($inParameters.filter))>0)
		$urlParams+=$delimiter+"$filter="+$inParameters.filter
		$delimiter:="&"
	End if 
	If (Length(String($inParameters.select))>0)
		$urlParams+=$delimiter+"$select="+$inParameters.select
		$delimiter:="&"
	End if 
	If (Not(Value type($inParameters.top)=Is undefined))
		$urlParams+=$delimiter+"$top="+Choose(Value type($inParameters.top)=Is text; \
			$inParameters.top; String($inParameters.top))
		$delimiter:="&"
	End if 
	If (Length(String($inParameters.orderBy))>0)
		$urlParams+=$delimiter+"$orderBy="+$inParameters.orderBy
		$delimiter:="&"
	End if 
	
	return $urlParams
