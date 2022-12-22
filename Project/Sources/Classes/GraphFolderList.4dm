Class extends _GraphBaseList

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super:C1705($inProvider; $inURL; $inHeaders)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get folders() : Collection
	
	return This:C1470._internals.list
	