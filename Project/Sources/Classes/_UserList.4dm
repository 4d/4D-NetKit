Class extends _BaseList

Class constructor($inOAuth2Provider : cs:C1710.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super:C1705($inOAuth2Provider; $inURL; $inHeaders)
	
	
	// ----------------------------------------------------
	
	
Function get users() : Collection
	
	return This:C1470._internals.list
	