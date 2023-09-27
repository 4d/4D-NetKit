//%attributes = {"invisible":true}
#DECLARE($inParameters : Object)->$OK : Boolean

var $webServer : 4D.WebServer
var $settings; $status : Object

$settings:={HTTPEnabled: True; \
HTTPSEnabled: False; \
HTTPPort: (OB Is defined($inParameters; "port")) ? Num($inParameters.port) : 50993; \
debugLog: (OB Is defined($inParameters; "enableDebugLog") && $inParameters.enableDebugLog) ? wdl enable with all body parts : wdl disable web log}

If (OB Is defined($inParameters; "webFolder"))
	If (OB Instance of($inParameters.webFolder; 4D.Folder))
		$settings.rootFolder:=$inParameters.webFolder
	Else 
		$settings.rootFolder:=Folder($inParameters.webFolder; fk platform path)
	End if 
End if 

$webServer:=WEB Server(Web server database)

If ($webServer.isRunning & (($webServer.HTTPPort#$settings.HTTPPort) || \
($webServer.debugLog#$settings.debugLog)))
	
	$webServer.stop()
	
	DELAY PROCESS(Current process; 20)
	
End if 


If (Not($webServer.isRunning))
	
	$status:=$webServer.start($settings)
	
End if 

$OK:=$webServer.isRunning
