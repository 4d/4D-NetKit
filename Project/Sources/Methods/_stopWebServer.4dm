//%attributes = {"invisible":true}
var $webServer : 4D.WebServer:=WEB Server(Web server database)

If ($webServer.isRunning)
	$webServer.stop()
End if 
