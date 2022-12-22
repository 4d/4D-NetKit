Class extends _GraphBaseList

Class constructor($inMail : cs:C1710.Office365Mail; $inProvider : cs:C1710.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super:C1705($inProvider; $inURL; $inHeaders)
	This:C1470._internals._mail:=$inMail
	This:C1470._internals._mails:=Null:C1517
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mails() : Collection
	
	If (This:C1470._internals._mails=Null:C1517)
		var $iter : Object
		var $mail : cs:C1710.GraphMessage
		var $provider : cs:C1710.OAuth2Provider
		
		$provider:=This:C1470._internals._OAuth2Provider
		
		This:C1470._internals._mails:=New collection:C1472
		For each ($iter; This:C1470._internals.list)
			$mail:=cs:C1710.GraphMessage.new($provider; \
				New object:C1471("userId"; String:C10(This:C1470._internals._mail.userId)); \
				$iter)
			This:C1470._internals._mails.push($mail)
		End for each 
	End if 
	
	return This:C1470._internals._mails
	