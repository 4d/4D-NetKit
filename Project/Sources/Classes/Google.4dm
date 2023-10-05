Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	This._internals:={_oAuth2Provider: $inProvider; _mail: Null; _parameters: $inParameters}
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mail : cs.GoogleMail
	
	If (This._internals._mail=Null)
		This._internals._mail:=cs.GoogleMail.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._mail
