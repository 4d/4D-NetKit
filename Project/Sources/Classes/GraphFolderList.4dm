Class extends _GraphBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider; $inURL; $inHeaders)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get folders() : Collection
	
	return This._internals._list
