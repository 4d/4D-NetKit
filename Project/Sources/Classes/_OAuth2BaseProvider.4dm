Class extends _BaseClass

Class constructor()
	
	Super:C1705()
	This:C1470.name:=""
	This:C1470.redirectURI:=""
	This:C1470.tenant:=""
	This:C1470.authenticateURI:=""
	This:C1470.tokenURI:=""
	
	
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
			return Choose:C955((Length:C16(This:C1470.redirectURI)>0); This:C1470.redirectURI; "https://login.microsoftonline.com/common/oauth2/nativeclient")
			
		: (This:C1470._isGoogle())
			return Choose:C955((Length:C16(This:C1470.redirectURI)>0); This:C1470.redirectURI; "https://login.microsoftonline.com/common/oauth2/nativeclient")
			
		Else 
			return This:C1470.redirectURI
			
	End case 
	
	
	// ----------------------------------------------------
	
	
Function _authenticateURI()->$authenticateURI : Text
	
/*
Uri used to do the Authorization request
*/
	Case of 
		: (This:C1470._isMicrosoft())
			$authenticateURI:="https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize"
			$authenticateURI:=Replace string:C233($authenticateURI; "{tenant}"; Choose:C955((Length:C16(String:C10(This:C1470.tenant))>0); This:C1470.tenant; "common"))
			
		: (This:C1470._isGoogle())
			$authenticateURI:="https://accounts.google.com/o/oauth2/auth"
			
	End case 
	
	
	// ----------------------------------------------------
	
	
Function _tokenURI()->$tokenURI : Text
	Case of 
		: (This:C1470._isMicrosoft())
			$tokenURI:="https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token"
			$tokenURI:=Replace string:C233($tokenURI; "{tenant}"; Choose:C955((Length:C16(String:C10(This:C1470.tenant))>0); This:C1470.tenant; "common"))
			
		: (This:C1470._isGoogle())
			$tokenURI:="https://accounts.google.com/o/oauth2/token"
			
	End case 
	