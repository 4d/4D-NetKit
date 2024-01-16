Class extends _BaseAPI

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	This._internals._URL:="https://graph.microsoft.com/v1.0/"
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _cleanGraphObject($inObject : Object) : Object
	
	var $keys : Collection
	var $key : Text
	var $cleanObject : Object
	
	$cleanObject:=OB Copy($inObject)
	$keys:=OB Keys($cleanObject)
	For each ($key; $keys)
		If ((Position("@"; $key)=1) || ($cleanObject[$key]=Null))
			OB REMOVE($cleanObject; $key)
		End if 
	End for each 
	
	return $cleanObject
	
	
	// ----------------------------------------------------
	
	
Function _copyGraphMessage($inMessage : Object) : Object
	
	If (OB Instance of($inMessage; cs.GraphMessage))
		
		var $result; $message : Object
		var $keys : Collection
		var $key : Text
		var $iter; $attachment : Object
		
		$message:=OB Copy($inMessage)
		$result:={}
		If (OB Is defined($message; "attachments") && ($message.attachments#Null))
			$result.attachments:=[]
		End if 
		$keys:=OB Keys($message)
		For each ($key; $keys)
			
			Case of 
				: (($key="_internals") || (Position("@"; $key)=1) || ($key="webLink"))
					// do not copy
					
				: ($key="attachments")
					For each ($iter; $message.attachments)
						$attachment:=_convertToGraphAttachment($iter)
						$result.attachments.push($attachment)
					End for each 
					
				Else 
					$result[$key]:=$message[$key]
					
			End case 
			
		End for each 
		
		return $result
		
	Else 
		
		return $inMessage
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromObject($inObject : Object)
	
	If (($inObject#Null) & (Not(OB Is empty($inObject))))
		
		var $key : Text
		var $keys : Collection:=$keys:=OB Keys($inObject)
		
		For each ($key; $keys)
			This[$key]:=$inObject[$key]
		End for each 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
	
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
	If (Bool($inCount))
		$urlParams+=$delimiter+"$count=true"
		$delimiter:="&"
	End if 
	
	return $urlParams
