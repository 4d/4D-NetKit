Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	This._internals:={_oAuth2Provider: $inProvider; _user: Null; _mail: Null; _parameters: $inParameters}
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get user : cs.Office365User
	
	If (This._internals._user=Null)
		This._internals._user:=cs.Office365User.new(This._internals._oAuth2Provider)
	End if 
	return This._internals._user
	
	
	// ----------------------------------------------------
	
	
Function get mail : cs.Office365Mail
	
	If (This._internals._mail=Null)
		This._internals._mail:=cs.Office365Mail.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._mail
	
	
	// ----------------------------------------------------
	
	
Function get calendar : cs.Office365Calendar
	
	If (This._internals._calendar=Null)
		This._internals._calendar:=cs.Office365Calendar.new(This._internals._oAuth2Provider)
	End if 
	return This._internals._calendar
