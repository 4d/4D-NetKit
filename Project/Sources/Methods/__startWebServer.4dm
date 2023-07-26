//%attributes = {"invisible":true}
#DECLARE($inParameters : Object)->$OK : Boolean

var $webServer : 4D:C1709.WebServer
var $settings; $status : Object

$settings:=New object:C1471
$settings.HTTPEnabled:=True:C214
$settings.HTTPSEnabled:=False:C215
$settings.HTTPPort:=(OB Is defined:C1231($inParameters; "port")) ? Num:C11($inParameters.port) : 50993
$settings.debugLog:=(OB Is defined:C1231($inParameters; "enableDebugLog") && $inParameters.enableDebugLog) ? wdl enable with all body parts:K73:23 : wdl disable web log:K73:19

If (OB Is defined:C1231($inParameters; "webFolder"))
	If (OB Instance of:C1731($inParameters.webFolder; 4D:C1709.Folder))
		$settings.rootFolder:=$inParameters.webFolder
	Else 
		$settings.rootFolder:=Folder:C1567($inParameters.webFolder; fk platform path:K87:2)
	End if 
End if 

$webServer:=WEB Server:C1674(Web server database:K73:30)

If ($webServer.isRunning & (($webServer.HTTPPort#$settings.HTTPPort) || \
($webServer.debugLog#$settings.debugLog)))
	
	$webServer.stop()
	
	DELAY PROCESS:C323(Current process:C322; 20)
	
End if 


If (Not:C34($webServer.isRunning))
	
	$status:=$webServer.start($settings)
	
End if 

$OK:=$webServer.isRunning
