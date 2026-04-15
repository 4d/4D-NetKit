//%attributes = {"invisible":true}
#DECLARE($URL : Text; $header : Text; $peerIP : Text; $localIP : Text; $username : Text; $password : Text)

var $redirectURI : Text
var $state : Text:=cs._Tools.me.getURLParameterValue($1; "state")
var $statusLine : Text

If ((Storage.requests#Null) && OB Is defined(Storage.requests; $state))
	$redirectURI:=String(Storage.requests[$state].redirectURI)
	If (Length($redirectURI)>0)
		$redirectURI:=cs._Tools.me.getPathFromURL($redirectURI)+"@"
	End if 
End if 

If ($URL=$redirectURI)
	
	var $options : Object:={redirectURI: $redirectURI; state: $state}
	
	ARRAY TEXT($names; 0)
	ARRAY TEXT($values; 0)
	WEB GET VARIABLES($names; $values)
	
	If (Size of array($names)>0)
		
		var $i : Integer
		var $result : Object:=New shared object
		Use ($result)
			For ($i; 1; Size of array($names))
				$result[$names{$i}]:=$values{$i}
			End for 
		End use 
		$options.result:=$result
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
			var $contentType : Text:=$response.contentType
			WEB SEND TEXT($responseBody; $contentType)
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
		: ($URL="/$4dnk-graph-notification@")
			
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
			
			
		: ($URL="/$4dnk-google-notification@")
			
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
			WEB SEND TEXT(""; "text/plain")
			
		Else 
			
			// Send a 404 status line
			$responseBody:=cs._Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "404 Not Found"; "The requested resource could not be found."; False)
			$statusLine:="X-STATUS: 404 Not Found"
			WEB SET HTTP HEADER($statusLine)
			WEB SEND TEXT($responseBody; "text/html")
	End case 
End if 
