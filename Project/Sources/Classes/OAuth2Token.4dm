property token : Object
property tokenExpiration : Text

Class constructor($inParams : Object)
	
	var $params : Object
	$params:=Null
	If (Count parameters>0)
		If ((Type($inParams)=Is object) & (Not(OB Is empty($inParams))))
			$params:=$inParams
		End if 
	End if 
	
	If ($params#Null)
		
		This._loadFromObject($params)
		
	End if 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _loadFromObject($inObject : Object)
	
	If (($inObject#Null) & (Not(OB Is empty($inObject))))
		
		This.token:=New object
		If (OB Get type($inObject; "token")=Is object)
			
			var $keys; $values : Collection
			var $i : Integer
			
			$keys:=OB Keys($inObject.token)
			$values:=OB Values($inObject.token)
			
			This.token:=New object
			For ($i; 0; $keys.length-1)
				This.token[$keys[$i]]:=$values[$i]
			End for 
		End if 
		
		If (OB Is defined($inObject; "tokenExpiration") && ($inObject.tokenExpiration#Null))
			This.tokenExpiration:=$inObject.tokenExpiration
		Else 
			var $expires_in : Integer
			
			$expires_in:=(Current time+0)+Num($inObject.token.expires_in)
			
			This.tokenExpiration:=String(Current date; ISO date; Time($expires_in))
		End if 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromResponse($inResponseString : Text)
	
	var $token : Object
	
	$token:=JSON Parse($inResponseString)
	If (($token#Null) & (Not(OB Is empty($token))))
		
		This._loadFromObject(New object("token"; $token))
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromURLEncodedResponse($inResponseString : Text)
	
	var $token : Object
	var $params : Collection
	var $iter : Text
	
	$token:=New object
	$params:=Split string($inResponseString; "&")
	For each ($iter; $params)
		var $pair : Collection
		$pair:=Split string($iter; "=")
		If ($pair.length>1)
			$token[$pair[0]]:=$pair[1]
		End if 
	End for each 
	
	If (Not(OB Is empty($token)))
		
		This._loadFromObject(New object("token"; $token))
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _Expired($inParams : Text)->$result : Boolean
	
	var $expiration : Text
	$expiration:=Choose((Count parameters>0); $inParams; This.tokenExpiration)
	
	$result:=True
	If (Length($expiration)>0)
		Case of 
			: (Current date<Date($expiration))
				$result:=False
			: ((Current date=Date($expiration)) & \
				((Current time+0)<(Time($expiration)+0)))
				$result:=False
		End case 
	End if 
