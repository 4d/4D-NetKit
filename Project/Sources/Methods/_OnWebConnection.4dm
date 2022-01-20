//%attributes = {"invisible":true}
C_TEXT:C284($1; $2; $3; $4; $5; $6)

var $redirectURI : Text

If (OB Is defined:C1231(Storage:C1525; "params"))
	Use (Storage:C1525.params)
		$redirectURI:=String:C10(Storage:C1525.params.redirectURI)
		If (Length:C16($redirectURI)>0)
			$redirectURI:=_getPathFromURL($redirectURI)+"@"
		End if 
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
		
	Else 
		
		WSTITLE:=Get localized string:C991("OAuth2_Response_Title")
		WSMESSAGE:=Get localized string:C991("OAuth2_Response_Message")
		WSDETAILS:=Get localized string:C991("OAuth2_Response_Details")
		
	End if 
	
	WEB SEND FILE:C619(Get 4D folder:C485(Current resources folder:K5:16)+"Response_Template.html")
	
Else 
	
	// Nothing to do... 404 will be automatically sent
	
End if 
