Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	This:C1470._internals:=New object:C1471
	This:C1470._internals._oAuth2Provider:=$inProvider
	This:C1470._internals._mail:=Null:C1517
	This:C1470._internals._parameters:=$inParameters
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mail : cs:C1710.GoogleMail
	
	If (This:C1470._internals._mail=Null:C1517)
		This:C1470._internals._mail:=cs:C1710.GoogleMail.new(This:C1470._internals._oAuth2Provider; This:C1470._internals._parameters)
	End if 
	return This:C1470._internals._mail
	