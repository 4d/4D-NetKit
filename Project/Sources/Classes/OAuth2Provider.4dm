Class extends _BaseClass

property name : Text  // Name of OAuth2 provider.
property permission : Text  // "signedIn" or "service" mode
property clientId : Text  // The Application ID that the registration portal assigned the app
property redirectURI : Text  // The redirect_uri of your app, where authentication responses can be sent and received by your app.
property tenant : Text
property clientSecret : Text  // The application secret that you created in the app registration portal for your app. Required for web apps.
property token : Object  // Any valid existing token
property tokenExpiration : Text
property timeout : Integer
property authenticationPage : 4D.File
property authenticationErrorPage : 4D.File
property accessType : Text
property loginHint : Text
property prompt : Text
property clientEmail : Text  // clientMail used by Google services account used
property privateKey : Text  // privateKey may be used used by Google services account to sign JWT token

property _scope : Text
property _authenticateURI : Text
property _tokenURI : Text
property _grantType : Text

Class constructor($inParams : Object)
	
	Super()
	
	This._try()
	
	// Sanity check
	If (This._checkPrerequisites($inParams))
		
/*
Name of OAuth2 provider.
*/
		This.name:=String($inParams.name)
		
/*
"signedIn": Provider will sign the user in and ensure their consent for the permissions your app requests. Need to open a web browser.
"service": Call Provider with their own identity.
*/
		If ((String($inParams.permission)="signedIn") || \
			(String($inParams.permission)="service"))
			This.permission:=String($inParams.permission)
		End if 
		
/*
The Application ID that the registration portal assigned the app
*/
		This.clientId:=String($inParams.clientId)
		
/*
The redirect_uri of your app, where authentication responses can be sent and received by your app.
*/
		This.redirectURI:=String($inParams.redirectURI)
		
/*
A space-separated list of the permissions that you want the user to consent to.
*/
		If (Value type($inParams.scope)=Is collection)
			This._scope:=$inParams.scope.join(" ")
			
		Else 
			This._scope:=String($inParams.scope)
			
		End if 
		
/*
The {tenant} value in the path of the request can be used to control who can sign into the application.
The allowed values are "common" for both Microsoft accounts and work or school accounts, "organizations"
for work or school accounts only, "consumers" for Microsoft accounts only, and tenant identifiers such as
the tenant ID or domain name. By default "common"
*/
		This.tenant:=Choose(Value type($inParams.tenant)=Is undefined; "common"; String($inParams.tenant))
		
/*
Uri used to do the Authorization request.
*/
		This._authenticateURI:=String($inParams.authenticateURI)
		
/*
Uri used to request an access token.
*/
		This._tokenURI:=String($inParams.tokenURI)
		
/*
The application secret that you created in the app registration portal for your app. Required for web apps.
*/
		This.clientSecret:=String($inParams.clientSecret)
		
/*
Any valid existing token
*/
		This.token:=Choose(Value type($inParams.token)=Is object; $inParams.token; Null)
		
/*
*/
		This.tokenExpiration:=Choose(Value type($inParams.tokenExpiration)=Is text; $inParams.tokenExpiration; Null)
		
/*
*/
		This.timeout:=Choose(Value type($inParams.timeout)=Is undefined; 120; Num($inParams.timeout))
		
/*
Path of the web page to display in the webbrowser when the authentication code
is received correctly in signed in mode
If not present the default page is used
*/
		This.authenticationPage:=_retainFileObject($inParams.authenticationPage)
		
/*
Path of the web page to display in the webbrowser when the authentication server
returns an error in signed in mode
If not present the default page is used
*/
		This.authenticationErrorPage:=_retainFileObject($inParams.authenticationErrorPage)
		
/*
Indicates whether your application can refresh access tokens when the user is not
present at the browser. Valid parameter values are online, which is the default
value, and offline.
Set the value to offline if your application needs to refresh access tokens when
the user is not present at the browser. This is the method of refreshing access
tokens described later in this document.
This value instructs the Google authorization server to return a refresh token and
an access token the first time that your application exchanges an authorization code
for tokens.
*/
		If ((String($inParams.accessType)="online") || \
			(String($inParams.accessType)="offline"))
			This.accessType:=String($inParams.accessType)
		Else 
			This.accessType:="online"  // Default Access Type
		End if 
		
/*
If your application knows which user is trying to authenticate,
it can use this parameter to provide a hint to the Google Authentication Server.
The server uses the hint to simplify the login flow either by prefilling the email
field in the sign-in form or by selecting the appropriate multi-login session.
		
Set the parameter value to an email address or sub identifier, which is equivalent
to the user's Google ID.
*/
		This.loginHint:=String($inParams.loginHint)
		
/*
A space-delimited, case-sensitive list of prompts to present the user.
If you don't specify this parameter, the user will be prompted only the
first time your project requests access. See Prompting re-consent for more information.
Possible values are:
none: Do not display any authentication or consent screens.
Must not be specified with other values.
consent: Prompt the user for consent.
select_account: Prompt the user to select an account.
*/
		If ((String($inParams.prompt)="none") || \
			(String($inParams.prompt)="consent") || \
			(String($inParams.prompt)="select_account"))
			This.prompt:=String($inParams.prompt)
		End if 
		
/*
clientMail used by Google services account used
*/
		This.clientEmail:=String($inParams.clientEmail)
		
/*
privateKey may be used used by Google services account to sign JWT token
*/
		This.privateKey:=String($inParams.privateKey)
		
/*
_grantType used in Service mode to determine if we use a JWT or client_credentials
If empty value is "urn:ietf:params:oauth:grant-type:jwt-bearer" for Google services,
or "client_credentials" for other provider.
*/
		This._grantType:=String($inParams.grantType)
		
/*
Enable HTTP Server debug log for Debug purposes only
*/
		If (Bool($inParams.enableDebugLog))
			This.enableDebugLog:=True
		End if 
	End if 
	
	This._finally()
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getErrorDescription($inObject : Object) : Text
	
	var $result : Object
	var $keys : Collection
	var $key : Text
	
	$result:=New object
	$keys:=OB Keys($inObject)
	For each ($key; $keys)
		If (Position("error"; $key)=1)
			$result[$key]:=$inObject[$key]
		End if 
	End for each 
	
	return JSON Stringify($result)
	
	
	// ----------------------------------------------------
	
	
Function _isMicrosoft() : Boolean
	
	return (This.name="Microsoft")
	
	
	// ----------------------------------------------------
	
	
Function _isGoogle() : Boolean
	
	return (This.name="Google")
	
	
	// ----------------------------------------------------
	
	
Function _isSignedIn() : Boolean
	
	return (This.permission="signedIn")
	
	
	// ----------------------------------------------------
	
	
Function _isService() : Boolean
	
	return (This.permission="service")
	
	
	// ----------------------------------------------------
	
	
Function _OpenBrowserForAuthorisation()->$authorizationCode : Text
	
	var $url; $redirectURI; $state; $scope : Text
	
	$state:=Generate UUID
	$redirectURI:=This.redirectURI
	$url:=This.authenticateURI
	$scope:=This.scope
	
	// Sanity check
	Case of 
			
		: (Length(String(This.clientId))=0)
			This._throwError(2; New object("attribute"; "clientId"))
			
		: (Length(String($url))=0)
			This._throwError(2; New object("attribute"; "authenticateURI"))
			
		: ((This._isGoogle() || This._isMicrosoft()) && (Length(String($scope))=0))
			This._throwError(2; New object("attribute"; "scope"))
			
		: (This._isMicrosoft() && (Length(String(This.tenant))=0))
			This._throwError(2; New object("attribute"; "tenant"))
			
		: (This._isSignedIn() & (Length(String($redirectURI))=0))
			This._throwError(2; New object("attribute"; "redirectURI"))
			
		Else 
			
			$url+="?client_id="+This.clientId
			$url+="&response_type=code"
			$url+="&redirect_uri="+_urlEncode($redirectURI)
			$url+="&response_mode=query"
			If (Length(String($scope))>0)
				$url+="&scope="+_urlEncode($scope)
			End if 
			$url+="&state="+String($state)
			If (Length(String(This.accessType))>0)
				$url+="&access_type="+This.accessType
			End if 
			If (Length(String(This.loginHint))>0)
				$url+="&login_hint="+This.loginHint
			End if 
			If (Length(String(This.prompt))>0)
				$url+="&prompt="+This.prompt
			End if 
			
			Use (Storage)
				If (Storage.requests=Null)
					Storage.requests:=New shared object()
				End if 
				Use (Storage.requests)
					Storage.requests[$state]:=New shared object("redirectURI"; $redirectURI; \
						"state"; $state; \
						"authenticationPage"; (Value type(This.authenticationPage)#Is undefined) ? This.authenticationPage : Null; \
						"authenticationErrorPage"; (Value type(This.authenticationErrorPage)#Is undefined) ? This.authenticationErrorPage : Null)
				End use 
			End use 
			
			OPEN URL($url; *)
			
			var $endTime : Integer
			$endTime:=Milliseconds+(This.timeout*1000)
			While ((Milliseconds<=$endTime) & (Not(OB Is defined(Storage.requests[$state]; "token")) | (Storage.requests[$state].token=Null)))
				DELAY PROCESS(Current process; 10)
			End while 
			
			Use (Storage.requests)
				If (OB Is defined(Storage.requests; $state))
					Use (Storage.requests[$state])
						$authorizationCode:=Storage.requests[$state].token.code
						//If (OB Is defined(Storage.requests[$state].token; "state") & (Length(OB Get(Storage.requests[$state].token; "state"; Is text))>0))
						//ASSERT(Storage.requests[$state].token.state=$state; "state changed !!! CSRF Attack ?")
						//End if
						
						If (OB Is defined(Storage.requests[$state].token; "error"))
							This._throwError(12; \
								New object("function"; Current method name; \
								"message"; This._getErrorDescription(Storage.requests[$state].token)))
						End if 
					End use 
					OB REMOVE(Storage.requests; $state)
				End if 
			End use 
			
	End case 
	
	
	// ----------------------------------------------------
	
	
Function _getToken_SignedIn($bUseRefreshToken : Boolean)->$result : Object
	
	var $params : Text
	var $bSendRequest : Boolean
	
	$bSendRequest:=True
	If ($bUseRefreshToken)
		
		$params:="client_id="+This.clientId
		If (Length(This.scope)>0)
			$params+="&scope="+_urlEncode(This.scope)
		End if 
		$params+="&refresh_token="+This.token.refresh_token
		$params+="&grant_type=refresh_token"
		If (Length(This.clientSecret)>0)
			$params+="&client_secret="+This.clientSecret
		End if 
		
	Else 
		
		If ((Position("localhost"; This.redirectURI)>0) | (Position("127.0.0.1"; This.redirectURI)>0))
			
			var $options : Object
			$options:=New object
			$options.port:=_getPortFromURL(This.redirectURI)
			$options.enableDebugLog:=This.enableDebugLog
			If ((This.authenticationPage#Null) || (This.authenticationErrorPage#Null))
				var $file : Object
				$file:=(This.authenticationPage#Null) ? This.authenticationPage : This.authenticationErrorPage
				If (OB Instance of($file; 4D.File))
					$options.webFolder:=$file.parent
				End if 
			End if 
			
			If (_startWebServer($options))
				
				var $authorizationCode : Text
				$authorizationCode:=This._OpenBrowserForAuthorisation()
				
				If (Length($authorizationCode)>0)
					
					$params:="client_id="+This.clientId
					$params+="&scope="+_urlEncode(This.scope)
					$params+="&code="+$authorizationCode
					$params+="&redirect_uri="+_urlEncode(This.redirectURI)
					$params+="&grant_type=authorization_code"
					If (Length(This.clientSecret)>0)
						$params+="&client_secret="+This.clientSecret
					End if 
					
				Else 
					
					$bSendRequest:=False
					This._throwError(6)
					
				End if 
				
			Else 
				
				$bSendRequest:=False
				This._throwError(7; New object("port"; $options.port))
				
			End if 
		End if 
		
	End if 
	
	If ($bSendRequest)
		
		$result:=This._sendTokenRequest($params)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getToken_Service()->$result : Object
	
	var $params : Text
	
	Case of 
		: (This._useJWTBearer())
			
			var $jwt : cs._JWT
			var $options : Object
			var $bearer : Text
			
			$options:=New object("header"; New object("alg"; "RS256"; "typ"; "JWT"))
			
			$options.payload:=New object
			$options.payload.iss:=This.clientEmail
			$options.payload.scope:=This.scope
			$options.payload.aud:=This.tokenURI
			$options.payload.iat:=This._unixTime()
			$options.payload.exp:=$options.payload.iat+3600
			If ((Length(String(This.tenant))>0) && (Position("@"; This.tenant)>0))
				$options.payload.sub:=This.tenant
			End if 
			
			$options.privateKey:=This.privateKey
			
			$jwt:=cs._JWT.new($options)
			$bearer:=$jwt.generate()
			
			$params:="grant_type="+_urlEncode(This.grantType)
			$params+="&assertion="+$bearer
			
		Else 
			
			$params:="client_id="+This.clientId
			If (Length(This.scope)>0)
				$params+="&scope="+_urlEncode(This.scope)
			End if 
			$params+="&client_secret="+This.clientSecret
			$params+="&grant_type="+This.grantType
			
	End case 
	
	$result:=This._sendTokenRequest($params)
	
	
	// ----------------------------------------------------
	
	
Function _checkPrerequisites($obj : Object)->$OK : Boolean
	
	$OK:=False
	
	If (($obj#Null) & (Value type($obj)=Is object))
		
		Case of 
				
			: (Length(String($obj.clientId))=0)
				This._throwError(2; New object("attribute"; "clientId"))
				
			: ((Length(String($obj.name))>0) && (Length(String($obj.scope))=0))
				This._throwError(2; New object("attribute"; "scope"))
				
			: (Length(String($obj.permission))=0)
				This._throwError(2; New object("attribute"; "permission"))
				
			: (Not(String($obj.permission)="signedIn") & Not(String($obj.permission)="service"))
				This._throwError(3; New object("attribute"; "permission"))
				
			: ((String($obj.permission)="signedIn") & (Length(String($obj.redirectURI))=0))
				This._throwError(2; New object("attribute"; "redirectURI"))
				
			Else 
				$OK:=True
				
		End case 
		
	Else 
		
		This._throwError(1)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _sendTokenRequest($params : Text)->$result : Object
	
	var $response; $savedMethod : Text
	var $status : Integer
	
	var $options : Object
	var $request : 4D.HTTPRequest
	
	$options:=New object
	$options.headers:=New object("Content-Type"; "application/x-www-form-urlencoded"; \
		"Accept"; "application/json")
	$options.method:=HTTP POST method
	$options.body:=$params
	$options.dataType:="text"
	
	If (Value type(This._internals._rawBody)#Is undefined)
		OB REMOVE(This._internals; "_rawBody")
	End if 
	
	$savedMethod:=Method called on error
	This._installErrorHandler()
	$request:=4D.HTTPRequest.new(This.tokenURI; $options).wait()
	This._resetErrorHandler()
	$status:=$request["response"]["status"]
	$response:=$request["response"]["body"]
	
	If ($status=200)
		
		If (Length($response)>0)
			
			var $contentType : Text
			$contentType:=String($request["response"]["headers"]["content-type"])
			
			Case of 
				: (($contentType="application/json@") || ($contentType="text/plain@"))
					$result:=cs.OAuth2Token.new()
					$result._loadFromResponse($response)
					
				: ($contentType="application/x-www-form-urlencoded@")
					$result:=cs.OAuth2Token.new()
					$result._loadFromURLEncodedResponse($response)
					
				Else 
/*
We have a status 200 (no error) and a response that we don't know/want to interpret.
Simply return a null result (to be consistent with the specifications) and
copy the raw response body in a private member of the class
*/
					var $blob : Blob
					CONVERT FROM TEXT($response; _getHeaderValueParameter($contentType; "charset"; "UTF-8"); $blob)
					This._internals._rawBody:=4D.Blob.new($blob)
					$result:=Null
					
			End case 
			
		Else 
			
			var $licenseAvailable : Boolean
			If (Application type=4D Remote mode)
				$licenseAvailable:=Is license available(4D Client Web license)
			Else 
				$licenseAvailable:=(Is license available(4D Web license) | Is license available(4D Web local license) | Is license available(4D Web one connection license))
			End if 
			If ($licenseAvailable)
				This._throwError(4)  // Timeout error
			Else 
				This._throwError(11)  // License error
			End if 
			
		End if 
		
	Else 
		
		var $explanation : Text
		$explanation:=$request["response"]["statusText"]
		
		var $error : Object
		
		$error:=JSON Parse($response)
		If ($error#Null)
			var $errorCode : Integer
			var $message : Text
			
			If (Num($error.error_codes.length)>0)
				$errorCode:=Num($error.error_codes[0])
			End if 
			$message:=String($error.error_description)
			
			This._throwError(8; New object("status"; $status; "explanation"; $explanation; "message"; $message))
		Else 
			
			This._throwError(5; New object("received"; $status; "expected"; 200))
		End if 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _unixTime($inDate : Date; $inTime : Time)->$result : Real
/*
Unix_Time stolen from ThomasMaul/JWT_Token_Example
https://github.com/ThomasMaul/JWT_Token_Example/blob/main/Project/Sources/Methods/Unix_Time.4dm
*/
	
	var $start; $date : Date
	var $now : Text
	var $time : Time
	var $days : Integer
	
	$start:=!1970-01-01!
	
	If (Count parameters=0)
		$now:=Timestamp
		$now:=Substring($now; 1; Length($now)-5)  // remove milliseconds and Z
		$date:=Date($now)  // date in UTC
		$time:=Time($now)  // returns now time in UTC
	Else 
		$date:=$inDate
		$time:=$inTime
	End if 
	
	$days:=$date-$start
	$result:=($days*86400)+($time+0)  // convert in seconds
	
	
	// ----------------------------------------------------
	
	
Function _useJWTBearer() : Boolean
	
	return (This.grantType="urn:ietf:params:oauth:grant-type:jwt-bearer")
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getToken()->$result : Object
	
	This._try()
	
	var $bUseRefreshToken : Boolean
	
	$bUseRefreshToken:=False
	If (This.token#Null)
		var $token : cs.OAuth2Token
		$token:=cs.OAuth2Token.new(This)
		If (Not($token._Expired()))
			// Token is still valid.. Simply return it
			$result:=$token
		Else 
			$bUseRefreshToken:=(Length(String(This.token.refresh_token))>0)
		End if 
	End if 
	
	If ($result=Null)
		
		var $redirectURI; $authenticateURI; $tokenURI : Text
		
		$redirectURI:=This.redirectURI
		$authenticateURI:=This.authenticateURI
		$tokenURI:=This.tokenURI
		
		// Sanity check
		Case of 
				
			: (Length(String(This.clientId))=0)
				This._throwError(2; New object("attribute"; "clientId"))
				
			: (Length(String($authenticateURI))=0)
				This._throwError(2; New object("attribute"; "authenticateURI"))
				
			: ((This._isGoogle() || This._isMicrosoft()) && (Length(String(This.scope))=0))
				This._throwError(2; New object("attribute"; "scope"))
				
			: (Length(String($tokenURI))=0)
				This._throwError(2; New object("attribute"; "tokenURI"))
				
			: (This._isMicrosoft() && (Length(String(This.tenant))=0))
				This._throwError(2; New object("attribute"; "tenant"))
				
			: (Length(String(This.permission))=0)
				This._throwError(2; New object("attribute"; "permission"))
				
			: (This._isSignedIn() & (Length(String($redirectURI))=0))
				This._throwError(2; New object("attribute"; "permission"))
				
			: (Not(This._isSignedIn()) & Not(This._isService()))
				This._throwError(3; New object("attribute"; "permission"))
				
			Else 
				
				If (This._isSignedIn())
					
					$result:=This._getToken_SignedIn($bUseRefreshToken)
					
				Else 
					
					$result:=This._getToken_Service()
					
				End if 
				
				If ($result#Null)
					// Save token internally
					If (OB Is defined($result; "tokenExpiration"))
						This.tokenExpiration:=$result.tokenExpiration
					End if 
					This.token:=$result.token
				End if 
				
		End case 
		
	End if 
	
	This._finally()
	
	
	// ----------------------------------------------------
	
	
Function get authenticateURI() : Text
	
	var $authenticateURI : Text
	Case of 
		: (This._isMicrosoft())
			$authenticateURI:=Choose((Length(String(This._authenticateURI))>0); This._authenticateURI; "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize")
			$authenticateURI:=Replace string($authenticateURI; "{tenant}"; Choose((Length(String(This.tenant))>0); This.tenant; "common"))
			
		: (This._isGoogle())
			$authenticateURI:=Choose((Length(String(This._authenticateURI))>0); This._authenticateURI; "https://accounts.google.com/o/oauth2/auth")
			
		Else 
			$authenticateURI:=This._authenticateURI
			
	End case 
	
	return $authenticateURI
	
	
	// ----------------------------------------------------
	
	
Function get grantType() : Text
	
	If (Length(This._grantType)=0)
		If (This._isService() && This._isGoogle())
			return "urn:ietf:params:oauth:grant-type:jwt-bearer"
		Else 
			return "client_credentials"
		End if 
	End if 
	
	return This._grantType
	
	
	// ----------------------------------------------------
	
	
Function get scope()->$scope : Text
	
	Case of 
		: (This._isMicrosoft())
			$scope:=This._scope
			If ((This.accessType="offline") && (Position("offline_access"; $scope)=0))
				$scope:="offline_access "+$scope
			End if 
			
		Else 
			$scope:=This._scope
			
	End case 
	
	return $scope
	
	
	// ----------------------------------------------------
	
	
Function get tokenURI() : Text
	
	var $tokenURI : Text
	Case of 
		: (This._isMicrosoft())
			$tokenURI:=Choose((Length(String(This._tokenURI))>0); This._tokenURI; "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token")
			$tokenURI:=Replace string($tokenURI; "{tenant}"; Choose((Length(String(This.tenant))>0); This.tenant; "common"))
			
		: (This._isGoogle())
			$tokenURI:=Choose((Length(String(This._tokenURI))>0); This._tokenURI; "https://accounts.google.com/o/oauth2/token")
			
		Else 
			$tokenURI:=This._tokenURI
			
	End case 
	
	return $tokenURI
