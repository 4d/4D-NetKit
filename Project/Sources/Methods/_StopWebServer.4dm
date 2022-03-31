//%attributes = {"invisible":true}
var $WS : 4D:C1709.WebServer

$WS:=WEB Server:C1674(Web server database:K73:30)

If ($WS.isRunning)
	$WS.stop()
	ASSERT:C1129($WS.isRunning=False:C215)
End if 
