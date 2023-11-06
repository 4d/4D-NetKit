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


var $v_privatekey : Variant
var $o_params : Object
var $cs_oAuth : cs.OAuth2Provider
var $v_token : Variant
$v_privatekey:=File("..//private.pem").getText("ascii"; Document unchanged)

$o_params:=New object()
$o_params.name:="Microsoft"
$o_params.permission:="service"
$o_params.clientId:="..."
//$o_params.clientSecret:="gotcha"
//$o_params.clientSecret
$o_params.scope:="https://graph.microsoft.com/.default"
$o_params.tenant:="..."
$o_params.privateKey:=$v_privatekey
$o_params.clientEmail:="sblaseradm@bossinfo.ch"
$o_params.tokenURI:="https://login.microsoftonline.com/.../oauth2/v2.0/token"
$o_params.authenticateURI:="https://login.microsoftonline.com/.../oauth2/v2.0/authorize"
$o_params.grantType:="client_credentials"
$o_params.client_assertion_type:="urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
$o_params._thumbprint:=""  //thumbprint of certificate / public key can be copied in Azure portal at certificated & secrets

$cs_oAuth:=cs.OAuth2Provider.new($o_params)
//$v_token:=$cs_oAuth.getToken()
