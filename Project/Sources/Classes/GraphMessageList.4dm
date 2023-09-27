Class extends _GraphBaseList

Class constructor($inMail : cs.Office365Mail; $inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider; $inURL; $inHeaders)
	This._internals._mail:=$inMail
	This._internals._mails:=Null
	This._internals._update:=True
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mails() : Collection
	
	If (This._internals._update)
		var $iter : Object
		var $mail : cs.GraphMessage
		var $provider : cs.OAuth2Provider
		
		$provider:=This._internals._oAuth2Provider
		
		This._internals._mails:=[]
		For each ($iter; This._internals._list)
			$mail:=cs.GraphMessage.new($provider; \
				{userId: String(This._internals._mail.userId)}; \
				$iter)
			This._internals._mails.push($mail)
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

