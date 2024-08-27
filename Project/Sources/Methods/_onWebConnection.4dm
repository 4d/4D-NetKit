//%attributes = {"invisible":true}
#DECLARE($URL : Text; $header : Text; $peerIP : Text; $localIP : Text; $username : Text; $password : Text)

var $redirectURI : Text
var $customResponseFile; $customErrorFile : 4D.File
var $state : Text:=cs.Tools.me.getURLParameterValue($1; "state")
var $responseFile : 4D.File:=Folder(fk resources folder).file("Response_Template.html")

If (OB Is defined(Storage.requests; $state))
	$redirectURI:=String(Storage.requests[$state].redirectURI)
	If (Length($redirectURI)>0)
		$redirectURI:=cs.Tools.me.getPathFromURL($redirectURI)+"@"
	End if 
	$customResponseFile:=(Value type(Storage.requests[$state].authenticationPage)#Is undefined) ? Storage.requests[$state].authenticationPage : Null
	$customErrorFile:=(Value type(Storage.requests[$state].authenticationErrorPage)#Is undefined) ? Storage.requests[$state].authenticationErrorPage : Null
End if 

If ($URL=$redirectURI)
	
	var $result : Object
	var WSTITLE; WSMESSAGE; WSDETAILS : Text
	
	ARRAY TEXT($names; 0)
	ARRAY TEXT($values; 0)
	WEB GET VARIABLES($names; $values)
	
	If (Size of array($names)>0)
		
		var $i : Integer
		$result:=New shared object
		Use ($result)
			For ($i; 1; Size of array($names))
				$result[$names{$i}]:=$values{$i}
			End for 
		End use 
		
	End if 
	
	If (OB Is defined(Storage.requests; $state))
		Use (Storage.requests[$state])
			Storage.requests[$state].token:=$result
		End use 
	End if 
	
	If (($result=Null) | (OB Is defined($result; "error")))
		
		WSTITLE:=Get localized string("OAuth2_Response_Title")
		WSMESSAGE:=Get localized string("OAuth2_Error_Message")
		
		If (OB Is defined($result; "error"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error
		End if 
		If (OB Is defined($result; "error_subtype"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_subtype
		End if 
		If (OB Is defined($result; "error_description"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_description
		End if 
		If (OB Is defined($result; "error_uri"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_uri
		End if 
		WSDETAILS:=Get localized string("OAuth2_Response_Details")
		
		$responseFile:=($customErrorFile#Null) ? $customErrorFile : $responseFile
	Else 
		
		WSTITLE:=Get localized string("OAuth2_Response_Title")
		WSMESSAGE:=Get localized string("OAuth2_Response_Message")
		WSDETAILS:=Get localized string("OAuth2_Response_Details")
		
		$responseFile:=($customResponseFile#Null) ? $customResponseFile : $responseFile
	End if 
	
	WEB SEND FILE($responseFile.platformPath)
	
Else 
	
	// Nothing to do... 404 will be automatically sent
	
End if 
