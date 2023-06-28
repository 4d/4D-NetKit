Class extends _GoogleBaseList

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text)
	
	Super:C1705($inProvider; $inURL; "messages")
	This:C1470._internals._mails:=Null:C1517
	This:C1470._internals._URL:=$inURL
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mails() : Collection
	
	If (This:C1470._internals._mails=Null:C1517)
		
		//TRACE
		//Super._getList()
		This:C1470._internals._mails:=This:C1470._internals._list
		
		
		//var $iter : Object
		//var $provider : cs.OAuth2Provider
		
		//$provider:=This._internals._oAuth2Provider
		
		//This._internals._mails:=New collection
		//For each ($iter; This._internals._list)
		//$mail:=cs.GraphMessage.new($provider; \
															New object("userId"; String(This._internals._mail.userId)); \
															$iter)
		//This._internals._mails.push($mail)
		//End for each 
	End if 
	
	return This:C1470._internals._mails
	