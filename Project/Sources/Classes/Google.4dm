property _internals : Object

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	This._internals:={_oAuth2Provider: $inProvider; _parameters: $inParameters; _mail: Null; _user: Null; _calendar: Null}
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mail : cs.GoogleMail
	
	If (This._internals._mail=Null)
		This._internals._mail:=cs.GoogleMail.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._mail
	
	
	// ----------------------------------------------------
	
	
Function get user : cs.GoogleUser
	
	If (This._internals._user=Null)
		This._internals._user:=cs.GoogleUser.new(This._internals._oAuth2Provider)
	End if 
	return This._internals._user
	
	
	// ----------------------------------------------------
	
	
Function get calendar : cs.GoogleCalendar
	
	If (This._internals._calendar=Null)
		This._internals._calendar:=cs.GoogleCalendar.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._calendar
