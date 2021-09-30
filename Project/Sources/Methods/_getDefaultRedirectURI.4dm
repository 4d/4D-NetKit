//%attributes = {"invisible":true}
#DECLARE()->$URI : Text

var $WS : 4D:C1709.WebServer

$WS:=WEB Server:C1674(Web server database:K73:30)

If ($WS.isRunning)
	
	var $port : Integer
	
	Case of 
		: ($WS.HTTPEnabled | $WS.HTTPSEnabled)
			$URI:=Choose:C955($WS.HTTPEnabled; "http://"; "https://")
			$port:=Choose:C955($WS.HTTPEnabled; $WS.HTTPPort; $WS.HTTPSPort)
		Else 
			$URI:=""
	End case 
	
	If (Length:C16($URI)>0)
		$URI:=$URI+Choose:C955($WS.IPAddressToListen="0.0.0.0"; "127.0.0.1"; $WS.IPAddressToListen)
		$URI:=$URI+":"+String:C10($port)+"/authorize/"
	End if 
	
End if 