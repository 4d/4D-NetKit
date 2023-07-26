//%attributes = {"invisible":true}
var $ws : 4D:C1709.WebServer

$ws:=WEB Server:C1674(Web server database:K73:30)

If ($ws.isRunning)
	$ws.stop()
End if 
