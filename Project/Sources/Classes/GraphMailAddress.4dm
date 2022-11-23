Class constructor($inAddress : Text; $inName : Text)
	
	This:C1470.address:=$inAddress
	This:C1470.name:=$inName
	
	
Function mailAddress() : Object
	
	var $mailAddress : Object
	$mailAddress:=New object:C1471("address"; This:C1470.address)
	If (Length:C16(String:C10(This:C1470.name))>0)
		$mailAddress.name:=This:C1470.name
	End if 
	return New object:C1471("emailAddress"; $mailAddress)
	