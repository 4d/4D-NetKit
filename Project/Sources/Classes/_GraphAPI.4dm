Class extends _BaseAPI

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	This._internals._URL:="https://graph.microsoft.com/v1.0/"
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _cleanGraphObject($inObject : Object) : Object
	
	var $cleanObject : Object:=OB Copy($inObject)
	var $keys : Collection:=OB Keys($cleanObject)
	var $key : Text
	For each ($key; $keys)
		If ((Position("@"; $key)=1) || ($cleanObject[$key]=Null))
			OB REMOVE($cleanObject; $key)
		End if 
	End for each 
	
	return $cleanObject
	
	
	// ----------------------------------------------------
	
	
Function _copyGraphMessage($inMessage : Object) : Object
	
	If (OB Instance of($inMessage; cs.GraphMessage))
		
		var $result : Object:={}
		var $message : Object:=OB Copy($inMessage)
		If (OB Is defined($message; "attachments") && ($message.attachments#Null))
			$result.attachments:=[]
		End if 
		var $key : Text
		var $keys : Collection:=OB Keys($message)
		For each ($key; $keys)
			
			Case of 
				: (($key="_internals") || (Position("@"; $key)=1) || ($key="webLink"))
					// do not copy
					
				: ($key="attachments")
					var $iter : Object
					For each ($iter; $message.attachments)
						var $attachment : Object:=cs.Tools.me.convertToGraphAttachment($iter)
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
	
	If (($inObject#Null) && (Not(OB Is empty($inObject))))
		
		var $key : Text
		var $keys : Collection:=OB Keys($inObject)
		
		For each ($key; $keys)
			This[$key]:=$inObject[$key]
		End for each 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
	
	var $urlParams : Text:=""
	var $delimiter : Text:="?"

	If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
        $urlParams+=($delimiter+"$search="+$inParameters.search)
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.filter)=Is text) && (Length(String($inParameters.filter))>0))
        $urlParams+=($delimiter+"$filter="+$inParameters.filter)
        $delimiter:="&"
    End if 
    If (Not(Value type($inParameters.select)=Is undefined))
        var $select : Text
        Case of 
            : (Value type($inParameters.select)=Is text)
                $select:=$inParameters.select
            : (Value type($inParameters.select)=Is collection)
                $select:=$inParameters.select.join(","; ck ignore null or empty)
            Else 
                $select:=String($inParameters.select)
        End case 
        If (Length($select)>0)
            $urlParams+=($delimiter+"$select="+$select)
            $delimiter:="&"
        End if 
    End if 
    If (Not(Value type($inParameters.top)=Is undefined))
        $urlParams+=($delimiter+"$top="+Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
        $delimiter:="&"
    End if 
    If ((Value type($inParameters.orderBy)=Is text) && (Length(String($inParameters.orderBy))>0))
        $urlParams+=($delimiter+"$orderBy="+$inParameters.orderBy)
        $delimiter:="&"
    End if 

	// Specific to .getFolder / .getFolderList
	If (Bool($inParameters.includeHiddenFolders))
		$urlParams+="/"+$delimiter+"includeHiddenFolders=true"
		$delimiter:="&"
	End if 
	If (Bool($inCount))
		$urlParams+=$delimiter+"$count=true"
		$delimiter:="&"
	End if 

	return $urlParams
