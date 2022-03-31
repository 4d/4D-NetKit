Class extends OAuth2BaseProvider

// See: https://docs.microsoft.com/en-us/graph/auth-v2-service
Class constructor
	Super:C1705()
	
/*
The {tenant} value in the path of the request can be used to control who can sign into the application. 
The allowed values are "common" for both Microsoft accounts and work or school accounts, "organizations" 
for work or school accounts only, "consumers" for Microsoft accounts only, and tenant identifiers such as 
the tenant ID or domain name. By default "common"
*/
	This:C1470.tenant:="common"  // mandatory.
	
	// Default values for Microsoft provider
	This:C1470.name:="Microsoft"
	This:C1470.authenticateURI:="https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize"
	This:C1470.tokenURI:="https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token"
	This:C1470.redirectURI:="https://login.microsoftonline.com/common/oauth2/nativeclient"
	
/*
This function is a callback that will be called in the OAuth2Provider class to verify that the data are correct
*/
Function checkPrerequisites()->$OK : Boolean
	
	$OK:=False:C215
	
	Case of 
		: (This:C1470.name="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_provider"))
			
		: (This:C1470.clientId="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_clientId"))
			
		: (This:C1470.authenticateURI="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_authenticateURI"))
			
		: (This:C1470.tokenURI="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_tokenURI"))
			
		: (This:C1470.scope="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_scope"))
			
		: (This:C1470.permission="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_permission"))
			
		: (This:C1470.permission#"signedIn") & (This:C1470.permission#"service")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Unsupported_permission"))
			
		: (This:C1470.permission="signedIn") & (This:C1470.redirectURI="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_redirectURI"))
			
		: (This:C1470.tenant="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_tenant"))
			
		Else 
			$OK:=True:C214
			
	End case 
	
	
/*
Callback to execute on the authenticateURI before the authorization request
	
Replace the tenant in the url
*/
Function authenticateURIExtender($uri : Text)->$uriExtended : Text
	If (This:C1470.tenant#Null:C1517)
		$uriExtended:=Replace string:C233($uri; "{tenant}"; This:C1470.tenant)  // Microsoft specific
	End if 
	