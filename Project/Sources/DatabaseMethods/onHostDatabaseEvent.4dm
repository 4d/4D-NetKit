/**
 * @method onHostDatabaseEvent
 * @description Database method called on host database lifecycle events.
 *   On `On before host database startup`: initialises `_Tools` (licence check)
 *   on Windows and macOS.
 * @param {Integer} $event - Database event constant
 *   (e.g. `On before host database startup`)
 */
#DECLARE($event : Integer)

Case of 
	: ($event=On before host database startup)
		var $webServer : Object
		$webServer:=WEB Server
		If (Is Windows || Is macOS)
			cs._Tools.me.init()  // Check Licences
		End if 
End case 
