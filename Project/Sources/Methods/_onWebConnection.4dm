//%attributes = {"invisible":true}
#DECLARE($URL : Text; $header : Text; $peerIP : Text; $localIP : Text; $username : Text; $password : Text)

var $redirectURI : Text
var $state : Text:=cs._Tools.me.getURLParameterValue($1; "state")

If (OB Is defined(Storage.requests; $state))
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
	var $statusLine : Text
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
	If ($URL="/$4dk-notification@")
		
		// Handle notification webhook (validation or notification delivery)
		ARRAY TEXT($wvNames; 0)
		ARRAY TEXT($wvValues; 0)
		WEB GET VARIABLES($wvNames; $wvValues)
		
		// Check for validation token (subscription validation request)
		var $validationToken : Text:=""
		var $vi : Integer
		For ($vi; 1; Size of array($wvNames))
			If ($wvNames{$vi}="validationToken")
				$validationToken:=$wvValues{$vi}
			End if 
		End for 
		
		If (Length($validationToken)>0)
			// Respond with the validation token as plain text
			$statusLine:="X-STATUS: 200 OK"
			WEB SET HTTP HEADER($statusLine)
			WEB SEND TEXT($validationToken; "text/plain")
		Else 
			// Process the notification body
			var $notifBody : Text
			WEB GET HTTP BODY($notifBody)
			If (Length($notifBody)>0)
				var $notifJson : Object:=Try(JSON Parse($notifBody))
				If ($notifJson#Null)
					cs._GraphNotificationHandler.me._processNotificationBody($notifJson)
				End if 
			End if 
			
			$statusLine:="X-STATUS: 202 Accepted"
			WEB SET HTTP HEADER($statusLine)
			WEB SEND TEXT(""; "text/plain")
		End if 
		
	Else 
		
		// Send a 404 status line
		$responseBody:=cs._Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "404 Not Found"; "The requested resource could not be found."; False)
		$statusLine:="X-STATUS: 404 Not Found"
		WEB SET HTTP HEADER($statusLine)
		WEB SEND TEXT($responseBody; "text/html")
	End if 
End if 
