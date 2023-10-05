property emailAddress : Object

Class constructor($inAddress : Text; $inName : Text)
	
	If (Length(String($inAddress))>0)
		
		This.emailAddress:={address: $inAddress}
		If (Length(String($inName))>0)
			This.emailAddress.name:=$inName
		End if 
	Else 
		
		throw({code: 2; component: "4DNK"; deferred: True; attribute: "address"})
	End if 
