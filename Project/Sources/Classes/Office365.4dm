Class constructor($inOAuth2Provider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	This:C1470._internals:=New object:C1471
	This:C1470._internals._OAuth2Provider:=$inOAuth2Provider
	This:C1470._internals._user:=Null:C1517
	This:C1470._internals._mail:=Null:C1517
	This:C1470._internals._parameters:=$inParameters
	
	
	// ----------------------------------------------------
	
	
Function get user : cs:C1710._GraphUser
	
	If (This:C1470._internals._user=Null:C1517)
		This:C1470._internals._user:=cs:C1710._GraphUser.new(This:C1470._internals._OAuth2Provider)
	End if 
	return This:C1470._internals._user
	
	
	// ----------------------------------------------------
	
	
Function get mail : cs:C1710._GraphMail
	
	If (This:C1470._internals._mail=Null:C1517)
		This:C1470._internals._mail:=cs:C1710._GraphMail.new(This:C1470._internals._OAuth2Provider; This:C1470._internals._parameters)
	End if 
	return This:C1470._internals._mail
	