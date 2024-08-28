#DECLARE($event : Integer)

Case of 
	: ($event=On before host database startup)
		var $webServer : Object
		$webServer:=WEB Server
		cs.Tools.me.init()  // Check Licences
End case 

