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
	
	var $responseBody : Text:=""
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
	
	If (_authorize($options; $responseBody))
		
		WEB SEND TEXT($responseBody; "text/html")
	End if 
	
End if 

// Nothing to do... 404 will be automatically sent
