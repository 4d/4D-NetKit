//%attributes = {"invisible":true}
#DECLARE($inPort : Integer)->$OK : Boolean

var $WS : 4D:C1709.WebServer
var $port : Integer
var $settings; $status : Object

If (Count parameters:C259>0)
	$port:=$inPort
Else 
	$port:=50993
End if 

$settings:=New object:C1471
$settings.HTTPEnabled:=True:C214
$settings.HTTPSEnabled:=False:C215
$settings.HTTPPort:=$port

$WS:=WEB Server:C1674(Web server database:K73:30)

If ($WS.isRunning & ($WS.HTTPPort#$port))
	
	$WS.stop()
	
	DELAY PROCESS:C323(Current process:C322; 20)
	
End if 


If (Not:C34($WS.isRunning))
	
	$status:=$WS.start($settings)
	
End if 

$OK:=$WS.isRunning
