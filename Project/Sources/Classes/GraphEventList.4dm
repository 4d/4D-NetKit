Class extends _GraphBaseList

property calendarId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider; $inURL; $inHeaders)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get events() : Collection
	
	return This._internals._list
