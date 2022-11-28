Class constructor($inAddress : Text; $inName : Text)
	
	If (Length:C16(String:C10($inAddress))>0)
		
		This:C1470.emailAddress:=New object:C1471("address"; $inAddress)
		If (Length:C16(String:C10($inName))>0)
			This:C1470.emailAddress.name:=$inName
		End if 
		
	Else 
		
		_4D THROW ERROR:C1520(New object:C1471("code"; 2; "component"; "4DNK"; "deferred"; True:C214; "attribute"; "address"))
		
	End if 
	