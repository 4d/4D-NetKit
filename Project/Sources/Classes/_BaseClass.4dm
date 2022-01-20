Class constructor()
	
	This:C1470._lastErrorCallMethod:=""
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _throwError($code : Integer; $parameters : Object)
	
	var $error : Object
	$error:=New object:C1471("code"; $code; "component"; "4DNK"; "deferred"; True:C214)
	
	If (Not:C34(OB Is empty:C1297($parameters)))
		var $key : Text
		For each ($key; $parameters)
			$error[$key]:=$parameters[$key]
		End for each 
	End if 
	
	_4D THROW ERROR:C1520($error)
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _try
	
	This:C1470._lastErrorCallMethod:=Method called on error:C704
	If (Length:C16(This:C1470._lastErrorCallMethod)>0)
		CLEAR VARIABLE:C89(ERROR)
		CLEAR VARIABLE:C89(ERROR METHOD)
		CLEAR VARIABLE:C89(ERROR LINE)
		CLEAR VARIABLE:C89(ERROR FORMULA)
		
		ON ERR CALL:C155("_catch")
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _finally
	
	ON ERR CALL:C155(This:C1470._lastErrorCallMethod)
	