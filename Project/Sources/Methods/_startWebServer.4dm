//%attributes = {"invisible":true}
#DECLARE($inParameters : Object)->$OK : Boolean

var $port : Integer:=(Num($inParameters.port)>0) ? Num($inParameters.port) : 50993
var $bIsSSL : Boolean:=(Value type($inParameters.useTLS)#Is undefined) ? Bool($inParameters.useTLS) : False
var $debugLog : Integer:=Bool($inParameters.enableDebugLog) ? wdl enable with all body parts : wdl disable web log
var $webServer : 4D.WebServer:=WEB Server(Web server database)

If ($webServer.isRunning)
	If (($webServer.HTTPEnabled=$bIsSSL) || ($bIsSSL && ($webServer.HTTPSPort#$port)) || (Not($bIsSSL) && ($webServer.HTTPPort#$port)) || ($webServer.debugLog#$debugLog))
		$webServer.stop()
		DELAY PROCESS(Current process; 20)
	End if 
End if 

If (Not($webServer.isRunning))
	var $settings : Object:={}
	$settings.HTTPEnabled:=Not($bIsSSL)
	$settings.HTTPSEnabled:=$bIsSSL
	If ($bIsSSL)
		$settings.HTTPSPort:=$port
		$settings.certificateFolder:=Folder("/PACKAGE/";*)
	Else 
		$settings.HTTPPort:=$port
	End if 
	$settings.debugLog:=$debugLog
	$settings.scalableSession:=False
	$settings.keepSession:=False
	
	If (OB Is defined($inParameters; "webFolder"))
		If (OB Instance of($inParameters.webFolder; 4D.Folder))
			$settings.rootFolder:=$inParameters.webFolder
		Else 
			$settings.rootFolder:=Folder($inParameters.webFolder; fk platform path)
		End if 
	End if 
	
	var $status : Object:=$webServer.start($settings)
	
End if 

$OK:=$webServer.isRunning
