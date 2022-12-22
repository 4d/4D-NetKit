Class constructor()
	
	This:C1470._internals:=New object:C1471
	This:C1470._internals._errorStack:=Null:C1517
	This:C1470._internals._throwErrors:=True:C214
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _pushError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack without throwing it
	var $description : Text
	
	$description:=Get localized string:C991("ERR_4DNK_"+String:C10($inCode))
	
	If (Not:C34(OB Is empty:C1297($inParameters)))
		var $key : Text
		For each ($key; $inParameters)
			$description:=Replace string:C233($description; "{"+$key+"}"; String:C10($inParameters[$key]))
		End for each 
	End if 
	
	This:C1470._pushInErrorStack($inCode; $description)
	
	
	// ----------------------------------------------------
	
	
Function _pushInErrorStack($inErrorCode : Integer; $inErrorDescription : Text)
	
	// Push error into errorStack without throwing it
	var $error : Object
	
	$error:=New object:C1471("errCode"; $inErrorCode; "componentSignature"; "4DNK"; "message"; $inErrorDescription)
	If (This:C1470._internals._errorStack=Null:C1517)
		This:C1470._internals._errorStack:=New collection:C1472
	End if 
	This:C1470._internals._errorStack.push($error)
	
	
	// ----------------------------------------------------
	
	
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
	
	
Function _try
	
	CLEAR VARIABLE:C89(ERROR)
	CLEAR VARIABLE:C89(ERROR METHOD)
	CLEAR VARIABLE:C89(ERROR LINE)
	CLEAR VARIABLE:C89(ERROR FORMULA)
	
	ON ERR CALL:C155("_catch")
	
	
	// ----------------------------------------------------
	
	
Function _finally
	
	ON ERR CALL:C155(This:C1470._internals._throwErrors ? "_throwError" : "")
	
	
	// ----------------------------------------------------
	
	
Function _getErrorStack : Collection
	
	If (This:C1470._internals._errorStack=Null:C1517)
		This:C1470._internals._errorStack:=New collection:C1472
	End if 
	return This:C1470._internals._errorStack
	
	
	// ----------------------------------------------------
	
	
Function _getLastError : Object
	
	If (This:C1470._getErrorStack().length>0)
		return This:C1470._getErrorStack()[This:C1470._getErrorStack().length-1]
	End if 
	return Null:C1517
	
	
	// ----------------------------------------------------
	
	
Function _getLastErrorCode : Integer
	
	return Num:C11(This:C1470._getLastError().errCode)
	
	
	// ----------------------------------------------------
	
	
Function _clearErrorStack
	
	This:C1470._getErrorStack().clear()
	
	
	// ----------------------------------------------------
	
	
Function _throwErrors($inThrowErrors : Boolean)
	
	If (Bool:C1537($inThrowErrors))
		This:C1470._internals._throwErrors:=True:C214
		ON ERR CALL:C155(String:C10(This:C1470._internals._savedErrorCallMethod))
		This:C1470._internals._savedErrorCallMethod:=""
	Else 
		This:C1470._internals._savedErrorCallMethod:=Method called on error:C704
		ON ERR CALL:C155("_ErrorHandler")
		This:C1470._internals._throwErrors:=False:C215
		This:C1470._getErrorStack().clear()
	End if 
	