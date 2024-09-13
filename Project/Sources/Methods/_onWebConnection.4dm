//%attributes = {"invisible":true}
#DECLARE($URL : Text; $header : Text; $peerIP : Text; $localIP : Text; $username : Text; $password : Text)

var $redirectURI : Text
var $customResponseFile; $customErrorFile : 4D:C1709.File
var $state : Text:=cs:C1710.Tools.me.getURLParameterValue($1; "state")
var $responseFile : 4D:C1709.File:=Folder:C1567(fk resources folder:K87:11).file("Response_Template.html")

If (OB Is defined:C1231(Storage:C1525.requests; $state))
	$redirectURI:=String:C10(Storage:C1525.requests[$state].redirectURI)
	If (Length:C16($redirectURI)>0)
		$redirectURI:=cs:C1710.Tools.me.getPathFromURL($redirectURI)+"@"
	End if 
	$customResponseFile:=(Value type:C1509(Storage:C1525.requests[$state].authenticationPage)#Is undefined:K8:13) ? Storage:C1525.requests[$state].authenticationPage : Null:C1517
	$customErrorFile:=(Value type:C1509(Storage:C1525.requests[$state].authenticationErrorPage)#Is undefined:K8:13) ? Storage:C1525.requests[$state].authenticationErrorPage : Null:C1517
End if 

If ($URL=$redirectURI)
	
	var $result : Object
	var WSTITLE; WSMESSAGE; WSDETAILS : Text
	
	ARRAY TEXT:C222($names; 0)
	ARRAY TEXT:C222($values; 0)
	WEB GET VARIABLES:C683($names; $values)
	
	If (Size of array:C274($names)>0)
		
		var $i : Integer
		$result:=New shared object:C1526
		Use ($result)
			For ($i; 1; Size of array:C274($names))
				$result[$names{$i}]:=$values{$i}
			End for 
		End use 
		
	End if 
	
	If (OB Is defined:C1231(Storage:C1525.requests; $state))
		Use (Storage:C1525.requests[$state])
			Storage:C1525.requests[$state].token:=$result
		End use 
	End if 
	
	If (($result=Null:C1517) | (OB Is defined:C1231($result; "error")))
		
		WSTITLE:=Localized string:C991("OAuth2_Response_Title")
		WSMESSAGE:=Localized string:C991("OAuth2_Error_Message")
		
		If (OB Is defined:C1231($result; "error"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error
		End if 
		If (OB Is defined:C1231($result; "error_subtype"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_subtype
		End if 
		If (OB Is defined:C1231($result; "error_description"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_description
		End if 
		If (OB Is defined:C1231($result; "error_uri"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_uri
		End if 
		WSDETAILS:=Localized string:C991("OAuth2_Response_Details")
		
		$responseFile:=($customErrorFile#Null:C1517) ? $customErrorFile : $responseFile
	Else 
		
		WSTITLE:=Localized string:C991("OAuth2_Response_Title")
		WSMESSAGE:=Localized string:C991("OAuth2_Response_Message")
		WSDETAILS:=Localized string:C991("OAuth2_Response_Details")
		
		$responseFile:=($customResponseFile#Null:C1517) ? $customResponseFile : $responseFile
	End if 
	
	WEB SEND FILE:C619($responseFile.platformPath)
	
Else 
	
	// Nothing to do... 404 will be automatically sent
	
End if 
