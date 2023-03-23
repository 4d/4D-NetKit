//%attributes = {"invisible":true}
#DECLARE($inPort : Integer; $bEnableDebugLog : Boolean)->$OK : Boolean

var $ws : 4D:C1709.WebServer
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
$settings.debugLog:=($bEnableDebugLog) ? wdl enable with all body parts:K73:23 : wdl disable web log:K73:19

$ws:=WEB Server:C1674(Web server database:K73:30)

If ($ws.isRunning & ($ws.HTTPPort#$port))
	
	$ws.stop()
	
	DELAY PROCESS:C323(Current process:C322; 20)
	
End if 


If (Not:C34($ws.isRunning))
	
	$status:=$ws.start($settings)
	
End if 

$OK:=$ws.isRunning
