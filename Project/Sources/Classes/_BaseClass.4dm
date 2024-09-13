property _internals : Object

Class constructor()
	
	This:C1470._internals:={_errorStack: Null:C1517; _throwErrors: True:C214; _savedErrorHandler: ""}
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _pushError($inCode : Integer; $inParameters : Object) : Object
	
	// Push error into errorStack without throwing it
	var $description : Text:=Localized string:C991("ERR_4DNK_"+String:C10($inCode))
	
	If (Not:C34(OB Is empty:C1297($inParameters)))
		var $key : Text
		For each ($key; $inParameters)
			$description:=Replace string:C233($description; "{"+$key+"}"; String:C10($inParameters[$key]))
		End for each 
	End if 
	
	// Push error into errorStack 
	var $error : Object:={errCode: $inCode; componentSignature: "4DNK"; message: $description}
	If (This:C1470._internals._errorStack=Null:C1517)
		This:C1470._internals._errorStack:=[]
	End if 
	This:C1470._internals._errorStack.push($error)
	
	return $error
	
	
	// ----------------------------------------------------
	
	
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it
	var $error : Object:=This:C1470._pushError($inCode; $inParameters)
	
	If (This:C1470._internals._throwErrors)
		$error.deferred:=True:C214
		throw:C1805($error)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _try
	
	CLEAR VARIABLE:C89(ERROR)
	CLEAR VARIABLE:C89(ERROR METHOD)
	CLEAR VARIABLE:C89(ERROR LINE)
	CLEAR VARIABLE:C89(ERROR FORMULA)
	
	ON ERR CALL:C155("_catch"; ek errors from components:K92:3)
	
	
	// ----------------------------------------------------
	
	
Function _finally
	
	ON ERR CALL:C155(This:C1470._internals._throwErrors ? "_throwError" : ""; ek errors from components:K92:3)
	
	
	// ----------------------------------------------------
	
	
Function _getErrorStack : Collection
	
	If (This:C1470._internals._errorStack=Null:C1517)
		This:C1470._internals._errorStack:=[]
	End if 
	return This:C1470._internals._errorStack
	
	
	// ----------------------------------------------------
	
	
Function _getLastError : Object
	
	If (This:C1470._getErrorStack().length>0)
		return This:C1470._getErrorStack().last()
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
		This:C1470._resetErrorHandler()
	Else 
		This:C1470._installErrorHandler()
		This:C1470._internals._throwErrors:=False:C215
		This:C1470._getErrorStack().clear()
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _installErrorHandler($inErrorHandler : Text)
	
	This:C1470._internals._savedErrorHandler:=Method called on error:C704
	ON ERR CALL:C155((Length:C16($inErrorHandler)>0) ? $inErrorHandler : "_errorHandler"; ek errors from components:K92:3)
	
	
	// ----------------------------------------------------
	
	
Function _resetErrorHandler
	
	ON ERR CALL:C155(This:C1470._internals._savedErrorHandler; ek errors from components:K92:3)
	This:C1470._internals._savedErrorHandler:=""
	