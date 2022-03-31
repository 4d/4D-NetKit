Class constructor($OAuth2 : cs:C1710.OAuth2BaseProvider)
	
	If (OB Instance of:C1731($OAuth2; cs:C1710.OAuth2BaseProvider))  // can be cs.OAuth2Base or any extended class
		
		// Sanity check
		If ($OAuth2.checkPrerequisites())
			
			This:C1470._checkPrerequisites:=Formula:C1597($OAuth2.checkPrerequisites())  // Store the provider checkPrerequisites as a formula to be call later
			This:C1470._authenticateURIExtender:=Formula:C1597($OAuth2.authenticateURIExtender($1))  // Store the provider checkPrerequisites as a formula to be call later
			
			This:C1470.name:=String:C10($OAuth2.name)
			
			This:C1470.permission:=String:C10($OAuth2.permission)
			
			This:C1470.clientId:=String:C10($OAuth2.clientId)
			
			This:C1470.redirectURI:=String:C10($OAuth2.redirectURI)
			
			If (Value type:C1509($OAuth2.scope)=Is collection:K8:32)
				This:C1470.scope:=$OAuth2.scope.join(" ")
			Else 
				This:C1470.scope:=String:C10($OAuth2.scope)
			End if 
			
			This:C1470.authenticateURI:=String:C10($OAuth2.authenticateURI)
			
			This:C1470.tokenURI:=String:C10($OAuth2.tokenURI)
			
			This:C1470.clientSecret:=String:C10($OAuth2.clientSecret)
			
			This:C1470.token:=$OAuth2.token
			
			This:C1470.tokenExpiration:=String:C10($OAuth2.tokenExpiration)
			
			This:C1470.timeout:=$OAuth2.timeout
			
		End if 
	Else 
		ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_parameters"))
	End if 
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _OpenBrowserForAuthorisation()->$authorizationCode : Text
	
	var $provider : Text
	$provider:=String:C10(This:C1470.name)
	
	// You must add your own provider here if needed
	If ($provider#"OAuth2") & ($provider#"Microsoft")
		ASSERT:C1129(False:C215; $provider+" : "+Get localized string:C991("OAuth2_Unsupported_Provider"))
		
	Else 
		
		// Sanity check
		If (This:C1470._checkPrerequisites())
			
			var $url : Text
			$url:=This:C1470.authenticateURI
			
			$url:=$url+"?client_id="+This:C1470.clientId+\
				"&response_type=code"+\
				"&redirect_uri="+_urlEscape(This:C1470.redirectURI)+\
				"&response_mode=query"+\
				"&scope="+_urlEscape(This:C1470.scope)+\
				"&state="+String:C10(This:C1470.state)
			
			$url:=This:C1470._authenticateURIExtender($url)
			
			Use (Storage:C1525)
				OB REMOVE:C1226(Storage:C1525; "token")
				Storage:C1525.params:=New shared object:C1526("redirectURI"; This:C1470.redirectURI)
			End use 
			
			OPEN URL:C673($url; *)
			
			var $endTime : Integer
			$endTime:=Milliseconds:C459+(This:C1470.timeout*1000)
			While ((Milliseconds:C459<=$endTime) & (Not:C34(OB Is defined:C1231(Storage:C1525; "token")) | (Storage:C1525.token=Null:C1517)))
				DELAY PROCESS:C323(Current process:C322; 10)
			End while 
			
			Use (Storage:C1525)
				If (OB Is defined:C1231(Storage:C1525; "token"))
					$authorizationCode:=Storage:C1525.token.code
					//If (OB Is defined(Storage.token; "state") & (Length(OB Get(Storage.token; "state"; Is text))>0))
					//ASSERT(Storage.token.state=$state; "state changed !!! CSRF Attack ?")
					//End if 
					OB REMOVE:C1226(Storage:C1525; "token")
					OB REMOVE:C1226(Storage:C1525; "params")
				End if 
			End use 
			
		End if 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getToken_SignedIn($bUseRefreshToken : Boolean)->$result : Object
	
	var $params : Text
	var $bSendRequest : Boolean
	
	$bSendRequest:=True:C214
	If ($bUseRefreshToken)
		
		$params:="client_id="+This:C1470.clientId+\
			"&scope="+_urlEscape(This:C1470.scope)+\
			"&refresh_token="+This:C1470.token.refresh_token+\
			"&grant_type=refresh_token"
		If (Length:C16(This:C1470.clientSecret)>0)
			$params:=$params+"&client_secret="+This:C1470.clientSecret
		End if 
		
	Else 
		
		var $authorizationCode : Text
		var $LaunchWebServer : Boolean
		
		If ((Position:C15("localhost"; This:C1470.redirectURI)>0) | (Position:C15("127.0.0.1"; This:C1470.redirectURI)>0))
			
			var $port : Integer
			$port:=_getPortFromURL(This:C1470.redirectURI)
			If (_StartWebServer($port))
				
				$authorizationCode:=This:C1470._OpenBrowserForAuthorisation()
				
			Else 
				
				ASSERT:C1129(False:C215; Replace string:C233(Get localized string:C991("OAuth2_Port_Already_Used"); "{PORT}"; String:C10($port)))
				
			End if 
		End if 
		
		If (Asserted:C1132(Length:C16($authorizationCode)>0; "authorizationCode is empty!"))
			
			$params:="client_id="+This:C1470.clientId+\
				"&scope="+_urlEscape(This:C1470.scope)+\
				"&code="+$authorizationCode+\
				"&redirect_uri="+_urlEscape(This:C1470.redirectURI)+\
				"&grant_type=authorization_code"
			If (Length:C16(This:C1470.clientSecret)>0)
				$params:=$params+"&client_secret="+This:C1470.clientSecret
			End if 
			
		Else 
			
			$bSendRequest:=False:C215
			
		End if 
		
	End if 
	
	If ($bSendRequest)
		
		$result:=This:C1470._sendTokenRequest($params)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getToken_Service()->$result : Object
	
	var $params : Text
	
	$params:="client_id="+This:C1470.clientId+\
		"&scope="+_urlEscape(This:C1470.scope)+\
		"&client_secret="+This:C1470.clientSecret+\
		"&grant_type=client_credentials"
	
	$result:=This:C1470._sendTokenRequest($params)
	
	
	// ----------------------------------------------------
	
	
	// [Public]
Function getToken()->$result : Object
	
	var $provider : Text
	
	$provider:=This:C1470.name
	
	// You must add your own provider here if needed
	If ($provider#"OAuth2") & ($provider#"Microsoft")
		ASSERT:C1129(False:C215; $provider+" : "+Get localized string:C991("OAuth2_Unsupported_Provider"))
		
	Else 
		var $bUseRefreshToken : Boolean
		
		$bUseRefreshToken:=False:C215
		If (This:C1470.token#Null:C1517)
			var $token : cs:C1710.OAuth2Token
			$token:=cs:C1710.OAuth2Token.new(This:C1470)
			If (Not:C34($token._Expired(This:C1470.tokenExpiration)))
				// Token is still valid.. Simply return it
				$result:=$token
			Else 
				If (OB Is defined:C1231(This:C1470.token; "refresh_token"))
					$bUseRefreshToken:=(Length:C16(This:C1470.token.refresh_token)>0)
				End if 
			End if 
		End if 
		
		If ($result=Null:C1517)
			
			// Sanity check
			If (This:C1470._checkPrerequisites())
				
				If (This:C1470.permission="signedIn")  // signedIn Mode
					
					$result:=This:C1470._getToken_SignedIn($bUseRefreshToken)
					
				Else 
					
					$result:=This:C1470._getToken_Service()
					
				End if 
				
				If ($result#Null:C1517)
					// Save token internally
					If (OB Is defined:C1231($result; "tokenExpiration"))
						This:C1470.tokenExpiration:=$result.tokenExpiration
					End if 
					This:C1470.token:=$result.token
				End if 
				
			End if 
			
		End if 
		
	End if 
	// ----------------------------------------------------
	
	
	// [Private]
Function _sendTokenRequest($params : Text)->$result : Object
	
	var $response; $savedMethod : Text
	var $request : Blob
	var $status : Integer
	ARRAY TEXT:C222($names; 0)
	ARRAY TEXT:C222($values; 0)
	
	CONVERT FROM TEXT:C1011($params; "utf-8"; $request)
	
	APPEND TO ARRAY:C911($names; "Content-Type")
	APPEND TO ARRAY:C911($values; "application/x-www-form-urlencoded")
	
	$savedMethod:=Method called on error:C704
	This:C1470.tokenURI:=Replace string:C233(This:C1470.tokenURI; "{tenant}"; Choose:C955((Length:C16(This:C1470.tenant)>0); This:C1470.tenant; "common"))
	ON ERR CALL:C155("_ErrorHandler")
	$status:=HTTP Request:C1158(HTTP POST method:K71:2; This:C1470.tokenURI; $request; $response; $names; $values)
	ON ERR CALL:C155($savedMethod)
	
	If (Asserted:C1132(($status=200); Get localized string:C991("OAuth2_Error_Wrong_Status_Code")+String:C10($status)+"\r\n"+\
		$response))
		
		If (Asserted:C1132(Length:C16($response)>0; Get localized string:C991("OAuth2_Error_Empty_Token_Response")))
			
			$result:=cs:C1710.OAuth2Token.new()
			$result._loadFromResponse($response)
			
		End if 
		
	End if 
	