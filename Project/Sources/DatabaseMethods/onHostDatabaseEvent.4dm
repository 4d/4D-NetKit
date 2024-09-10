C_LONGINT:C283($1)

Case of 
	: ($1=On before host database startup:K74:3)
		var $webServer : Object
		$webServer:=WEB Server:C1674
		var $webLicenseAvailable : Boolean
		If (Application type:C494=4D Remote mode:K5:5)
			$webLicenseAvailable:=Is license available:C714(4D Client Web license:K44:6)
		Else 
			$webLicenseAvailable:=(Is license available:C714(4D Web license:K44:3) | Is license available:C714(4D Web local license:K44:14) | Is license available:C714(4D Web one connection license:K44:15))
		End if 
		Use (Storage:C1525)
			Storage:C1525.options:=New shared object:C1526("webLicenseAvailable"; $webLicenseAvailable)
		End use 
		
End case 

