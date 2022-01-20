Class extends _BaseClass

Class constructor($parameters : Object)
	
	Super:C1705()
	
	This:C1470._try()
	
	// Sanity check
	If (This:C1470._checkPrerequisites($parameters))
		
/*
Only currently supported value : "Microsoft"
No default value, no prefered provider but, a different value from "Microsoft" will throw an error
*/
		This:C1470.name:=String:C10($parameters.name)
		
/*
"signedIn": Azure AD will sign the user in and ensure their consent for the permissions your app requests. Need to open a web browser.
"service": call Microsoft Graph with their own identity.
*/
		This:C1470.permission:=String:C10($parameters.permission)
		
/*
The Application ID that the registration portal assigned the app
*/
		This:C1470.clientId:=String:C10($parameters.clientId)
		
/*
The redirect_uri of your app, where authentication responses can be sent and received by your app.
*/
		This:C1470.redirectURI:=String:C10($parameters.redirectURI)
		
/*
A space-separated list of the Microsoft Graph permissions that you want the user to consent to.
collection: collection of Microsoft Graph permissions
*/
		If (Value type:C1509($parameters.scope)=Is collection:K8:32)
			This:C1470.scope:=$parameters.scope.join(" ")
			
		Else 
			This:C1470.scope:=String:C10($parameters.scope)
			
		End if 
		
/*
The {tenant} value in the path of the request can be used to control who can sign into the application. 
The allowed values are "common" for both Microsoft accounts and work or school accounts, "organizations" 
for work or school accounts only, "consumers" for Microsoft accounts only, and tenant identifiers such as 
the tenant ID or domain name. By default "common"
*/
		This:C1470.tenant:=Choose:C955(Value type:C1509($parameters.tenant)=Is undefined:K8:13; "common"; String:C10($parameters.tenant))
		
/*
Uri used to do the Authorization request.
*/
		This:C1470.authenticateURI:=Choose:C955(Value type:C1509($parameters.authenticateURI)=Is undefined:K8:13; \
			"https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize"; \
			String:C10($parameters.authenticateURI))
		
/*
Uri used to request an access token.
*/
		This:C1470.tokenURI:=Choose:C955(Value type:C1509($parameters.tokenURI)=Is undefined:K8:13; \
			"https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token"; \
			String:C10($parameters.tokenURI))
		
/*
The application secret that you created in the app registration portal for your app. Required for web apps.
*/
		This:C1470.clientSecret:=String:C10($parameters.clientSecret)
		
/*
*/
		This:C1470.token:=Choose:C955(Value type:C1509($parameters.token)=Is object:K8:27; $parameters.token; Null:C1517)
		
/*
*/
		This:C1470.tokenExpiration:=Choose:C955(Value type:C1509($parameters.tokenExpiration)=Is text:K8:3; $parameters.tokenExpiration; Null:C1517)
		
/*
*/
		This:C1470.timeout:=Choose:C955(Value type:C1509($parameters.timeout)=Is undefined:K8:13; 120; Num:C11($parameters.timeout))
		
	End if 
	
	This:C1470._finally()
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _OpenBrowserForAuthorisation()->$authorizationCode : Text
	
	// Sanity check
	Case of 
			
		: (Length:C16(String:C10(This:C1470.clientId))=0)
			This:C1470._throwError(2; New object:C1471("attribute"; "clientId"))
			
		: (Length:C16(String:C10(This:C1470.authenticateURI))=0)
			This:C1470._throwError(2; New object:C1471("attribute"; "authenticateURI"))
			
		: (Length:C16(String:C10(This:C1470.scope))=0)
			This:C1470._throwError(2; New object:C1471("attribute"; "scope"))
			
		: (Length:C16(String:C10(This:C1470.tenant))=0)
			This:C1470._throwError(2; New object:C1471("attribute"; "tenant"))
			
		: ((String:C10(This:C1470.permission)="signedIn") & (Length:C16(String:C10(This:C1470.redirectURI))=0))
			This:C1470._throwError(2; New object:C1471("attribute"; "redirectURI"))
			
		: (Not:C34(String:C10(This:C1470.name)="Microsoft"))
			This:C1470._throwError(3; New object:C1471("attribute"; "name"))
			
			
		Else 
			
			// See: https://docs.microsoft.com/en-us/graph/auth-v2-service
			var $url; $redirectURI; $state : Text
			
			$state:=Generate UUID:C1066
			This:C1470.authenticateURI:=Replace string:C233(This:C1470.authenticateURI; "{tenant}"; Choose:C955((Length:C16(This:C1470.tenant)>0); This:C1470.tenant; "common"))
			$url:=This:C1470.authenticateURI
			$redirectURI:=Choose:C955((Length:C16(This:C1470.redirectURI)>0); This:C1470.redirectURI; "https://login.microsoftonline.com/common/oauth2/nativeclient")
			
			$url:=$url+"?client_id="+This:C1470.clientId+\
				"&response_type=code"+\
				"&redirect_uri="+_urlEscape($redirectURI)+\
				"&response_mode=query"+\
				"&scope="+_urlEscape(This:C1470.scope)+\
				"&state="+String:C10($state)
			
			Use (Storage:C1525)
				OB REMOVE:C1226(Storage:C1525; "token")
				Storage:C1525.params:=New shared object:C1526("redirectURI"; $redirectURI)
			End use 
			
			OPEN URL:C673($url; *)
			
			//TRACE
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
			
	End case 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getToken_SignedIn($bUseRefreshToken : Boolean)->$result : Object
	
	var $params : Text
	var $bSendRequest : Boolean
	
	$bSendRequest:=True:C214
	If ($bUseRefreshToken)
		
		$params:="client_id="+This:C1470.clientId+\
			"&scope="+_urlEscape(This:C1470.scope)+\
			"&refresh_token="+This:C1470.token.refreshToken+\
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
				
				This:C1470._throwError(7; New object:C1471("port"; $port))
				
			End if 
		End if 
		
		If (Length:C16($authorizationCode)>0)
			
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
			This:C1470._throwError(6)
			
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
	
	
Function getToken()->$result : Object
	
	This:C1470._try()
	
	If (String:C10(This:C1470.name)="Microsoft")
		
		var $bUseRefreshToken : Boolean
		
		$bUseRefreshToken:=False:C215
		If (This:C1470.token#Null:C1517)
			var $token : cs:C1710._OAuth2Token
			$token:=cs:C1710._OAuth2Token.new(This:C1470)
			If (Not:C34($token._Expired(This:C1470.tokenExpiration)))
				// Token is still valid.. Simply return it
				$result:=$token
			Else 
				If (OB Is defined:C1231(This:C1470.token; "refreshToken"))
					$bUseRefreshToken:=(Length:C16(This:C1470.token.refreshToken)>0)
				End if 
			End if 
		End if 
		
		If ($result=Null:C1517)
			
			// Sanity check
			Case of 
					
				: (Length:C16(String:C10(This:C1470.clientId))=0)
					This:C1470._throwError(2; New object:C1471("attribute"; "clientId"))
					
				: (Length:C16(String:C10(This:C1470.authenticateURI))=0)
					This:C1470._throwError(2; New object:C1471("attribute"; "authenticateURI"))
					
				: (Length:C16(String:C10(This:C1470.scope))=0)
					This:C1470._throwError(2; New object:C1471("attribute"; "scope"))
					
				: (Length:C16(String:C10(This:C1470.tokenURI))=0)
					This:C1470._throwError(2; New object:C1471("attribute"; "tokenURI"))
					
				: (Length:C16(String:C10(This:C1470.tenant))=0)
					This:C1470._throwError(2; New object:C1471("attribute"; "tenant"))
					
				: (Length:C16(String:C10(This:C1470.permission))=0)
					This:C1470._throwError(2; New object:C1471("attribute"; "permission"))
					
				: ((String:C10(This:C1470.permission)="signedIn") & (Length:C16(String:C10(This:C1470.redirectURI))=0))
					This:C1470._throwError(2; New object:C1471("attribute"; "permission"))
					
				: (Not:C34(String:C10(This:C1470.permission)="signedIn") & Not:C34(String:C10(This:C1470.permission)="service"))
					This:C1470._throwError(3; New object:C1471("attribute"; "permission"))
					
				Else 
					
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
					
			End case 
			
		End if 
		
	Else 
		This:C1470._throwError(3; New object:C1471("attribute"; "name"))
		
	End if 
	
	This:C1470._finally()
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _checkPrerequisites($obj : Object)->$OK : Boolean
	
	$OK:=False:C215
	
	If (($obj#Null:C1517) & (Value type:C1509($obj)=Is object:K8:27))
		
		Case of 
				
			: (Length:C16(String:C10($obj.name))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "name"))
				
			: (Length:C16(String:C10($obj.clientId))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "clientId"))
				
			: (Length:C16(String:C10($obj.scope))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "scope"))
				
			: (Length:C16(String:C10($obj.permission))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "permission"))
				
			: (Not:C34(String:C10($obj.permission)="signedIn") & Not:C34(String:C10($obj.permission)="service"))
				This:C1470._throwError(3; New object:C1471("attribute"; "permission"))
				
			: ((String:C10($obj.permission)="signedIn") & (Length:C16(String:C10($obj.redirectURI))=0))
				This:C1470._throwError(2; New object:C1471("attribute"; "redirectURI"))
				
			Else 
				$OK:=True:C214
				
		End case 
		
		
	Else 
		
		This:C1470._throwError(1)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _sendTokenRequest($params : Text)->$result : Object
	
	var $response; $savedMethod : Text
	var $status : Integer
	
	This:C1470.tokenURI:=Replace string:C233(This:C1470.tokenURI; "{tenant}"; Choose:C955((Length:C16(This:C1470.tenant)>0); This:C1470.tenant; "common"))
	
	var $requestBody : Blob
	
	ARRAY TEXT:C222($names; 0)
	ARRAY TEXT:C222($values; 0)
	
	CONVERT FROM TEXT:C1011($params; "utf-8"; $requestBody)
	
	APPEND TO ARRAY:C911($names; "Content-Type")
	APPEND TO ARRAY:C911($values; "application/x-www-form-urlencoded")
	
	$savedMethod:=Method called on error:C704
	ON ERR CALL:C155("_ErrorHandler")
	$status:=HTTP Request:C1158(HTTP POST method:K71:2; This:C1470.tokenURI; $requestBody; $response; $names; $values)
	ON ERR CALL:C155($savedMethod)
	
	If ($status=200)
		
		If (Length:C16($response)>0)
			
			$result:=cs:C1710._OAuth2Token.new()
			$result._loadFromResponse($response)
			
		Else 
			This:C1470._throwError(4)
			
		End if 
		
	Else 
		This:C1470._throwError(5; New object:C1471("received"; $status; "expected"; 200))
		
	End if 
	