#DECLARE($event : Integer)

Case of 
	: ($event=On before host database startup)
		var $webServer : Object
		$webServer:=WEB Server
End case 

