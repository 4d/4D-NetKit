Class constructor($inParams : Object)
	
	var $params : Object
	$params:=Null:C1517
	If (Count parameters:C259>0)
		If ((Type:C295($inParams)=Is object:K8:27) & (Not:C34(OB Is empty:C1297($inParams))))
			$params:=$inParams
		End if 
	End if 
	
	If ($params#Null:C1517)
		
		This:C1470._loadFromObject($params)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _loadFromObject($inObject : Object)
	
	If (($inObject#Null:C1517) & (Not:C34(OB Is empty:C1297($inObject))))
		
		This:C1470.token:=New object:C1471
		If (OB Get type:C1230($inObject; "token")=Is object:K8:27)
			
			var $keys; $values : Collection
			var $i : Integer
			
			$keys:=OB Keys:C1719($inObject.token)
			$values:=OB Values:C1718($inObject.token)
			
			This:C1470.token:=New object:C1471
			For ($i; 0; $keys.length-1)
				This:C1470.token[$keys[$i]]:=$values[$i]
			End for 
		End if 
		
		If (OB Is defined:C1231($inObject; "tokenExpiration") && ($inObject.tokenExpiration#Null:C1517))
			This:C1470.tokenExpiration:=$inObject.tokenExpiration
		Else 
			var $expires_in : Integer
			var $expiration_date : Date
			
			$expires_in:=(Current time:C178+0)+Num:C11($inObject.token.expires_in)
			$expiration_date:=Add to date:C393(Current date:C33; 0; 0; Choose:C955(($expires_in>=(24*3600)); 1; 0))
			
			This:C1470.tokenExpiration:=String:C10($expiration_date; ISO date:K1:8; Time:C179($expires_in))
		End if 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _loadFromResponse($inResponseString : Text)
	
	var $token : Object
	
	$token:=JSON Parse:C1218($inResponseString)
	If (($token#Null:C1517) & (Not:C34(OB Is empty:C1297($token))))
		
		This:C1470._loadFromObject(New object:C1471("token"; $token))
		
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _Expired($inParams : Text)->$result : Boolean
	
	var $expiration : Text
	$expiration:=Choose:C955((Count parameters:C259>0); $inParams; This:C1470.tokenExpiration)
	
	$result:=True:C214
	If (Length:C16($expiration)>0)
		Case of 
			: (Current date:C33<Date:C102($expiration))
				$result:=False:C215
			: ((Current date:C33=Date:C102($expiration)) & \
				((Current time:C178+0)<(Time:C179($expiration)+0)))
				$result:=False:C215
		End case 
	End if 
	