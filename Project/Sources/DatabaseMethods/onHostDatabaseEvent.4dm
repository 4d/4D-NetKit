C_LONGINT($1)

Case of 
	: ($1=On before host database startup)
		var $webServer : Object
		$webServer:=WEB Server
		var $webLicenseAvailable : Boolean:=False
		If (Application type=4D Remote mode)
			$webLicenseAvailable:=Is license available(4D Client Web license)
		Else 
			$webLicenseAvailable:=(Is license available(4D Web license) | Is license available(4D Web local license) | Is license available(4D Web one connection license))
		End if 
		Use (Storage)
			Storage.options:=New shared object("webLicenseAvailable"; $webLicenseAvailable)
		End use 
		
End case 

