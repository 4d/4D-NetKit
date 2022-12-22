Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	This:C1470._internals:=New object:C1471
	This:C1470._internals._OAuth2Provider:=$inProvider
	This:C1470._internals._user:=Null:C1517
	This:C1470._internals._mail:=Null:C1517
	This:C1470._internals._parameters:=$inParameters
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get user : cs:C1710.Office365User
	
	If (This:C1470._internals._user=Null:C1517)
		This:C1470._internals._user:=cs:C1710.Office365User.new(This:C1470._internals._OAuth2Provider)
	End if 
	return This:C1470._internals._user
	
	
	// ----------------------------------------------------
	
	
Function get mail : cs:C1710.Office365Mail
	
	If (This:C1470._internals._mail=Null:C1517)
		This:C1470._internals._mail:=cs:C1710.Office365Mail.new(This:C1470._internals._OAuth2Provider; This:C1470._internals._parameters)
	End if 
	return This:C1470._internals._mail
	