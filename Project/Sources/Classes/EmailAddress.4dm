property name : Text
property email : Text

Class constructor($inName : Text; $inAddress : Text)
	
	This.name:=""
	This.email:=""
	
	Case of 
		: (Count parameters=1)
			
			This.fromString($inName)
		Else 
			
			This.name:=_trimSpaces($inName)
			This.email:=_trimSpaces($inAddress)
	End case 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function fromString($inValue : Text)
	
	var $startMailPos : Integer:=Position("<"; $inValue)
	var $endMailPos : Integer:=($startMailPos>0) ? Position(">"; $inValue) : 0
	
	If (($startMailPos>0) && ($endMailPos>$startMailPos))
		
		This.name:=_trimSpaces(Substring($inValue; 1; $startMailPos-1))
		This.email:=_trimSpaces(Substring($inValue; $startMailPos+1; $endMailPos-$startMailPos-1))
	Else 
		
		var $email:Text:=_trimSpaces($inValue)
		If (This._isValidEmail($email))
			This.email:=$email
		End if 
	End if 
	
	
	// ----------------------------------------------------
	
	
Function toString()->$result : Text
	
	If (Length(This.name)=0)
		$result:=This.email
	Else 
		$result:=This.name+" <"+This.email+">"
	End if 
	
	
	// ----------------------------------------------------
	
	
Function isValid() : Boolean
	
	return This._isValidEmail(This.email)
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _isValidEmail($inEmail : Text) : Boolean
	
	var $pattern : Text:="(?i)^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$"
	return Match regex($pattern; $inEmail; 1)
