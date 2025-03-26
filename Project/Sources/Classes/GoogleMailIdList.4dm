Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text)
	
	Super($inProvider; {url: $inURL; elements: "messages"})
	This._internals._URL:=$inURL
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mailIds() : Collection
	
	return This._internals._list