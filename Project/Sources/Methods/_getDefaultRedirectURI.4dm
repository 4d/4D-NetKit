//%attributes = {"invisible":true}
#DECLARE()->$URI : Text

var $ws : 4D:C1709.WebServer

$ws:=WEB Server:C1674(Web server database:K73:30)

If ($ws.isRunning)
	
	var $port : Integer
	
	Case of 
		: ($ws.HTTPEnabled | $ws.HTTPSEnabled)
			$URI:=Choose:C955($ws.HTTPEnabled; "http://"; "https://")
			$port:=Choose:C955($ws.HTTPEnabled; $ws.HTTPPort; $ws.HTTPSPort)
		Else 
			$URI:=""
	End case 
	
	If (Length:C16($URI)>0)
		$URI:=$URI+Choose:C955($ws.IPAddressToListen="0.0.0.0"; "127.0.0.1"; $ws.IPAddressToListen)
		$URI:=$URI+":"+String:C10($port)+"/authorize/"
	End if 
	
End if 