C_LONGINT($1)

Case of 
	: ($1=On before host database startup)
		var $webServer : Object
		$webServer:=WEB Server
		Use (Storage)
			If (Application type=4D Remote mode)
				Storage.webLicenseAvailable:=Is license available(4D Client Web license)
			Else 
				Storage.webLicenseAvailable:=(Is license available(4D Web license) | Is license available(4D Web local license) | Is license available(4D Web one connection license))
			End if 
		End use 
		
End case 

