Class extends _BaseClass

Class constructor()
	
	Super:C1705()
	This:C1470.name:=""
	This:C1470.tenant:=""
	This:C1470.redirectURI:=""
	This:C1470.authenticateURI:=""
	This:C1470.tokenURI:=""
	//
	This:C1470.accessType:=""
	This:C1470.includeGrantedScopes:=False:C215  // Google Only
	This:C1470.loginHint:=""
	This:C1470.prompt:=""
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _isMicrosoft() : Boolean
	
	return (This:C1470.name="Microsoft")
	
	
	// ----------------------------------------------------
	
	
Function _isGoogle() : Boolean
	
	return (This:C1470.name="Google")
	
	
	// ----------------------------------------------------
	
	
Function _redirectURI() : Text
	
	Case of 
		: (This:C1470._isMicrosoft())
			return Choose:C955((Length:C16(String:C10(This:C1470.redirectURI))>0); This:C1470.redirectURI; "https://login.microsoftonline.com/common/oauth2/nativeclient")
			
		: (This:C1470._isGoogle())
			return Choose:C955((Length:C16(String:C10(This:C1470.redirectURI))>0); This:C1470.redirectURI; "urn:ietf:wg:oauth:2.0:oob")
			
		Else 
			return This:C1470.redirectURI
			
	End case 
	
	
	// ----------------------------------------------------
	
	
Function _authenticateURI() : Text
	
	Case of 
		: (This:C1470._isMicrosoft())
			This:C1470.authenticateURI:=Choose:C955((Length:C16(String:C10(This:C1470.authenticateURI))>0); This:C1470.authenticateURI; "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize")
			This:C1470.authenticateURI:=Replace string:C233(This:C1470.authenticateURI; "{tenant}"; Choose:C955((Length:C16(String:C10(This:C1470.tenant))>0); This:C1470.tenant; "common"))
			
		: (This:C1470._isGoogle())
			This:C1470.authenticateURI:="https://accounts.google.com/o/oauth2/auth"
			
	End case 
	
	return This:C1470.authenticateURI
	
	
	// ----------------------------------------------------
	
	
Function _tokenURI() : Text
	
	Case of 
		: (This:C1470._isMicrosoft())
			This:C1470.tokenURI:=Choose:C955((Length:C16(String:C10(This:C1470.tokenURI))>0); This:C1470.tokenURI; "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token")
			This:C1470.tokenURI:=Replace string:C233(This:C1470.tokenURI; "{tenant}"; Choose:C955((Length:C16(String:C10(This:C1470.tenant))>0); This:C1470.tenant; "common"))
			
		: (This:C1470._isGoogle())
			This:C1470.tokenURI:="https://accounts.google.com/o/oauth2/token"
			
	End case 
	
	return This:C1470.tokenURI
	