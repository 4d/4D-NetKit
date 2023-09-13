Class extends _GraphBaseList

Class constructor($inMail : cs:C1710.Office365Mail; $inProvider : cs:C1710.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider; $inURL; $inHeaders)
	This._internals._mail:=$inMail
	This._internals._mails:=Null
	This._internals._update:=True
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mails() : Collection
	
	If (This._internals._update)
		var $iter : Object
		var $mail : cs:C1710.GraphMessage
		var $provider : cs:C1710.OAuth2Provider
		
		$provider:=This:C1470._internals._oAuth2Provider
		
		This:C1470._internals._mails:=New collection:C1472
		For each ($iter; This:C1470._internals._list)
			$mail:=cs:C1710.GraphMessage.new($provider; \
				New object:C1471("userId"; String:C10(This:C1470._internals._mail.userId)); \
				$iter)
			This:C1470._internals._mails.push($mail)
		End for each 
		
		This._internals._update:=False
	End if 
	
	return This._internals._mails
	
	
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	This._internals._update:=Super.next()
	return This._internals._update
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	This._internals._update:=Super.previous()
	return This._internals._update

