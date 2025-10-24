#DECLARE($event : Integer)

Case of 
	: ($event=On before host database startup)
		var $webServer : Object
		$webServer:=WEB Server
		If (Is Windows || Is macOS)
			cs._Tools.me.init()  // Check Licences
		End if 
End case 
