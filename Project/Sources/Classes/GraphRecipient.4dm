property emailAddress : Object

Class constructor($inAddress : Text; $inName : Text)
	
	var $parsed : cs._EmailAddress:=cs._EmailAddress.new($inName; $inAddress)
	If ($parsed.isValid())
		
		This.emailAddress:={address: $parsed.email}
		If (Length($parsed.name)>0)
			This.emailAddress.name:=$parsed.name
		End if 
	Else 
		
		throw({code: 2; component: "4DNK"; deferred: True; attribute: "address"})
	End if 
