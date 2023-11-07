//%attributes = {}

// ----------------------------------------------------
// User name (OS): sblaser
// Date and time: 03.11.23, 13:27:47
// ----------------------------------------------------
// Method: test_method_sblaser
// Description
// 

// Parameters
// ----------------------------------------------------


var $t_privatekey : Text
var $o_params : Object
var $cs_oAuth : cs.OAuth2Provider
var $v_token : Variant
t_privatekey:=""
$t_privatekey:=File("C:/Users/sblaser/AppData/Local/Temp/O365/Alex/private.pem").getText("ascii"; Document unchanged)

If (Length($t_privatekey)>0)
	$o_params:=New object()
	$o_params.name:="Microsoft"
	$o_params.permission:="service"
	$o_params.clientId:="e7621d20-8f00-4933-80c8-d15446226f32"
	
	//$o_params.clientSecret:="gotcha"
	//$o_params.clientSecret
	$o_params.scope:="https://graph.microsoft.com/.default"
	$o_params.tenant:="e0fb5e9f-de14-438c-8cdb-41a4a402d5cd"
	$o_params.privateKey:=$t_privatekey
	$o_params.clientEmail:="sblaseradm@bossinfo.ch"
	$o_params.tokenURI:="https://login.microsoftonline.com/e0fb5e9f-de14-438c-8cdb-41a4a402d5cd/oauth2/v2.0/token"
	$o_params.authenticateURI:="https://login.microsoftonline.com/e0fb5e9f-de14-438c-8cdb-41a4a402d5cd/oauth2/v2.0/authorize"
	$o_params.grantType:="client_credentials"
	$o_params.clientAssertionType:="urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
	$o_params._thumbprint:="6D95BDD3CB370B2A270D966CB584F90FDF4714DA"  //thumbprint of certificate / public key can be copied in Azure portal at certificated & secrets
	
	$cs_oAuth:=cs.OAuth2Provider.new($o_params)
	$v_token:=$cs_oAuth.getToken()
End if 
