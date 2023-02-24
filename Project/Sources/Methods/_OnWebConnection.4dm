//%attributes = {"invisible":true}
C_TEXT:C284($1; $2; $3; $4; $5; $6)

var $redirectURI : Text
var $responseFile; $customResponseFile; $customErrorFile : 4D:C1709.File

$responseFile:=Folder:C1567(fk resources folder:K87:11).file("Response_Template.html")

If (OB Is defined:C1231(Storage:C1525; "params"))
	Use (Storage:C1525.params)
		$redirectURI:=String:C10(Storage:C1525.params.redirectURI)
		If (Length:C16($redirectURI)>0)
			$redirectURI:=_getPathFromURL($redirectURI)+"@"
		End if 
		$customResponseFile:=(Value type:C1509(Storage:C1525.params.authenticationPage)#Is undefined:K8:13) ? Storage:C1525.params.authenticationPage : Null:C1517
		$customErrorFile:=(Value type:C1509(Storage:C1525.params.authenticationErrorPage)#Is undefined:K8:13) ? Storage:C1525.params.authenticationErrorPage : Null:C1517
	End use 
End if 

If ($1=$redirectURI)
	
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
	
	Use (Storage:C1525)
		Storage:C1525.token:=$result
	End use 
	
	If (($result=Null:C1517) | (OB Is defined:C1231($result; "error")))
		
		WSTITLE:=Get localized string:C991("OAuth2_Response_Title")
		WSMESSAGE:=Get localized string:C991("OAuth2_Error_Message")
		If (OB Is defined:C1231($result; "error_description"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_description
		End if 
		If (OB Is defined:C1231($result; "error_uri"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_uri
		End if 
		WSDETAILS:=Get localized string:C991("OAuth2_Response_Details")
		
		$responseFile:=($customErrorFile#Null:C1517) ? $customErrorFile : $responseFile
	Else 
		
		WSTITLE:=Get localized string:C991("OAuth2_Response_Title")
		WSMESSAGE:=Get localized string:C991("OAuth2_Response_Message")
		WSDETAILS:=Get localized string:C991("OAuth2_Response_Details")
		
		$responseFile:=($customResponseFile#Null:C1517) ? $customResponseFile : $responseFile
	End if 
	
	WEB SEND FILE:C619($responseFile.platformPath)
	
Else 
	
	// Nothing to do... 404 will be automatically sent
	
End if 
