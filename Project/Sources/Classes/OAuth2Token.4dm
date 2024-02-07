property token : Object
property tokenExpiration : Text

Class constructor($inParams : Object)
	
	var $params : Object:=Null
	If (Count parameters>0)
		If ((Type($inParams)=Is object) && (Not(OB Is empty($inParams))))
			$params:=$inParams
		End if 
	End if 
	
	If ($params#Null)
		
		This._loadFromObject($params)
		
	End if 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _loadFromObject($inObject : Object)
	
	If (($inObject#Null) && (Not(OB Is empty($inObject))))
		
		This.token:={}
		If (OB Get type($inObject; "token")=Is object)
			
			var $i : Integer
			var $keys : Collection:=OB Keys($inObject.token)
			var $values:collection:=OB Values($inObject.token)
			
			This.token:={}
			For ($i; 0; $keys.length-1)
				This.token[$keys[$i]]:=$values[$i]
			End for 
		End if 
		
		If (OB Is defined($inObject; "tokenExpiration") && ($inObject.tokenExpiration#Null))
			This.tokenExpiration:=$inObject.tokenExpiration
		Else 
			var $expires_in : Integer:=(Current time+0)+Num($inObject.token.expires_in)
			This.tokenExpiration:=String(Current date; ISO date; Time($expires_in))
		End if 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromResponse($inResponseString : Text)
	
	var $token : Object:=JSON Parse($inResponseString)

	If (($token#Null) && (Not(OB Is empty($token))))
		
		This._loadFromObject({token: $token})
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromURLEncodedResponse($inResponseString : Text)
	
	var $token : Object:={}
	var $params : Collection:=Split string($inResponseString; "&")
	var $iter : Text

	For each ($iter; $params)
		var $pair : Collection:=Split string($iter; "=")
		If ($pair.length>1)
			$token[$pair[0]]:=$pair[1]
		End if 
	End for each 
	
	If (Not(OB Is empty($token)))
		
		This._loadFromObject({token: $token})
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _Expired($inParams : Text)->$result : Boolean
	
	var $expiration : Text:=Choose((Count parameters>0); $inParams; This.tokenExpiration)
	
	$result:=True
	If (Length($expiration)>0)
		Case of 
			: (Current date<Date($expiration))
				$result:=False
			: ((Current date=Date($expiration)) && \
				((Current time+0)<(Time($expiration)+0)))
				$result:=False
		End case 
	End if 
