/* 
This class is the base provider for an OAuth2 workflow.
Depending on the resources we try to access, the requested and optional fields can slighty differ.

This base parameter class define what the OAuth 2 spec define as mandatory or optional. https://oauth.net/2/

Any provider should extend this class with its own extended attributes.

A "name" attribute is added that must be used to determine which provider is used.

This class or an extended one must be used when creating a new OAuth2 instance
*/

Class constructor
/*
Only currently supported value : "Microsoft", "Oauth2"
Default = "Oauth2", no prefered provider but, a non implemented provider will throw an error
mandatory
*/
	This:C1470.name:="OAuth2"
	
/*
"signedIn": authorization_code flow
"service": client_credentials flow
mandatory
*/
	This:C1470.permission:="signedIn"
	
/*
The Application ID that the registration portal assigned the app
mandatory
*/
	This:C1470.clientId:=""
	
/*
The redirect_uri of your app, where authentication responses can be sent and received by your app.
mandatory if permission="signedIn"
*/
	This:C1470.redirectURI:=""
	
/*
The application secret that you created in the app registration portal for your app. Required for web apps.
optional
*/
	This:C1470.clientSecret:=""
	
/*
A space-separated list of scopes that you want the user to consent to.
collection: collection of scope
optional
*/
	This:C1470.scope:=""
	
/*
optional
*/
	This:C1470.state:=""
	
/*
Uri used to do the Authorization request.
mandatory
*/
	This:C1470.authenticateURI:=""
	
/*
Uri used to request an access token.
mandatory
*/
	This:C1470.tokenURI:=""
	
	This:C1470.token:=Null:C1517  // optional
	This:C1470.tokenExpiration:=String:C10(!00-00-00!; ISO date GMT:K1:10; ?00:00:00?)  // optional
	This:C1470.timeout:=120  // optional. 120 seconds by default
	
/*
This function is a callback that will be called in the OAuth2Provider class to verify that the data are correct
	
This function can be overrided in the children class if needed
*/
Function checkPrerequisites()->$OK : Boolean
	
	$OK:=False:C215
	
	Case of 
		: (This:C1470.name="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_provider"))
			
		: (This:C1470.clientId="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_clientId"))
			
		: (This:C1470.redirectURI="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_redirectURI"))
			
		: (This:C1470.authenticateURI="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_authenticateURI"))
			
		: (This:C1470.tokenURI="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_tokenURI"))
			
		: (This:C1470.permission="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_permission"))
			
		: (This:C1470.permission#"signedIn") & (This:C1470.permission#"service")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Unsupported_permission"))
			
		: (This:C1470.permission="signedIn") & (This:C1470.redirectURI="")
			ASSERT:C1129(False:C215; Get localized string:C991("OAuth2_Undefined_redirectURI"))
			
		Else 
			$OK:=True:C214
			
	End case 
	
	
/*
Callback to execute on the authenticateURI before the authorization request
*/
Function authenticateURIExtender($uri : Text)->$uriExtended : Text
	$uriExtended:=$uri