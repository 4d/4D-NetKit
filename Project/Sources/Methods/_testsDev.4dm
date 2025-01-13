//%attributes = {}
var $options:={}
$options.permission:="signedIn"
$options.timeout:=30
$options.redirectURI:="http://127.0.0.1:50993/authorize/"
$options.accessType:="offline"
$options.PKCEEnabled:=True:C214
$options.enableDebugLog:=True:C214

If (True:C214)
	$options.name:="Microsoft"
	$options.clientId:="7008ebf5-f013-4d92-ad5b-8c2252c460fc"
	$options.scope:="https://graph.microsoft.com/.default"
Else 
	$options.name:="Google"
	$options.clientId:="31264495209-ot6tevrkqj7c62tnieqmp7uq2i680d26.apps.googleusercontent.com"
	$options.clientSecret:="auROtyUBnPcH01aqo6eu3Ae5"
	$options.scope:="https://mail.google.com/"
	$options.mail:="yannick.trinh@gmail.com"
	//$options.loginHint:=$options.mail
	//$options.prompt:="consent"  // none ; consent ; select_account
End if 
HTTP SET OPTION:C1160(HTTP client log:K71:16; HTTP enable log with all body parts:K71:21)

TRACE:C157
var $oauth2:=cs:C1710.OAuth2Provider.new($options)
var $token : Object:=$oauth2.getToken()

HTTP SET OPTION:C1160(HTTP client log:K71:16; HTTP disable log:K71:17)
