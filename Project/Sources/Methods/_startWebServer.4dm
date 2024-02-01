//%attributes = {"invisible":true}
#DECLARE($inParameters : Object)->$OK : Boolean

var $port : Integer:=(Num($inParameters.port)>0) ? Num($inParameters.port) : 50993
var $debugLog : Integer:=Bool($inParameters.enableDebugLog) ? wdl enable with all body parts : wdl disable web log
var $settings : Object:={HTTPEnabled: True; HTTPSEnabled: False; HTTPPort: $port; debugLog: $debugLog}
var $webServer : 4D.WebServer:=WEB Server(Web server database)

If (OB Is defined($inParameters; "webFolder"))
	If (OB Instance of($inParameters.webFolder; 4D.Folder))
		$settings.rootFolder:=$inParameters.webFolder
	Else 
		$settings.rootFolder:=Folder($inParameters.webFolder; fk platform path)
	End if 
End if 

If ($webServer.isRunning && (($webServer.HTTPPort#$settings.HTTPPort) || ($webServer.debugLog#$settings.debugLog)))
	
	$webServer.stop()
	
	DELAY PROCESS(Current process; 20)
	
End if 


If (Not($webServer.isRunning))
	
	var $status : Text:=$webServer.start($settings)
	
End if 

$OK:=$webServer.isRunning
