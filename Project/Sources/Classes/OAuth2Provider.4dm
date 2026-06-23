/**
 * @class OAuth2Provider
 * @description Core OAuth2 client supporting both `signedIn` (Authorization Code) and
 *   `service` (Client Credentials / JWT Bearer) flows for Google and Microsoft providers.
 *   Handles token acquisition, refresh, PKCE, JWT generation (RS256/HS256/PS256),
 *   and certificate-based client assertions (x5t thumbprint).
 *
 * @example
 *   var $provider : cs.OAuth2Provider := cs.OAuth2Provider.new({\n *     name: "Microsoft"; permission: "signedIn"; clientId: "...";\n *     redirectURI: "http://localhost:9999/authorize"; scope: "Mail.Read"\n *   })
 *   var $token : cs.OAuth2Token := $provider.getToken()
 */

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
property authenticationPage : Variant
property authenticationErrorPage : Variant
property accessType : Text
property loginHint : Text
property prompt : Text
property clientEmail : Text  // clientMail used by Google services account used
property privateKey : Text  // privateKey may be used used to sign JWT token
property privateKeyId : Text  // Private key ID (kid in JWT header) used by Google service accounts
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

property state : Text
property nonce : Text  // For OpenID Connect

property enableDebugLog : Boolean  // Enable HTTP Server debug log for Debug purposes only

Class constructor($inParams : Object)
/**
 * @constructor
 * @param {Object} $inParams - Provider configuration; required fields vary by flow:
 *   - `name` {Text} — Provider name: `"Google"` or `"Microsoft"`
 *   - `permission` {Text} — `"signedIn"` (Authorization Code) or `"service"` (Client Credentials)
 *   - `clientId` {Text} — Application (client) ID from the registration portal
 *   - `redirectURI` {Text} — Redirect URI (required for `signedIn` mode)
 *   - `scope` {Text|Collection} — Space-separated or collection of OAuth2 scopes
 *   - `clientSecret` {Text} — Client secret (required for most flows)
 *   - `tenant` {Text} — Microsoft tenant ID / domain (default `"common"`)
 *   - `token` {Object} — Existing token to reuse
 *   - `tokenExpiration` {Text} — ISO 8601 expiration of existing token
 *   - `timeout` {Integer} — Authorization timeout in seconds (default 120)
 *   - `accessType` {Text} — `"online"` (default) or `"offline"` (Google refresh token)
 *   - `loginHint` {Text} — Pre-fill the email field (Google)
 *   - `prompt` {Text} — `"none"`, `"consent"`, or `"select_account"`
 *   - `clientEmail` {Text} — Service account email (Google service accounts)
 *   - `privateKey` {Text} — PEM private key for JWT signing
 *   - `privateKeyId` {Text} — Private key ID from service account JSON (sets `kid` in JWT header)
 *   - `thumbprint` {Text} — Certificate thumbprint hex string (sets `x5t` in JWT)
 *   - `clientAssertionType` {Text} — Overrides default assertion type URI
 *   - `PKCEEnabled` {Boolean} — Enable PKCE (default `False`)
 *   - `PKCEMethod` {Text} — `"S256"` (default) or `"plain"`
 *   - `state` {Text} — Custom state value (alphanumeric + `-_`; UUID generated if omitted)
 *   - `nonce` {Text} — Nonce for OpenID Connect
 *   - `browserAutoOpen` {Boolean} — Auto-open browser in `signedIn` mode (default `True`)
 *   - `enableDebugLog` {Boolean} — Enable HTTP server debug log
 */
	
	Super()
	
	Try
		
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
			If ((Value type($inParams.token)=Is object) && (Value type($inParams.token.token)=Is object))
				This.token:=$inParams.token.token
			Else 
				This.token:=Choose(Value type($inParams.token)=Is object; $inParams.token; Null)
			End if 
			
/*
*/
			If ((Value type($inParams.token)=Is object) && (Value type($inParams.token.tokenExpiration)=Is text))
				This.tokenExpiration:=$inParams.token.tokenExpiration
			Else 
				This.tokenExpiration:=Choose(Value type($inParams.tokenExpiration)=Is text; $inParams.tokenExpiration; Null)
			End if 
			
/*
*/
			This.timeout:=Choose(Value type($inParams.timeout)=Is undefined; 120; Num($inParams.timeout))
			
/*
	Path of the web page to display in the webbrowser when the authentication code
	is received correctly in signed in mode
	If not present the default page is used
*/
			If ((Value type($inParams.authenticationPage)=Is text) && cs._Tools.me.isValidURL(String($inParams.authenticationPage)))
				This.authenticationPage:=String($inParams.authenticationPage)
			Else 
				This.authenticationPage:=cs._Tools.me.retainFileObject($inParams.authenticationPage)
			End if 
/*
	Path of the web page to display in the webbrowser when the authentication server
	returns an error in signed in mode
	If not present the default page is used
*/
			If ((Value type($inParams.authenticationErrorPage)=Is text) && cs._Tools.me.isValidURL(String($inParams.authenticationErrorPage)))
				This.authenticationErrorPage:=String($inParams.authenticationErrorPage)
			Else 
				This.authenticationErrorPage:=cs._Tools.me.retainFileObject($inParams.authenticationErrorPage)
			End if 
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
	privateKeyId used for Google services account in JWT header (kid field)
	Founds in the service account JSON file as "private_key_id"
*/
			This.privateKeyId:=String($inParams.privateKeyId)
			
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
			
			If ((Value type($inParams.state)=Is text) && (Length($inParams.state)>0))
				This.state:=This._cleanString($inParams.state)  // Keep only letters, digits, - and _
				If (Length(This.state)=0)
					This.state:=Generate UUID
				End if 
			Else 
				This.state:=Generate UUID
			End if 
			If ((Value type($inParams.nonce)=Is text) && (Length($inParams.nonce)>0))
				This.nonce:=$inParams.nonce
			End if 
			This.browserAutoOpen:=Choose(Value type($inParams.browserAutoOpen)=Is undefined; True; Bool($inParams.browserAutoOpen))
			
		End if 
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _cleanString($inString : Text) : Text
/**
 * @function _cleanString
 * @private
 * @param {Text} $inString - Raw string to sanitise
 * @returns {Text} String containing only `A-Z`, `a-z`, `0-9`, `-`, and `_`
 * @description Strips all characters not safe for use as an OAuth2 `state` value
 */
	
	var $string : Text:=""
	var $i; $code : Integer
	var $len : Integer:=Length($inString)
	var $c : Text
	
	For ($i; 1; $len)
		$c:=Substring($inString; $i; 1)
		$code:=Character code($c)
		
		// Keep only letter (A-Z, a-z), numbers (0-9), and '-', '_'
		If ((($code>=48) && ($code<=57)) || \
			(($code>=65) && ($code<=90)) || \
			(($code>=97) && ($code<=122)) || \
			(($c="-") || ($c="_")))
			$string+=$c
		End if 
	End for 
	
	return $string
	
	
	// ----------------------------------------------------
	
	
Function _generateCodeChallenge($codeVerifier : Text) : Text
/**
 * @function _generateCodeChallenge
 * @private
 * @param {Text} $codeVerifier - PKCE code verifier
 * @returns {Text} `code_challenge` value:
 *   Base64URL-encoded SHA-256 hash of the verifier (`S256` method) or
 *   the verifier itself (`plain` method)
 */
	
	If (This.PKCEMethod="plain")
		return $codeVerifier  // code_challenge = code_verifier
	Else 
		return Generate digest($codeVerifier; SHA256 digest; *)  // code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _generateCodeVerifier : Text
/**
 * @function _generateCodeVerifier
 * @private
 * @returns {Text} Cryptographically random PKCE code verifier string;
 *   length is randomly chosen between 43 and 128 characters;
 *   characters are drawn from the PKCE-safe alphabet (`A-Z a-z 0-9 - _ ~ .`)
 */
	
	var $chars : Text:="-_abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ~."
	var $charsLen : Integer:=Length($chars)
	var $uuid : Text:=Replace string(Generate UUID; "-"; "")  // 32 hex chars
	var $size : Integer:=43+((This._hexCharToNum($uuid[[1]])*16+This._hexCharToNum($uuid[[2]]))%86)  // Random size between 43 and 128
	var $string : Text:=""
	var $hexPool : Text:=""
	
	// Build a pool of random hex chars from UUIDs (each UUID = 32 hex chars = 16 random bytes)
	var $needed : Integer:=$size*2  // 2 hex chars per random byte
	While (Length($hexPool)<$needed)
		$hexPool+=Replace string(Generate UUID; "-"; "")
	End while 
	
	var $i : Integer
	For ($i; 0; $size-1)
		var $byte : Integer:=(This._hexCharToNum($hexPool[[$i*2+1]])*16)+This._hexCharToNum($hexPool[[$i*2+2]])
		$string+=$chars[[($byte%$charsLen)+1]]
	End for 
	
	return $string
	
	
	// ----------------------------------------------------
	
	
Function _hexCharToNum($c : Text) : Integer
/**
 * @function _hexCharToNum
 * @private
 * @param {Text} $c - A single hexadecimal character (`0-9`, `A-F`, `a-f`)
 * @returns {Integer} Numeric value 0–15; returns 0 for unrecognised characters
 */
	
	var $code : Integer:=Character code($c)
	Case of 
		: (($code>=48) && ($code<=57))  // 0-9
			return $code-48
		: (($code>=65) && ($code<=70))  // A-F
			return $code-55
		: (($code>=97) && ($code<=102))  // a-f
			return $code-87
	End case 
	
	return 0
	
	
	// ----------------------------------------------------
	
	
Function get _x5t() : Text
/**
 * @function get _x5t
 * @private
 * @returns {Text} Base64URL-encoded byte array of the `thumbprint` hex string;
 *   used as the `x5t` (X.509 certificate thumbprint) claim in JWT headers
 *   for certificate-based client assertions
 */
	
	// x5t = BASE64URL-ENCODE(BYTEARRAY(thumbprint))
	var $byteArray : Blob
	var $i; $l_counter : Integer
	var $text : Text:=This.thumbprint
	var $textSize : Integer:=Length($text)
	
	SET BLOB SIZE($byteArray; ($textSize/2); 0)
	
	For ($i; 1; $textSize; 2)
		$byteArray{$l_counter}:=(This._hexCharToNum($text[[$i]])*16)+This._hexCharToNum($text[[$i+1]])
		$l_counter+=1
	End for 
	
	BASE64 ENCODE($byteArray; *)
	return BLOB to text($byteArray; UTF8 text without length)
	
	
	// ----------------------------------------------------
	
	
Function _getErrorDescription($inObject : Object) : Text
/**
 * @function _getErrorDescription
 * @private
 * @param {Object} $inObject - Token endpoint error response object
 * @returns {Text} JSON string of all `error*` keys from the response
 * @description Extracts error-related fields (e.g. `error`, `error_description`,
 *   `error_codes`) from a Graph/OAuth2 error response for inclusion in thrown errors
 */
	
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
/**
 * @function _isMicrosoft
 * @private
 * @returns {Boolean} `True` when `name = "Microsoft"`
 */
	
	return (This.name="Microsoft")
	
	
	// ----------------------------------------------------
	
	
Function _isGoogle() : Boolean
/**
 * @function _isGoogle
 * @private
 * @returns {Boolean} `True` when `name = "Google"`
 */
	
	return (This.name="Google")
	
	
	// ----------------------------------------------------
	
	
Function _isSignedIn() : Boolean
/**
 * @function _isSignedIn
 * @private
 * @returns {Boolean} `True` when `permission = "signedIn"`
 */
	
	return (This.permission="signedIn")
	
	
	// ----------------------------------------------------
	
	
Function _isService() : Boolean
/**
 * @function _isService
 * @private
 * @returns {Boolean} `True` when `permission = "service"`
 */
	
	return (This.permission="service")
	
	
	// ----------------------------------------------------
	
	
Function _getAuthorizationCode() : Text
/**
 * @function _getAuthorizationCode
 * @private
 * @returns {Text} Authorization code string from the redirect; empty string on timeout or error
 * @description Opens the authorization URL in the browser (unless `browserAutoOpen` is `False`),
 *   then polls `Storage.requests[state]` until a code or error is received or `timeout` expires.
 *   Throws errors for missing `clientId`, `authenticateURI`, `scope`, `tenant`,
 *   or `redirectURI`.
 */
	
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
			
			var $state : Text:=This.state
			
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
	
	
Function _getToken_SignedIn($bUseRefreshToken : Boolean) : Object
/**
 * @function _getToken_SignedIn
 * @private
 * @param {Boolean} $bUseRefreshToken - When `True`, uses the stored `refresh_token`
 *   instead of triggering a new authorization code flow
 * @returns {Object} `OAuth2Token` instance, or `Null` on failure
 * @description Handles the Authorization Code and Refresh Token flows:
 *   starts a local web server for the redirect, waits for the authorization code,
 *   then exchanges it for a token via `_sendTokenRequest`
 */
	
	var $result : Object:=Null
	var $params : cs._URL:=cs._URL.new()
	var $bSendRequest : Boolean:=True
	If ($bUseRefreshToken)
		
		$params.addQueryParameter("client_id"; This.clientId)
		If (Length(This.scope)>0)
			$params.addQueryParameter("scope"; cs._Tools.me.urlEncode(This.scope))
		End if 
		$params.addQueryParameter("refresh_token"; This.token.refresh_token)
		$params.addQueryParameter("grant_type"; "refresh_token")
		If (Length(This.clientSecret)>0)
			$params.addQueryParameter("client_secret"; This.clientSecret)
		End if 
		
	Else 
		
		If (Length(String(This.redirectURI))>0)
			
			var $options : Object:={}
			$options.port:=cs._Tools.me.getPortFromURL(This.redirectURI)
			$options.enableDebugLog:=This.enableDebugLog
			$options.useTLS:=(Position("https"; This.redirectURI)=1)
			If ((Value type(This.authenticationPage)=Is object) || (Value type(This.authenticationErrorPage)=Is object))
				var $file : Object:=Null
				Case of 
					: (Value type(This.authenticationPage)=Is object)
						$file:=This.authenticationPage
					: (Value type(This.authenticationErrorPage)=Is object)
						$file:=This.authenticationErrorPage
				End case 
				If (OB Instance of($file; 4D.File))
					$options.webFolder:=$file.parent
				End if 
			End if 
			
			var $bUseHostDatabaseServer : Boolean:=False
			var $hostDatabaseServer : Object:=WEB Server(Web server host database)
			If (($hostDatabaseServer#Null) && $hostDatabaseServer.isRunning)
				If ($options.useTLS)
					$bUseHostDatabaseServer:=($hostDatabaseServer.HTTPSEnabled && ($hostDatabaseServer.HTTPSPort=$options.port))
				Else 
					$bUseHostDatabaseServer:=($hostDatabaseServer.HTTPEnabled && ($hostDatabaseServer.HTTPPort=$options.port))
				End if 
			End if 
			
			var $webServerStatus : Object:={success: $bUseHostDatabaseServer; error: Null}
			If (Not($bUseHostDatabaseServer))
				$webServerStatus:=cs._Tools.me.startWebServer($options)
			End if 
			
			If ($webServerStatus.success)
				
				var $authorizationCode : Text:=This._getAuthorizationCode()
				
				If (Length($authorizationCode)>0)
					
					$params.addQueryParameter("client_id"; This.clientId)
					$params.addQueryParameter("grant_type"; "authorization_code")
					$params.addQueryParameter("code"; $authorizationCode)
					$params.addQueryParameter("redirect_uri"; cs._Tools.me.urlEncode(This.redirectURI))
					If (This.PKCEEnabled)
						$params.addQueryParameter("code_verifier"; This.codeVerifier)
					End if 
					If (Length(This.clientSecret)>0)
						$params.addQueryParameter("client_secret"; This.clientSecret)
					End if 
					$params.addQueryParameter("scope"; cs._Tools.me.urlEncode(This.scope))
					
				Else 
					
					$bSendRequest:=False
					This._throwError(6)
					
				End if 
				
			Else 
				
				$bSendRequest:=False
				If (($webServerStatus.error#Null) && (Value type($webServerStatus.error)=Is object))
					var $serverError : Object:=OB Copy($webServerStatus.error)
					This._internals._errorStack.push($serverError)
					$serverError.deferred:=True
					throw($serverError)
				Else 
					This._throwError(7; {port: $options.port})
				End if 
				
			End if 
		End if 
		
	End if 
	
	If ($bSendRequest)
		
		$result:=This._sendTokenRequest($params.query)
		
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function _getToken_Service() : Object
/**
 * @function _getToken_Service
 * @private
 * @returns {Object} `OAuth2Token` instance, or `Null` on failure
 * @description Handles the Client Credentials and JWT Bearer flows:
 *   - **JWT Bearer** (`urn:ietf:params:oauth:grant-type:jwt-bearer`): signs a JWT with
 *     the service account private key (Google)
 *   - **JWT Bearer + assertion type** (x5t thumbprint set): builds a certificate-based
 *     client assertion (Microsoft Entra)
 *   - **Client Credentials**: sends `client_id`, `client_secret`, `grant_type`
 */
	
	var $result : Object:=Null
	var $params : cs._URL:=cs._URL.new()
	var $jwt : cs.JWT:=cs.JWT.new(This.privateKey)
	var $options : Object
	var $bearer : Text
	
	Case of 
		: (This._useJWTBearer())
			
			$options:={header: {alg: "RS256"; typ: "JWT"}}
			If (Length(String(This.privateKeyId))>0)
				$options.header.kid:=This.privateKeyId
			End if 
			$options.payload:={}
			$options.payload.iss:=This.clientEmail
			$options.payload.scope:=This.scope
			$options.payload.aud:=This.tokenURI
			$options.payload.iat:=This._unixTime()
			$options.payload.exp:=$options.payload.iat+3600
			If ((Length(String(This.tenant))>0) && (Position("@"; This.tenant)>0))
				$options.payload.sub:=This.tenant
			End if 
			
			$bearer:=$jwt.generate($options)
			
			$params.addQueryParameter("grant_type"; cs._Tools.me.urlEncode(This.grantType))
			$params.addQueryParameter("assertion"; $bearer)
			
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
			
			$bearer:=$jwt.generate($options)
			
			// See documentation of https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-client-creds-grant-flow#second-case-access-token-request-with-a-certificate
			$params.addQueryParameter("grant_type"; This.grantType)
			$params.addQueryParameter("client_id"; This.clientId)
			$params.addQueryParameter("scope"; cs._Tools.me.urlEncode(This.scope))
			$params.addQueryParameter("client_assertion_type"; cs._Tools.me.urlEncode(This.clientAssertionType))
			$params.addQueryParameter("client_assertion"; $bearer)
			
		Else 
			
			$params.addQueryParameter("client_id"; This.clientId)
			If (Length(This.scope)>0)
				$params.addQueryParameter("scope"; cs._Tools.me.urlEncode(This.scope))
			End if 
			$params.addQueryParameter("client_secret"; This.clientSecret)
			$params.addQueryParameter("grant_type"; This.grantType)
			
	End case 
	
	$result:=This._sendTokenRequest($params.query)
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function _checkPrerequisites($obj : Object) : Boolean
/**
 * @function _checkPrerequisites
 * @private
 * @param {Object} $obj - Provider parameters to validate
 * @returns {Boolean} `True` when all required fields are present and valid
 * @description Validates mandatory constructor parameters; throws errors 1, 2, or 3
 *   for missing/empty/invalid fields (`clientId`, `scope`, `permission`, `redirectURI`)
 */
	
	var $OK : Boolean:=False
	
	If (($obj#Null) && (Value type($obj)=Is object))
		
		Case of 
				
			: (Length(String($obj.clientId))=0)
				This._throwError(2; {attribute: "clientId"})
				
			: ((Length(String($obj.name))>0) && \
				((Value type($obj.scope)=Is text) && (Length(String($obj.scope))=0)) || \
				((Value type($obj.scope)=Is collection) && ($obj.scope.length=0)))
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
	
	return $OK
	
	
	// ----------------------------------------------------
	
	
Function _sendTokenRequest($params : Text) : Object
/**
 * @function _sendTokenRequest
 * @private
 * @param {Text} $params - URL-encoded request body (`application/x-www-form-urlencoded`)
 * @returns {Object} `OAuth2Token` instance on HTTP 200; `Null` when the response body
 *   is empty or has an unrecognised `Content-Type`
 * @description POSTs to `tokenURI` and parses the response:
 *   - `application/json` or `text/plain` → `_loadFromResponse`
 *   - `application/x-www-form-urlencoded` → `_loadFromURLEncodedResponse`
 *   - Other → raw body stored in `_internals._rawBody`, returns `Null`
 *   Preserves existing `refresh_token` when the response omits it.
 */
	
	var $result : Object:=Null
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
					CONVERT FROM TEXT($response; cs._Tools.me.getHeaderValueParameter($contentType; "charset"; "UTF-8"); $blob)
					This._internals._rawBody:=4D.Blob.new($blob)
					$result:=Null
					
			End case 
			
			// If we already had a refresh token, we need to add it to result object in case it was not present in the response
			If (Value type($result.token.refresh_token)=Is undefined)
				If (OB Is defined(This.token; "refresh_token") && (Length(String(This.token.refresh_token))>0))
					$result.token.refresh_token:=This.token.refresh_token
				End if 
			End if 
			
		Else 
			
			If (cs._Tools.me.webLicenseAvailable)
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
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function _unixTime($inDate : Date; $inTime : Time) : Real
/**
 * @function _unixTime
 * @private
 * @param {Date} $inDate - Optional UTC date (defaults to `Current date` UTC)
 * @param {Time} $inTime - Optional UTC time (defaults to `Current time` UTC)
 * @returns {Real} Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
 * @description Converts a date+time pair to a Unix timestamp for JWT `iat`/`exp` claims.
 *   When called with no parameters, uses the current UTC time from `Timestamp`.
 */
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
	return Num(($days*86400)+($time+0))  // convert in seconds
	
	
	// ----------------------------------------------------
	
	
Function _useJWTBearer() : Boolean
/**
 * @function _useJWTBearer
 * @private
 * @returns {Boolean} `True` when `grantType = "urn:ietf:params:oauth:grant-type:jwt-bearer"`
 *   (Google service account flow)
 */
	
	return (This.grantType="urn:ietf:params:oauth:grant-type:jwt-bearer")
	
	
	// ----------------------------------------------------
	
	
Function _useJWTBearerAssertionType() : Boolean
/**
 * @function _useJWTBearerAssertionType
 * @private
 * @returns {Boolean} `True` when a `thumbprint` is set (certificate-based assertion,
 *   Microsoft Entra)
 */
	
	return (Length(String(This.thumbprint))>0)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getToken() : Object
/**
 * @function getToken
 * @returns {Object} `OAuth2Token` instance with a valid access token, or `Null` on failure
 * @description Returns the current token if still valid; otherwise:
 *   - Refreshes via `_getToken_SignedIn(True)` when a `refresh_token` is available
 *   - Runs the full `signedIn` Authorization Code flow
 *   - Runs the `service` Client Credentials / JWT Bearer flow
 *
 *   Saves the new token and expiration to `This.token` / `This.tokenExpiration`.
 *   Re-throws any caught errors as non-deferred for caller visibility.
 */
	
	This._clearErrorStack()
	
	var $result : Object:=Null
	
	Try
		
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
	Catch
		// Re-throw so errors are visible to callers
		var $caughtErrors : Collection:=Last errors
		If ($caughtErrors.length>0)
			var $firstError : Object:=OB Copy($caughtErrors.first())
			OB REMOVE($firstError; "deferred")  // Force immediate (non-deferred) throw
			throw($firstError)
		End if 
	End try
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function get authenticateURI() : Text
/**
 * @function get authenticateURI
 * @returns {Text} Full authorization URL including all required query parameters
 *   (`client_id`, `response_type`, `scope`, `state`, `redirect_uri`, etc.)
 * @description Builds the authorization URL from the configured `_authenticateURI`
 *   (or defaults for Google/Microsoft). Appends PKCE parameters when `PKCEEnabled`
 *   is `True`; otherwise appends `access_type`, `login_hint`, and `prompt` when set.
 */
	
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
		var $state : Text:=This.state
		var $redirectURI : Text:=This.redirectURI
		var $urlParams : cs._URL:=cs._URL.new()
		
		$urlParams.addQueryParameter("client_id"; This.clientId)
		$urlParams.addQueryParameter("response_type"; "code")
		If (Length(String($scope))>0)
			$urlParams.addQueryParameter("scope"; cs._Tools.me.urlEncode($scope))
		End if 
		$urlParams.addQueryParameter("state"; cs._Tools.me.urlEncode(String($state)))
		$urlParams.addQueryParameter("response_mode"; "query")
		$urlParams.addQueryParameter("redirect_uri"; cs._Tools.me.urlEncode($redirectURI))
		If (This.PKCEEnabled)
			$urlParams.addQueryParameter("code_challenge"; This._generateCodeChallenge(This.codeVerifier))
			$urlParams.addQueryParameter("code_challenge_method"; String(This.PKCEMethod))
		Else 
			If (Length(String(This.accessType))>0)
				$urlParams.addQueryParameter("access_type"; This.accessType)
			End if 
			If (Length(String(This.loginHint))>0)
				$urlParams.addQueryParameter("login_hint"; This.loginHint)
			End if 
			If (Length(String(This.prompt))>0)
				$urlParams.addQueryParameter("prompt"; This.prompt)
			End if 
		End if 
		If (Length(String(This.nonce))>0)
			$urlParams.addQueryParameter("nonce"; cs._Tools.me.urlEncode(This.nonce))
		End if 
		
		$authenticateURI+=$urlParams.getQueryString()
	End if 
	
	return $authenticateURI
	
	
	// ----------------------------------------------------
	
	
Function get codeVerifier() : Text
/**
 * @function get codeVerifier
 * @returns {Text} PKCE code verifier (lazily generated on first access and cached)
 */
	
	If (Length(String(This._codeVerifier))=0)
		This._codeVerifier:=This._generateCodeVerifier()
	End if 
	
	return This._codeVerifier
	
	
	// ----------------------------------------------------
	
	
Function get grantType() : Text
/**
 * @function get grantType
 * @returns {Text} OAuth2 grant type string; defaults to
 *   `"urn:ietf:params:oauth:grant-type:jwt-bearer"` for Google service accounts or
 *   `"client_credentials"` for other service-mode providers
 */
	
	If (Length(String(This._grantType))=0)
		If (This._isService() && This._isGoogle())
			return "urn:ietf:params:oauth:grant-type:jwt-bearer"
		Else 
			return "client_credentials"
		End if 
	End if 
	
	return This._grantType
	
	
	// ----------------------------------------------------
	
	
Function get scope() : Text
/**
 * @function get scope
 * @returns {Text} Space-separated scope string; prepends `offline_access` for Microsoft
 *   when `accessType = "offline"` and it is not already present
 */
	
	var $scope : Text
	
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
/**
 * @function get tokenURI
 * @returns {Text} Token endpoint URL; substitutes `{tenant}` for Microsoft;
 *   defaults to `https://accounts.google.com/o/oauth2/token` for Google and
 *   `https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token` for Microsoft
 */
	
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
/**
 * @function isTokenValid
 * @returns {Boolean} `True` when the current token is valid (not expired);
 *   attempts a refresh when a `refresh_token` is available and the token has expired
 */
	
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
