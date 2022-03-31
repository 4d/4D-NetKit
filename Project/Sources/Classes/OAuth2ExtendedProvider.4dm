/*
This extended OAuth2 provider class allow to have custom parameters in the authorization call query string
*/
Class extends OAuth2BaseProvider
Class constructor
	Super:C1705()
/*
Optional params for specific implementation.
Only used during the authorization call.
Those params will be added to the querystring at the end of the authenticateURI.
Must be a <key:Text>/<value:Text> object where keys and values are valid query string uri
*/
	This:C1470.customAuthorizationUriParams:=New object:C1471()
	
/*
Callback to execute on the authenticateURI before the authorization request
	
Add custom query string parameters
*/
Function authenticateURIExtender($uri : Text)->$uriExtended : Text
	var $paramName : Text
	$uriExtended:=$uri
	For each ($paramName; This:C1470.customAuthorizationUriParams)
		$uriExtended:=$uriExtended+"&"+$paramName+"="+This:C1470.customAuthorizationUriParams[$paramName]
	End for each 
	