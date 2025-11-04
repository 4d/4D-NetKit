property name : Text
property email : Text

Class constructor($inName : Text; $inAddress : Text)
	
	This.name:=""
	This.email:=""
	
	Case of 
		: (Count parameters=1)
			
			This.fromString($inName)
		Else 
			
			This.name:=Trim($inName)
			This.email:=Trim($inAddress)
	End case 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function fromString($inValue : Text)
	
	var $startMailPos : Integer:=Position("<"; $inValue)
	var $endMailPos : Integer:=($startMailPos>0) ? Position(">"; $inValue) : 0
	
	If (($startMailPos>0) && ($endMailPos>$startMailPos))
		
		This.name:=Trim(Substring($inValue; 1; $startMailPos-1))
		This.email:=Trim(Substring($inValue; $startMailPos+1; $endMailPos-$startMailPos-1))
	Else 
		
		var $email : Text:=Trim($inValue)
		If (cs._Tools.me.isValidEmail($email))
			This.email:=$email
		End if 
	End if 
	
	
	// ----------------------------------------------------
	
	
Function toString() : Text
	
	If (Length(This.name)=0)
		return This.email
	Else 
		return String(This.name+" <"+This.email+">")
	End if 
	
	
	// ----------------------------------------------------
	
	
Function isValid() : Boolean
	
	return cs._Tools.me.isValidEmail(This.email)
