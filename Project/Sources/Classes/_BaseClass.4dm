Class constructor()
	
	This:C1470._internals:=New object:C1471
	This:C1470._internals._errorStack:=Null:C1517
	This:C1470._internals._throwErrors:=True:C214
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _pushError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack without throwing it
	var $error : Object
	var $description : Text
	
	$description:=Get localized string:C991("ERR_4DNK_"+String:C10($inCode))
	
	If (Not:C34(OB Is empty:C1297($inParameters)))
		var $key : Text
		For each ($key; $inParameters)
			$description:=Replace string:C233($description; "{"+$key+"}"; String:C10($inParameters[$key]))
		End for each 
	End if 
	
	$error:=New object:C1471("errCode"; $inCode; "componentSignature"; "4DNK"; "message"; $description)
	If (This:C1470._internals._errorStack=Null:C1517)
		This:C1470._internals._errorStack:=New collection:C1472
	End if 
	This:C1470._internals._errorStack.push($error)
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it
	This:C1470._pushError($inCode; $inParameters)
	
	If (This:C1470._internals._throwErrors)
		var $error : Object
		$error:=New object:C1471("code"; $inCode; "component"; "4DNK"; "deferred"; True:C214)
		
		If (Not:C34(OB Is empty:C1297($inParameters)))
			var $key : Text
			For each ($key; $inParameters)
				$error[$key]:=$inParameters[$key]
			End for each 
		End if 
		
		_4D THROW ERROR:C1520($error)
	End if 
	
	
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
	
	ON ERR CALL:C155(This:C1470._internals._throwErrors ? "_throwError" : "")
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getErrorStack : Collection
	
	If (This:C1470._internals._errorStack=Null:C1517)
		This:C1470._internals._errorStack:=New collection:C1472
	End if 
	return This:C1470._internals._errorStack
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _throwErrors($inValue : Boolean)
	
	This:C1470._internals._throwErrors:=$inValue
	