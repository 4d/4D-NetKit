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
	
	var $responseBody : Blob
	If (_authorize($options; ->$responseBody))
		
		var $contentType : Text:="Content-Type: text/html"
		WEB SET HTTP HEADER($contentType)
		WEB SEND RAW DATA($responseBody)
	Else 
		
		// Send a 403 status line
		// This is not strictly necessary, but it makes it clear that the request was forbidden
		// and not just a 404 Not Found
		var $statusLine : Text:="X-STATUS: 403 Forbidden"
		WEB SET HTTP HEADER($statusLine)
		var $errorBody : Text:="<html><body><h1>403 Forbidden</h1><p>Access denied</p></body></html>"
		WEB SEND TEXT($errorBody; "text/html")
	End if 
	
End if 

// Nothing to do... 404 will be automatically sent
