Class extends _GoogleBaseList

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text)
	
	Super:C1705($inProvider; $inURL; "messages")
	//This._internals._mails:=Null
	This:C1470._internals._URL:=$inURL
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mails() : Collection
	
	//If (This._internals._mails=Null)
	//This._internals._mails:=This._internals._list
	//End if 
	
	//return This._internals._mails
	
	return This:C1470._internals._list