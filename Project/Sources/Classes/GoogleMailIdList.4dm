Class extends _GoogleBaseList

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text)
	
	Super:C1705($inProvider; $inURL; "messages")
	This:C1470._internals._URL:=$inURL
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mailIds() : Collection
	
	return This:C1470._internals._list