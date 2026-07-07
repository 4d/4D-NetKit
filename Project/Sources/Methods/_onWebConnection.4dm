//%attributes = {"invisible":true}
/**
 * @method _onWebConnection
 * @description Internal HTTP request dispatcher for the NetKit component.
 *   Handles three categories of incoming requests:
 *   - **OAuth2 redirect** (matching `redirectURI`): resolves the pending authorization
 *     code flow via `_authorize` and sends the configured success/error page
 *   - **Microsoft Graph webhook** (`/4dnk-graph-notification`): responds to subscription
 *     validation challenges or dispatches change notifications to `GraphNotificationHandler`
 *   - **Google push notification** (`/4dnk-google-notification`): dispatches calendar
 *     push or Gmail Pub/Sub notifications to `GoogleNotificationHandler`
 *   - All other URLs return a 404 response
 * @param {Text} $URL - Request URL (same as `$1` in the `On Web Connection` database method)
 * @param {Text} $header - Raw HTTP request headers
 * @param {Text} $peerIP - Client IP address
 * @param {Text} $localIP - Server IP address
 * @param {Text} $username - HTTP Basic Auth username (if any)
 * @param {Text} $password - HTTP Basic Auth password (if any)
 */
#DECLARE($URL : Text; $header : Text; $peerIP : Text; $localIP : Text; $username : Text; $password : Text)

var $redirectURI : Text
var $state : Text:=cs._Tools.me.getURLParameterValue($1; "state")
var $statusLine : Text
var $oauthResult : Object:=Null

// Parse OAuth parameters as early as possible (query or form_post body)
ARRAY TEXT($oauthHeaderNames; 0)
ARRAY TEXT($oauthHeaderValues; 0)
WEB GET VARIABLES($oauthHeaderNames; $oauthHeaderValues)

If (Size of array($oauthHeaderNames)>0)
	var $iOAuth : Integer
	$oauthResult:=New shared object
	Use ($oauthResult)
		For ($iOAuth; 1; Size of array($oauthHeaderNames))
			$oauthResult[$oauthHeaderNames{$iOAuth}]:=$oauthHeaderValues{$iOAuth}
		End for 
	End use 
Else 
	// response_mode=form_post: parameters are in body, not in URL query
	WEB GET HTTP HEADER($oauthHeaderNames; $oauthHeaderValues)
	
	var $oauthHeaderIndex : Integer
	var $oauthContentType : Text:=""
	For ($oauthHeaderIndex; 1; Size of array($oauthHeaderNames))
		If (Lowercase($oauthHeaderNames{$oauthHeaderIndex})="content-type")
			$oauthContentType:=Lowercase($oauthHeaderValues{$oauthHeaderIndex})
		End if 
	End for 
	
	If (Position("application/x-www-form-urlencoded"; $oauthContentType)=1)
		var $oauthRequestBody : Text
		WEB GET HTTP BODY($oauthRequestBody)
		If (Length($oauthRequestBody)>0)
			$oauthResult:=cs._Tools.me.parseFormURLEncoded($oauthRequestBody)
		End if 
	End if 
End if 

If ((Value type($oauthResult)=Is object) && OB Is defined($oauthResult; "state") && (Length(String($oauthResult.state))>0))
	$state:=String($oauthResult.state)
End if 

If ((Storage.requests#Null) && OB Is defined(Storage.requests; $state))
	$redirectURI:=String(Storage.requests[$state].redirectURI)
	If (Length($redirectURI)>0)
		$redirectURI:=cs._Tools.me.getPathFromURL($redirectURI)+"@"
	End if 
End if 

If ($URL=$redirectURI)
	
	var $options : Object:={redirectURI: $redirectURI; state: $state}
	var $hasOAuthParams : Boolean:=((Value type($oauthResult)=Is object) && (OB Keys($oauthResult).length>0))
	If ($hasOAuthParams)
		$options.result:=$oauthResult
		If (OB Is defined($oauthResult; "state") && (Length(String($oauthResult.state))>0))
			$state:=String($oauthResult.state)
			$options.state:=$state
		End if 
	End if 
	
	var $response : Object:={}
	var $responseBody : Text
	
	If (_authorize($options; $response))
		
		// If the response contains a redirect URL, we send a 302 Temporary Redirect
		If ((Value type($response.redirectURL)=Is text) && (Length($response.redirectURL)>0))
			var $responseHeader : Text:="X-STATUS: 302 Found"+Char(13)+Char(10)+"Location: "+String($response.redirectURL)
			WEB SET HTTP HEADER($responseHeader)
		Else 
			
			$responseBody:=$response.body
			var $responseContentType : Text:=$response.contentType
			WEB SEND TEXT($responseBody; $responseContentType)
		End if 
	Else 
		
		// Send a 403 status line
		// This is not strictly necessary, but it makes it clear that the request was forbidden
		// and not just a 404 Not Found
		$responseBody:=cs._Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "403 Forbidden"; "Access denied."; False)
		$statusLine:="X-STATUS: 403 Forbidden"
		WEB SET HTTP HEADER($statusLine)
		WEB SEND TEXT($responseBody; "text/html")
	End if 
	
Else 
	
	// Check if this is a notification webhook request
	Case of 
		: ($URL="/4dnk-graph-notification@")
			
			// --- Microsoft Graph notification ---
			// Validation: Microsoft sends ?validationToken=<token> as a query parameter
			// Notification: Microsoft sends a JSON body with change data
			
			var $validationToken : Text:=cs._Tools.me.getURLParameterValue($1; "validationToken")
			// URL query does not decode '+' as spaces — we must do it manually
			$validationToken:=Replace string($validationToken; "+"; " ")
			
			If (Length($validationToken)>0)
				// Respond with the validation token as plain text
				$statusLine:="X-STATUS: 200 OK"
				WEB SET HTTP HEADER($statusLine)
				WEB SEND TEXT($validationToken; "text/plain")
			Else 
				// Process the notification body
				var $graphBody : Text
				WEB GET HTTP BODY($graphBody)
				If (Length($graphBody)>0)
					cs.GraphNotificationHandler.me._processNotificationBody($graphBody)
				End if 
				
				$statusLine:="X-STATUS: 202 Accepted"
				WEB SET HTTP HEADER($statusLine)
				WEB SEND TEXT(""; "text/plain")
			End if 
			
			
		: ($URL="/4dnk-google-notification@")
			
			// --- Google notification ---
			// Calendar push: Google sends X-Goog-Channel-Token header with state identifier
			// Gmail Pub/Sub push: Google sends JSON body with message.data (base64)
			
			// Extract X-Goog-Channel-Token from headers
			var $channelToken : Text:=""
			var $resourceState : Text:=""
			
			ARRAY TEXT($headerNames; 0)
			ARRAY TEXT($headerValues; 0)
			WEB GET HTTP HEADER($headerNames; $headerValues)
			
			var $hi : Integer
			For ($hi; 1; Size of array($headerNames))
				If ($headerNames{$hi}="X-Goog-Channel-Token")
					$channelToken:=$headerValues{$hi}
				End if 
				If ($headerNames{$hi}="X-Goog-Resource-State")
					$resourceState:=$headerValues{$hi}
				End if 
			End for 
			
			If (Length($channelToken)>0)
				// Calendar push notification
				If ($resourceState#"sync")
					cs.GoogleNotificationHandler.me._processCalendarNotification($channelToken)
				End if 
			Else 
				// Gmail Pub/Sub push notification
				var $googleBody : Text
				WEB GET HTTP BODY($googleBody)
				If (Length($googleBody)>0)
					cs.GoogleNotificationHandler.me._processGmailNotification($googleBody)
				End if 
			End if 
			
			$statusLine:="X-STATUS: 200 OK"
			WEB SET HTTP HEADER($statusLine)
			WEB SEND TEXT("{}"; "application/json")
		Else 
			
			// Send a 404 status line
			$responseBody:=cs._Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "404 Not Found"; "The requested resource could not be found."; False)
			$statusLine:="X-STATUS: 404 Not Found"
			WEB SET HTTP HEADER($statusLine)
			WEB SEND TEXT($responseBody; "text/html")
	End case 
End if 
