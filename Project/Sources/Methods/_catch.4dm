//%attributes = {"invisible":true}
If (cs._Tools.me.isDebug)  // for debug purposes
	
	If (cs._Tools.me.trace)
		TRACE
	End if 

	var $errors : Collection:=Last errors()
	
End if 
