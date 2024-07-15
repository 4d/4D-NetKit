property name : Text
property email : Text

Class constructor($inName : Text; $inAddress : Text)
	
	This.name:=""
	This.email:=""
	
	Case of 
		: (Count parameters=1)
			
			This.fromString($inName)
		Else 
			
			This.name:=cs.Tools.me.trimSpaces($inName)
			This.email:=cs.Tools.me.trimSpaces($inAddress)
	End case 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function fromString($inValue : Text)
	
	var $startMailPos : Integer:=Position("<"; $inValue)
	var $endMailPos : Integer:=($startMailPos>0) ? Position(">"; $inValue) : 0
	
	If (($startMailPos>0) && ($endMailPos>$startMailPos))
		
		This.name:=cs.Tools.me.trimSpaces(Substring($inValue; 1; $startMailPos-1))
		This.email:=cs.Tools.me.trimSpaces(Substring($inValue; $startMailPos+1; $endMailPos-$startMailPos-1))
	Else 
		
		var $email : Text:=cs.Tools.me.trimSpaces($inValue)
		If (cs.Tools.me.isValidEmail($email))
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
	
	return cs.Tools.me.isValidEmail(This.email)
