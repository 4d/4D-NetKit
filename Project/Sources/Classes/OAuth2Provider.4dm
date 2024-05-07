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
property privateKey : Text  // privateKey may be used used to sign JWT token
property PKCEEnabled : Boolean  // if true, PKCE is used for OAuth 2.0 authentication and token requests (false by default)
property PKCEMethod : Text  // If S256: code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier))), if Plain: code_challenge = code_verifier (S256 by default)

property clientAssertionType : Text  // When authenticating with certificate this one is needed in body
property thumbprint : Text  // used to set x5t in JWT (x5t = BASE64URL-ENCODE(BYTEARRAY(thumbprint)))
property browserAutoOpen : Boolean  // If true, the class will automatically open the URL in signed mode to handle the authentication process (default is True)

property _scope : Text
property _authenticateURI : Text
property _tokenURI : Text
property _grantType : Text
property _codeVerifier : Text
property _state : Text

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
		This.authenticationPage:=cs.Tools.me.retainFileObject($inParams.authenticationPage)
		
/*
	Path of the web page to display in the webbrowser when the authentication server
	returns an error in signed in mode
	If not present the default page is used
*/
		This.authenticationErrorPage:=cs.Tools.me.retainFileObject($inParams.authenticationErrorPage)
		
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
		
/*
	PKCEEnabled : Boolean: if true, PKCE is used for OAuth 2.0 authentication and token requests (false by default)
	PKCEMethod : Text: PKCE Encoding method. The only supported values for are "S256" or "plain" ("S256" by default)
		
	See https://auth0.com/docs/get-started/authentication-and-authorization-flow/call-your-api-using-the-authorization-code-flow-with-pkce
*/
		This.PKCEEnabled:=Bool($inParams.PKCEEnabled)
		If (This.PKCEEnabled)
			This.PKCEMethod:=Choose(((String($inParams.PKCEMethod)="plain") || (String($inParams.PKCEMethod)="S256")); String($inParams.PKCEMethod); "S256")
		End if 
		
/*
	thumbprint of the public key / certificate  is used for the property x5t in jwt header
	When _thumprint is empty it's not possible to create a proper jwt token for request.
*/
		If (Value type($inParams.thumbprint)#Is undefined)
			This.thumbprint:=String($inParams.thumbprint)
		End if 
		If (Value type($inParams.clientAssertionType)#Is undefined)
			This.clientAssertionType:=String($inParams.clientAssertionType)
		End if 
		If ((Length(String(This.privateKey))>0) && (Length(String(This.thumbprint))>0) && (Length(String(This.clientAssertionType))=0))
			This.clientAssertionType:="urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
		End if 
		
		This._state:=Generate UUID
		This.browserAutoOpen:=Choose(Value type($inParams.browserAutoOpen)=Is undefined; True; Bool($inParams.browserAutoOpen))
		
	End if 
	
	This._finally()
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _generateCodeChallenge($codeVerifier : Text) : Text
	
	If (This.PKCEMethod="plain")
		return $codeVerifier  // code_challenge = code_verifier
	Else 
		return Generate digest($codeVerifier; SHA256 digest; *)  // code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _rangeRandom($min : Integer; $max : Integer) : Integer
	
	return (Random%($max-$min+1))+$min
	
	
	// ----------------------------------------------------
	
	
Function _randomString($size : Integer) : Text
	
	var $tab : Text:="-_abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ~."
	var $string : Text:=""
	
	While (Length($string)<$size)
		var $rnd : Integer:=This._rangeRandom(1; Length($tab))
		$string+=$tab[[$rnd]]
	End while 
	
	return $string
	
	
	// ----------------------------------------------------
	
	
Function _generateCodeVerifier : Text
	
	return This._randomString(This._rangeRandom(43; 128))
	
	
	// ----------------------------------------------------
	
	
Function get _x5t() : Text
	
	// x5t = BASE64URL-ENCODE(BYTEARRAY(thumbprint))
	var $byteArray : Blob
	var $i; $l_counter : Integer
	var $text : Text:=This.thumbprint
	var $textSize : Integer:=Length($text)
	
	SET BLOB SIZE($byteArray; ($textSize/2); 0)
	
	For ($i; 1; $textSize)
		
		Case of 
			: ($text[[$i]]="A")
				$byteArray{$l_counter}:=10*16
			: ($text[[$i]]="B")
				$byteArray{$l_counter}:=11*16
			: ($text[[$i]]="C")
				$byteArray{$l_counter}:=12*16
			: ($text[[$i]]="D")
				$byteArray{$l_counter}:=13*16
			: ($text[[$i]]="E")
				$byteArray{$l_counter}:=14*16
			: ($text[[$i]]="F")
				$byteArray{$l_counter}:=15*16
			Else 
				$byteArray{$l_counter}:=Num($text[[$i]])*16
		End case 
		
		$i:=$i+1
		If ($i>$textSize)  // Sanity check
			break
		End if 
		
		Case of 
			: ($text[[$i]]="A")
				$byteArray{$l_counter}:=$byteArray{$l_counter}+10
			: ($text[[$i]]="B")
				$byteArray{$l_counter}:=$byteArray{$l_counter}+11
			: ($text[[$i]]="C")
				$byteArray{$l_counter}:=$byteArray{$l_counter}+12
			: ($text[[$i]]="D")
				$byteArray{$l_counter}:=$byteArray{$l_counter}+13
			: ($text[[$i]]="E")
				$byteArray{$l_counter}:=$byteArray{$l_counter}+14
			: ($text[[$i]]="F")
				$byteArray{$l_counter}:=$byteArray{$l_counter}+15
			Else 
				$byteArray{$l_counter}:=$byteArray{$l_counter}+Num($text[[$i]])
		End case 
		
		$l_counter+=1
	End for 
	
	BASE64 ENCODE($byteArray; *)
	return BLOB to text($byteArray; UTF8 text without length)
	
	
	// ----------------------------------------------------
	
	
Function _getErrorDescription($inObject : Object) : Text
	
	var $result : Object:={}
	var $keys : Collection:=OB Keys($inObject)
	var $key : Text
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
	
	
Function _getAuthorizationCode() : Text
	
	var $authorizationCode : Text:=""
	var $redirectURI : Text:=This.redirectURI
	var $authenticateURI : Text:=This.authenticateURI
	var $scope : Text:=This.scope
	
	// Sanity check
	Case of 
			
		: (Length(String(This.clientId))=0)
			This._throwError(2; {attribute: "clientId"})
			
		: (Length(String($authenticateURI))=0)
			This._throwError(2; {attribute: "authenticateURI"})
			
		: ((This._isGoogle() || This._isMicrosoft()) && (Length(String($scope))=0))
			This._throwError(2; {attribute: "scope"})
			
		: (This._isMicrosoft() && (Length(String(This.tenant))=0))
			This._throwError(2; {attribute: "tenant"})
			
		: (This._isSignedIn() && (Length(String($redirectURI))=0))
			This._throwError(2; {attribute: "redirectURI"})
			
		Else 
			
			var $state : Text:=This._state
			
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
			
			If (This.browserAutoOpen)
				OPEN URL($authenticateURI; *)
			End if 
			
			var $endTime : Integer:=Milliseconds+(This.timeout*1000)
			While ((Milliseconds<=$endTime) && (Not(OB Is defined(Storage.requests[$state]; "token")) | (Storage.requests[$state].token=Null)))
				DELAY PROCESS(Current process; 10)
			End while 
			
			Use (Storage.requests)
				If (OB Is defined(Storage.requests; $state))
					Use (Storage.requests[$state])
						$authorizationCode:=String(Storage.requests[$state].token.code)
						
						If (OB Is defined(Storage.requests[$state]; "token") && OB Is defined(Storage.requests[$state].token; "error"))
							This._throwError(12; {function: Current method name; message: This._getErrorDescription(Storage.requests[$state].token)})
						End if 
					End use 
					OB REMOVE(Storage.requests; $state)
				End if 
			End use 
			
	End case 
	
	return $authorizationCode
	
	
	// ----------------------------------------------------
	
	
Function _getToken_SignedIn($bUseRefreshToken : Boolean)->$result : Object
	
	var $params : Text
	var $bSendRequest : Boolean:=True
	If ($bUseRefreshToken)
		
		$params:="client_id="+This.clientId
		If (Length(This.scope)>0)
			$params+="&scope="+cs.Tools.me.urlEncode(This.scope)
		End if 
		$params+="&refresh_token="+This.token.refresh_token
		$params+="&grant_type=refresh_token"
		If (Length(This.clientSecret)>0)
			$params+="&client_secret="+This.clientSecret
		End if 
		
	Else 
		
		If (Length(String(This.redirectURI))>0)
			
			var $options : Object:={}
			$options.port:=cs.Tools.me.getPortFromURL(This.redirectURI)
			$options.enableDebugLog:=This.enableDebugLog
			$options.useTLS:=(Position("https"; This.redirectURI)=1)
			If ((This.authenticationPage#Null) || (This.authenticationErrorPage#Null))
				var $file : Object:=(This.authenticationPage#Null) ? This.authenticationPage : This.authenticationErrorPage
				If (OB Instance of($file; 4D.File))
					$options.webFolder:=$file.parent
				End if 
			End if 
			
			If (cs.Tools.me.startWebServer($options))
				
				var $authorizationCode : Text:=This._getAuthorizationCode()
				
				If (Length($authorizationCode)>0)
					
					$params:="client_id="+This.clientId
					$params+="&grant_type=authorization_code"
					$params+="&code="+$authorizationCode
					$params+="&redirect_uri="+cs.Tools.me.urlEncode(This.redirectURI)
					If (This.PKCEEnabled)
						$params+="&code_verifier="+This.codeVerifier
					End if 
					If (Length(This.clientSecret)>0)
						$params+="&client_secret="+This.clientSecret
					End if 
					$params+="&scope="+cs.Tools.me.urlEncode(This.scope)
					
				Else 
					
					$bSendRequest:=False
					This._throwError(6)
					
				End if 
				
			Else 
				
				$bSendRequest:=False
				This._throwError(7; {port: $options.port})
				
			End if 
		End if 
		
	End if 
	
	If ($bSendRequest)
		
		$result:=This._sendTokenRequest($params)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getToken_Service()->$result : Object
	
	var $params : Text
	var $jwt : cs._JWT
	var $options : Object
	var $bearer : Text
	
	Case of 
		: (This._useJWTBearer())
			
			$options:={header: {alg: "RS256"; typ: "JWT"}}
			$options.payload:={}
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
			
			$params:="grant_type="+cs.Tools.me.urlEncode(This.grantType)
			$params+="&assertion="+$bearer
			
		: (This._useJWTBearerAssertionType())
			// See documentation of https://learn.microsoft.com/en-us/entra/identity-platform/certificate-credentials
			$options:={header: {alg: "RS256"; typ: "JWT"; x5t: This._x5t}}
			
			$options.payload:={}
			$options.payload.iss:=This.clientId  // Must be client id of app registration
			$options.payload.scope:=This.scope
			$options.payload.aud:=This.tokenURI
			$options.payload.iat:=This._unixTime()
			$options.payload.exp:=$options.payload.iat+3600
			$options.payload.sub:=This.clientId  // Same as iss
			
			$options.privateKey:=This.privateKey
			
			$jwt:=cs._JWT.new($options)
			$bearer:=$jwt.generate()
			
			// See documentation of https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow#second-case-access-token-request-with-a-certificate
			$params:="grant_type="+This.grantType
			$params+="&client_id="+This.clientId
			$params+="&scope="+cs.Tools.me.urlEncode(This.scope)
			$params+="&client_assertion_type="+cs.Tools.me.urlEncode(This.clientAssertionType)
			$params+="&client_assertion="+$bearer
			
		Else 
			
			$params:="client_id="+This.clientId
			If (Length(This.scope)>0)
				$params+="&scope="+cs.Tools.me.urlEncode(This.scope)
			End if 
			$params+="&client_secret="+This.clientSecret
			$params+="&grant_type="+This.grantType
			
	End case 
	
	$result:=This._sendTokenRequest($params)
	
	
	// ----------------------------------------------------
	
	
Function _checkPrerequisites($obj : Object)->$OK : Boolean
	
	$OK:=False
	
	If (($obj#Null) && (Value type($obj)=Is object))
		
		Case of 
				
			: (Length(String($obj.clientId))=0)
				This._throwError(2; {attribute: "clientId"})
				
			: ((Length(String($obj.name))>0) && (Length(String($obj.scope))=0))
				This._throwError(2; {attribute: "scope"})
				
			: (Length(String($obj.permission))=0)
				This._throwError(2; {attribute: "permission"})
				
			: (Not(String($obj.permission)="signedIn") && Not(String($obj.permission)="service"))
				This._throwError(3; {attribute: "permission"})
				
			: ((String($obj.permission)="signedIn") && (Length(String($obj.redirectURI))=0))
				This._throwError(2; {attribute: "redirectURI"})
				
			Else 
				$OK:=True
				
		End case 
		
	Else 
		
		This._throwError(1)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _sendTokenRequest($params : Text)->$result : Object
	
	var $options : Object:={headers: {}}
	$options.headers["Content-Type"]:="application/x-www-form-urlencoded"
	$options.headers["Accept"]:="application/json"
	$options.method:=HTTP POST method
	$options.body:=$params
	$options.dataType:="text"
	
	If (Value type(This._internals._rawBody)#Is undefined)
		OB REMOVE(This._internals; "_rawBody")
	End if 
	
	var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new(This.tokenURI; $options).wait())
	var $status : Integer:=Num($request["response"]["status"])
	var $response : Text:=String($request["response"]["body"])
	
	If ($status=200)
		
		If (Length($response)>0)
			
			var $contentType : Text:=String($request["response"]["headers"]["content-type"])
			
			Case of 
				: (($contentType="application/json@") || ($contentType="text/plain@"))
					$result:=cs.OAuth2Token.new()
					$result._loadFromResponse($response)
					
				: ($contentType="application/x-www-form-urlencoded@")
					$result:=cs.OAuth2Token.new()
					$result._loadFromURLEncodedResponse($response)
					
				Else 
/*
 *					We have a status 200 (no error) and a response that we don't know/want to interpret.
 *					Simply return a null result (to be consistent with the specifications) and
 *					copy the raw response body in a private member of the class
 */
					var $blob : Blob
					CONVERT FROM TEXT($response; cs.Tools.me.getHeaderValueParameter($contentType; "charset"; "UTF-8"); $blob)
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
		
		var $error : Object:=Try(JSON Parse($response))
		If ($error#Null)
			
			var $statusText : Text:=String($request["response"]["statusText"])
			var $errorCode : Integer
			
			If (Num($error.error_codes.length)>0)
				$errorCode:=Num($error.error_codes[0])
			End if 
			var $message : Text:=String($error.error_description)
			
			This._throwError(8; {status: $status; explanation: $statusText; message: $message})
		Else 
			
			This._throwError(5; {received: $status; expected: 200})
		End if 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _unixTime($inDate : Date; $inTime : Time)->$result : Real
/*
 *	Unix_Time stolen from ThomasMaul/JWT_Token_Example
 *	https://github.com/ThomasMaul/JWT_Token_Example/blob/main/Project/Sources/Methods/Unix_Time.4dm
 */
	
	var $start : Date:=!1970-01-01!
	var $date : Date
	var $time : Time
	
	If (Count parameters=0)
		var $now : Text:=Timestamp
		$now:=Substring($now; 1; Length($now)-5)  // remove milliseconds and Z
		$date:=Date($now)  // date in UTC
		$time:=Time($now)  // returns now time in UTC
	Else 
		$date:=$inDate
		$time:=$inTime
	End if 
	
	var $days : Integer:=$date-$start
	$result:=Num(($days*86400)+($time+0))  // convert in seconds
	
	
	// ----------------------------------------------------
	
	
Function _useJWTBearer() : Boolean
	
	return (This.grantType="urn:ietf:params:oauth:grant-type:jwt-bearer")
	
	
	// ----------------------------------------------------
	
	
Function _useJWTBearerAssertionType() : Boolean
	
	return (Length(String(This.thumbprint))>0)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getToken()->$result : Object
	
	This._try()
	
	var $bUseRefreshToken : Boolean:=False
	If (This.token#Null)
		var $token : cs.OAuth2Token:=cs.OAuth2Token.new(This)
		If (Not($token._Expired()))
			// Token is still valid.. Simply return it
			$result:=$token
		Else 
			$bUseRefreshToken:=(Length(String(This.token.refresh_token))>0)
		End if 
	End if 
	
	If ($result=Null)
		
		var $redirectURI : Text:=This.redirectURI
		var $authenticateURI : Text:=This.authenticateURI
		var $tokenURI : Text:=This.tokenURI
		
		// Sanity check
		Case of 
				
			: (Length(String(This.clientId))=0)
				This._throwError(2; {attribute: "clientId"})
				
			: (Length(String($authenticateURI))=0)
				This._throwError(2; {attribute: "authenticateURI"})
				
			: ((This._isGoogle() || This._isMicrosoft()) && (Length(String(This.scope))=0))
				This._throwError(2; {attribute: "scope"})
				
			: (Length(String($tokenURI))=0)
				This._throwError(2; {attribute: "tokenURI"})
				
			: (This._isMicrosoft() && (Length(String(This.tenant))=0))
				This._throwError(2; {attribute: "tenant"})
				
			: (Length(String(This.permission))=0)
				This._throwError(2; {attribute: "permission"})
				
			: (This._isSignedIn() && (Length(String($redirectURI))=0))
				This._throwError(2; {attribute: "permission"})
				
			: (Not(This._isSignedIn()) && Not(This._isService()))
				This._throwError(3; {attribute: "permission"})
				
			Else 
				
				Case of 
						
					: (This._isSignedIn())
						$result:=This._getToken_SignedIn($bUseRefreshToken)
						
					: (This._isService())
						$result:=This._getToken_Service()
						
					Else 
						This._throwError(3; {attribute: "permission"})
						
				End case 
				
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
	
	If (This._isSignedIn())
		
		var $scope : Text:=This.scope
		var $state : Text:=This._state
		var $redirectURI : Text:=This.redirectURI
		var $urlParams : Text
		
		$urlParams:="?client_id="+This.clientId
		$urlParams+="&response_type=code"
		If (Length(String($scope))>0)
			$urlParams+="&scope="+cs.Tools.me.urlEncode($scope)
		End if 
		$urlParams+="&state="+String($state)
		$urlParams+="&response_mode=query"
		$urlParams+="&redirect_uri="+cs.Tools.me.urlEncode($redirectURI)
		If (This.PKCEEnabled)
			$urlParams+="&code_challenge="+This._generateCodeChallenge(This.codeVerifier)
			$urlParams+="&code_challenge_method="+String(This.PKCEMethod)
		Else 
			If (Length(String(This.accessType))>0)
				$urlParams+="&access_type="+This.accessType
			End if 
			If (Length(String(This.loginHint))>0)
				$urlParams+="&login_hint="+This.loginHint
			End if 
			If (Length(String(This.prompt))>0)
				$urlParams+="&prompt="+This.prompt
			End if 
		End if 
		
		$authenticateURI+=$urlParams
	End if 
	
	return $authenticateURI
	
	
	// ----------------------------------------------------
	
	
Function get codeVerifier() : Text
	
	If (Length(String(This._codeVerifier))=0)
		This._codeVerifier:=This._generateCodeVerifier()
	End if 
	
	return This._codeVerifier
	
	
	// ----------------------------------------------------
	
	
Function get grantType() : Text
	
	If (Length(String(This._grantType))=0)
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
	
	
	// ----------------------------------------------------
	
	
Function isTokenValid() : Boolean
	
	If (This.token#Null)
		var $token : cs.OAuth2Token:=cs.OAuth2Token.new(This)
		If (Not($token._Expired()))
			return True
		Else 
			If (Length(String(This.token.refresh_token))>0)
				var $newToken : Object:=This.getToken()
				return ($newToken#Null)
			End if 
		End if 
	End if 
	
	return False
	
	
	// ----------------------------------------------------
