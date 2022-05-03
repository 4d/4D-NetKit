Class constructor()
	
	This:C1470._internals:=New object:C1471
	This:C1470._internals.errorStack:=Null:C1517
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _throwError($inCode : Integer; $inParameters : Object)
	
	var $error : Object
	$error:=New object:C1471("code"; $inCode; "component"; "4DNK"; "deferred"; True:C214)
	
	If (Not:C34(OB Is empty:C1297($inParameters)))
		var $key : Text
		For each ($key; $inParameters)
			$error[$key]:=$inParameters[$key]
		End for each 
	End if 
	
	If (This:C1470._internals.errorStack=Null:C1517)
		This:C1470._internals.errorStack:=New collection:C1472
		This:C1470._internals.errorStack.push($error)
	End if 
	
	_4D THROW ERROR:C1520($error)
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _try
	
	CLEAR VARIABLE:C89(ERROR)
	CLEAR VARIABLE:C89(ERROR METHOD)
	CLEAR VARIABLE:C89(ERROR LINE)
	CLEAR VARIABLE:C89(ERROR FORMULA)
	
	ON ERR CALL:C155("_catch")
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _finally
	
	ON ERR CALL:C155("_throwError")

