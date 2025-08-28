//%attributes = {"invisible":true}
#DECLARE($URL : Text; $header : Text; $peerIP : Text; $localIP : Text; $username : Text; $password : Text)

var $redirectURI : Text
var $state : Text:=cs.Tools.me.getURLParameterValue($1; "state")

If (OB Is defined(Storage.requests; $state))
	$redirectURI:=String(Storage.requests[$state].redirectURI)
	If (Length($redirectURI)>0)
		$redirectURI:=cs.Tools.me.getPathFromURL($redirectURI)+"@"
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
		$responseBody:=cs.Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "403 Forbidden"; "Access denied."; False)
		$statusLine:="X-STATUS: 403 Forbidden"
		WEB SET HTTP HEADER($statusLine)
		WEB SEND TEXT($responseBody; "text/html")
	End if 
	
Else 
	
	// Send a 404 status line
	$responseBody:=cs.Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "404 Not Found"; "The requested resource could not be found."; False)
	$statusLine:="X-STATUS: 404 Not Found"
	WEB SET HTTP HEADER($statusLine)
	WEB SEND TEXT($responseBody; "text/html")
End if 
