//%attributes = {"invisible":true}
If (cs.Tools.me.isDebug)  // for debug purposes
	
	If (cs.Tools.me.trace)
		TRACE
	End if 
	
	var $errors : Collection:=Last errors()
	
End if 
