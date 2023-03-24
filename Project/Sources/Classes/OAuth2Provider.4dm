Class extends _BaseClass

Class constructor($inParams : Object)
	
	Super:C1705()
	
	This:C1470._try()
	
	// Sanity check
	If (This:C1470._checkPrerequisites($inParams))
		
/*
Name of OAuth2 provider. 
*/
		This:C1470.name:=String:C10($inParams.name)
		
/*
"signedIn": Provider will sign the user in and ensure their consent for the permissions your app requests. Need to open a web browser.
"service": Call Provider with their own identity.
*/
		If ((String:C10($inParams.permission)="signedIn") || \
			(String:C10($inParams.permission)="service"))
			This:C1470.permission:=String:C10($inParams.permission)
		End if 
		
/*
The Application ID that the registration portal assigned the app
*/
		This:C1470.clientId:=String:C10($inParams.clientId)
		
/*
The redirect_uri of your app, where authentication responses can be sent and received by your app.
*/
		This:C1470.redirectURI:=String:C10($inParams.redirectURI)
		
/*
A space-separated list of the permissions that you want the user to consent to.
*/
		If (Value type:C1509($inParams.scope)=Is collection:K8:32)
			This:C1470._scope:=$inParams.scope.join(" ")
			
		Else 
			This:C1470._scope:=String:C10($inParams.scope)
			
		End if 
		
/*
The {tenant} value in the path of the request can be used to control who can sign into the application. 
The allowed values are "common" for both Microsoft accounts and work or school accounts, "organizations" 
for work or school accounts only, "consumers" for Microsoft accounts only, and tenant identifiers such as 
the tenant ID or domain name. By default "common"
*/
		This:C1470.tenant:=Choose:C955(Value type:C1509($inParams.tenant)=Is undefined:K8:13; "common"; String:C10($inParams.tenant))
		
/*
Uri used to do the Authorization request.
*/
		This:C1470._authenticateURI:=String:C10($inParams.authenticateURI)
		
/*
Uri used to request an access token.
*/
		This:C1470._tokenURI:=String:C10($inParams.tokenURI)
		
/*
The application secret that you created in the app registration portal for your app. Required for web apps.
*/
		This:C1470.clientSecret:=String:C10($inParams.clientSecret)
		
/*
Any valid existing token
*/
		This:C1470.token:=Choose:C955(Value type:C1509($inParams.token)=Is object:K8:27; $inParams.token; Null:C1517)
		
/*
*/
		This:C1470.tokenExpiration:=Choose:C955(Value type:C1509($inParams.tokenExpiration)=Is text:K8:3; $inParams.tokenExpiration; Null:C1517)
		
/*
*/
		This:C1470.timeout:=Choose:C955(Value type:C1509($inParams.timeout)=Is undefined:K8:13; 120; Num:C11($inParams.timeout))
		
/*
Path of the web page to display in the webbrowser when the authentication code 
is received correctly in signed in mode
If not present the default page is used
*/
		This:C1470.authenticationPage:=_retainFileObject($inParams.authenticationPage)
		
/*
Path of the web page to display in the webbrowser when the authentication server 
returns an error in signed in mode
If not present the default page is used
*/
		This:C1470.authenticationErrorPage:=_retainFileObject($inParams.authenticationErrorPage)
		
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
		If ((String:C10($inParams.accessType)="online") || \
			(String:C10($inParams.accessType)="offline"))
			This:C1470.accessType:=String:C10($inParams.accessType)
		End if 
		
/*
If your application knows which user is trying to authenticate, 
it can use this parameter to provide a hint to the Google Authentication Server. 
The server uses the hint to simplify the login flow either by prefilling the email 
field in the sign-in form or by selecting the appropriate multi-login session.
		
Set the parameter value to an email address or sub identifier, which is equivalent 
to the user's Google ID.
*/
		This:C1470.loginHint:=String:C10($inParams.loginHint)
		
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
		If ((String:C10($inParams.prompt)="none") || \
			(String:C10($inParams.prompt)="consent") || \
			(String:C10($inParams.prompt)="select_account"))
			This:C1470.prompt:=String:C10($inParams.prompt)
		End if 
		
/*
Email address of the Google service account used (Google only)
*/
		If (This:C1470._isGoogle())
			This:C1470.clientEmail:=String:C10($inParams.clientEmail)
		End if 
		
/*
Enable HTTP Server debug log for Debug purposes only
*/
		If (Bool:C1537($inParams.enableDebugLog))
			This:C1470.enableDebugLog:=True:C214
		End if 
	End if 
	
	This:C1470._finally()
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _isMicrosoft() : Boolean
	
	return (This:C1470.name="Microsoft")
	
	
	// ----------------------------------------------------
	
	
Function _isGoogle() : Boolean
	
	return (This:C1470.name="Google")
	
	
	// ----------------------------------------------------
	
	
Function _OpenBrowserForAuthorisation()->$authorizationCode : Text
	
	var $url; $redirectURI; $state; $scope : Text
	
	$state:=Generate UUID:C1066
	$redirectURI:=This:C1470.redirectURI
	$url:=This:C1470.authenticateURI
	$scope:=This:C1470.scope
	
	// Sanity check
	Case of 
			
		: (Length:C16(String:C10(This:C1470.clientId))=0)
			This:C1470._throwError(2; New object:C1471("attribute"; "clientId"))
			
		: (Length:C16(String:C10($url))=0)
			This:C1470._throwError(2; New object:C1471("attribute"; "authenticateURI"))
			
		: ((This:C1470._isGoogle() || This:C1470._isMicrosoft()) && (Length:C16(String:C10($scope))=0))
			This:C1470._throwError(2; New object:C1471("attribute"; "scope"))
			
		: (Length:C16(String:C10(This:C1470.tenant))=0)
			This:C1470._throwError(2; New object:C1471("attribute"; "tenant"))
			
		: ((String:C10(This:C1470.permission)="signedIn") & (Length:C16(String:C10($redirectURI))=0))
			This:C1470._throwError(2; New object:C1471("attribute"; "redirectURI"))
			
		Else 
			
			$url+="?client_id="+This:C1470.clientId
			$url+="&response_type=code"
			$url+="&redirect_uri="+_urlEscape($redirectURI)
			$url+="&response_mode=query"
			If (Length:C16(String:C10($scope))>0)
				$url+="&scope="+_urlEscape($scope)
			End if 
			$url+="&state="+String:C10($state)
			If (Length:C16(String:C10(This:C1470.accessType))>0)
				$url+="&access_type="+This:C1470.accessType
			End if 
			If (Length:C16(String:C10(This:C1470.loginHint))>0)
				$url+="&login_hint="+This:C1470.loginHint
			End if 
			If (Length:C16(String:C10(This:C1470.prompt))>0)
				$url+="&prompt="+This:C1470.prompt
			End if 
			
			Use (Storage:C1525)
				OB REMOVE:C1226(Storage:C1525; "token")
				Storage:C1525.params:=New shared object:C1526("redirectURI"; $redirectURI; \
					"authenticationPage"; (Value type:C1509(This:C1470.authenticationPage)#Is undefined:K8:13) ? This:C1470.authenticationPage : Null:C1517; \
					"authenticationErrorPage"; (Value type:C1509(This:C1470.authenticationErrorPage)#Is undefined:K8:13) ? This:C1470.authenticationErrorPage : Null:C1517)
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
	
	
Function _getToken_SignedIn($bUseRefreshToken : Boolean)->$result : Object
	
	var $params : Text
	var $bSendRequest : Boolean
	
	$bSendRequest:=True:C214
	If ($bUseRefreshToken)
		
		$params:="client_id="+This:C1470.clientId
		If (Length:C16(This:C1470.scope)>0)
			$params+="&scope="+_urlEscape(This:C1470.scope)
		End if 
		$params+="&refresh_token="+This:C1470.token.refresh_token
		$params+="&grant_type=refresh_token"
		If (Length:C16(This:C1470.clientSecret)>0)
			$params+="&client_secret="+This:C1470.clientSecret
		End if 
		
	Else 
		
		If ((Position:C15("localhost"; This:C1470.redirectURI)>0) | (Position:C15("127.0.0.1"; This:C1470.redirectURI)>0))
			
			var $options : Object
			$options:=New object:C1471
			$options.port:=_getPortFromURL(This:C1470.redirectURI)
			$options.enableDebugLog:=This:C1470.enableDebugLog
			If ((This:C1470.authenticationPage#Null:C1517) || (This:C1470.authenticationErrorPage#Null:C1517))
				var $file : Object
				$file:=(This:C1470.authenticationPage#Null:C1517) ? This:C1470.authenticationPage : This:C1470.authenticationErrorPage
				If (OB Instance of:C1731($file; 4D:C1709.File))
					$options.webFolder:=$file.parent
				End if 
			End if 
			
			If (_StartWebServer($options))
				
				var $authorizationCode : Text
				$authorizationCode:=This:C1470._OpenBrowserForAuthorisation()
				
				If (Length:C16($authorizationCode)>0)
					
					$params:="client_id="+This:C1470.clientId
					$params+="&scope="+_urlEscape(This:C1470.scope)
					$params+="&code="+$authorizationCode
					$params+="&redirect_uri="+_urlEscape(This:C1470.redirectURI)
					$params+="&grant_type=authorization_code"
					If (Length:C16(This:C1470.clientSecret)>0)
						$params+="&client_secret="+This:C1470.clientSecret
					End if 
					
				Else 
					
					$bSendRequest:=False:C215
					This:C1470._throwError(6)
					
				End if 
				
			Else 
				
				$bSendRequest:=False:C215
				This:C1470._throwError(7; New object:C1471("port"; $options.port))
				
			End if 
		End if 
		
	End if 
	
	If ($bSendRequest)
		
		$result:=This:C1470._sendTokenRequest($params)
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _getToken_Service()->$result : Object
	
	Case of 
		: (This:C1470._isGoogle())
/*
TODO: send a JWT such as:
			
{"alg":"RS256","typ":"JWT"}.
{
"iss":"761326798069-r5mljlln1rd4lrbhg75efgigp36m78j5@developer.gserviceaccount.com",
"scope":"https://www.googleapis.com/auth/prediction",
"aud":"https://oauth2.googleapis.com/token",
"exp":1328554385,
"iat":1328550785
}.
[signature bytes]
*/
			
		Else 
			var $params : Text
			
			$params:="client_id="+This:C1470.clientId
			If (Length:C16(This:C1470.scope)>0)
				$params+="&scope="+_urlEscape(This:C1470.scope)
			End if 
			$params+="&client_secret="+This:C1470.clientSecret
			$params+="&grant_type=client_credentials"
			$result:=This:C1470._sendTokenRequest($params)
			
	End case 
	
	
	// ----------------------------------------------------
	
	
Function _checkPrerequisites($obj : Object)->$OK : Boolean
	
	$OK:=False:C215
	
	If (($obj#Null:C1517) & (Value type:C1509($obj)=Is object:K8:27))
		
		Case of 
				
			: (Length:C16(String:C10($obj.clientId))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "clientId"))
				
			: ((Length:C16(String:C10($obj.name))>0) && (Length:C16(String:C10($obj.scope))=0))
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
	
	
Function _sendTokenRequest($params : Text)->$result : Object
	
	var $response; $savedMethod : Text
	var $status : Integer
	
	var $options : Object
	var $request : 4D:C1709.HTTPRequest
	
	$options:=New object:C1471
	$options.headers:=New object:C1471("Content-Type"; "application/x-www-form-urlencoded"; \
		"Accept"; "application/json")
	$options.method:=HTTP POST method:K71:2
	$options.body:=$params
	$options.dataType:="text"
	
	$savedMethod:=Method called on error:C704
	ON ERR CALL:C155("_ErrorHandler")
	$request:=4D:C1709.HTTPRequest.new(This:C1470.tokenURI; $options)
	$request.wait(30)
	ON ERR CALL:C155($savedMethod)
	$status:=$request["response"]["status"]
	$response:=$request["response"]["body"]
	
	If ($status=200)
		
		If (Length:C16($response)>0)
			
			var $contentType : Text
			$contentType:=String:C10($request["response"]["headers"]["content-type"])
			
			Case of 
				: (($contentType="application/json@") || ($contentType="text/plain@"))
					$result:=cs:C1710.OAuth2Token.new()
					$result._loadFromResponse($response)
					
				: ($contentType="application/x-www-form-urlencoded@")
					$result:=cs:C1710.OAuth2Token.new()
					$result._loadFromURLEncodedResponse($response)
					
				Else 
					var $blob : Blob
					CONVERT FROM TEXT:C1011($response; _getHeaderValueParameter($contentType; "charset"; "UTF-8"); $blob)
					$result:=4D:C1709.Blob.new($blob)
					
			End case 
			
		Else 
			
			var $licenseAvailable : Boolean
			If (Application type:C494=4D Remote mode:K5:5)
				$licenseAvailable:=Is license available:C714(4D Client Web license:K44:6)
			Else 
				$licenseAvailable:=(Is license available:C714(4D Web license:K44:3) | Is license available:C714(4D Web local license:K44:14) | Is license available:C714(4D Web one connection license:K44:15))
			End if 
			If ($licenseAvailable)
				This:C1470._throwError(4)  // Timeout error
			Else 
				This:C1470._throwError(11)  // License error
			End if 
			
		End if 
		
	Else 
		
		var $explanation : Text
		$explanation:=$request["response"]["statusText"]
		
		var $error : Object
		
		$error:=JSON Parse:C1218($response)
		If ($error#Null:C1517)
			var $errorCode : Integer
			var $message : Text
			
			If (Num:C11($error.error_codes.length)>0)
				$errorCode:=Num:C11($error.error_codes[0])
			End if 
			$message:=String:C10($error.error_description)
			
			This:C1470._throwError(8; New object:C1471("status"; $status; "explanation"; $explanation; "message"; $message))
		Else 
			
			This:C1470._throwError(5; New object:C1471("received"; $status; "expected"; 200))
		End if 
		
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getToken()->$result : Object
	
	This:C1470._try()
	
	var $bUseRefreshToken : Boolean
	
	$bUseRefreshToken:=False:C215
	If (This:C1470.token#Null:C1517)
		var $token : cs:C1710.OAuth2Token
		$token:=cs:C1710.OAuth2Token.new(This:C1470)
		If (Not:C34($token._Expired()))
			// Token is still valid.. Simply return it
			$result:=$token
		Else 
			$bUseRefreshToken:=(Length:C16(String:C10(This:C1470.token.refresh_token))>0)
		End if 
	End if 
	
	If ($result=Null:C1517)
		
		var $redirectURI; $authenticateURI; $tokenURI : Text
		
		$redirectURI:=This:C1470.redirectURI
		$authenticateURI:=This:C1470.authenticateURI
		$tokenURI:=This:C1470.tokenURI
		
		// Sanity check
		Case of 
				
			: (Length:C16(String:C10(This:C1470.clientId))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "clientId"))
				
			: (Length:C16(String:C10($authenticateURI))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "authenticateURI"))
				
			: ((This:C1470._isGoogle() || This:C1470._isMicrosoft()) && (Length:C16(String:C10(This:C1470.scope))=0))
				This:C1470._throwError(2; New object:C1471("attribute"; "scope"))
				
			: (Length:C16(String:C10($tokenURI))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "tokenURI"))
				
			: (Length:C16(String:C10(This:C1470.tenant))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "tenant"))
				
			: (Length:C16(String:C10(This:C1470.permission))=0)
				This:C1470._throwError(2; New object:C1471("attribute"; "permission"))
				
			: ((String:C10(This:C1470.permission)="signedIn") & (Length:C16(String:C10($redirectURI))=0))
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
	
	This:C1470._finally()
	
	
	// ----------------------------------------------------
	
	
Function get authenticateURI() : Text
	
	var $authenticateURI : Text
	Case of 
		: (This:C1470._isMicrosoft())
			$authenticateURI:=Choose:C955((Length:C16(String:C10(This:C1470._authenticateURI))>0); This:C1470._authenticateURI; "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize")
			$authenticateURI:=Replace string:C233($authenticateURI; "{tenant}"; Choose:C955((Length:C16(String:C10(This:C1470.tenant))>0); This:C1470.tenant; "common"))
			
		: (This:C1470._isGoogle())
			$authenticateURI:=Choose:C955((Length:C16(String:C10(This:C1470._authenticateURI))>0); This:C1470._authenticateURI; "https://accounts.google.com/o/oauth2/auth")
			
		Else 
			$authenticateURI:=This:C1470._authenticateURI
			
	End case 
	
	return $authenticateURI
	
	
	// ----------------------------------------------------
	
	
Function get scope()->$scope : Text
	
	Case of 
		: (This:C1470._isMicrosoft())
			$scope:=This:C1470._scope
			If ((This:C1470.accessType="offline") && (Position:C15("offline_access"; $scope)=0))
				$scope:="offline_access "+$scope
			End if 
			
		Else 
			$scope:=This:C1470._scope
			
	End case 
	
	return $scope
	
	
	// ----------------------------------------------------
	
	
Function get tokenURI() : Text
	
	var $tokenURI : Text
	Case of 
		: (This:C1470._isMicrosoft())
			$tokenURI:=Choose:C955((Length:C16(String:C10(This:C1470._tokenURI))>0); This:C1470._tokenURI; "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token")
			$tokenURI:=Replace string:C233($tokenURI; "{tenant}"; Choose:C955((Length:C16(String:C10(This:C1470.tenant))>0); This:C1470.tenant; "common"))
			
		: (This:C1470._isGoogle())
			$tokenURI:=Choose:C955((Length:C16(String:C10(This:C1470._tokenURI))>0); This:C1470._tokenURI; "https://accounts.google.com/o/oauth2/token")
			
		Else 
			$tokenURI:=This:C1470._tokenURI
			
	End case 
	
	return $tokenURI
	