property _internals : Object

Class constructor()
	
	This._internals:={_errorStack: Null; _throwErrors: True; _savedErrorHandler: ""}
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _pushError($inCode : Integer; $inParameters : Object) : Object
	
	// Push error into errorStack without throwing it
	var $error : Object:=cs.Tools.me.makeError($inCode; $inParameters)
	If (This._internals._errorStack=Null)
		This._internals._errorStack:=[]
	End if 
	This._internals._errorStack.push($error)
	
	return $error
	
	
	// ----------------------------------------------------
	
	
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it
	var $error : Object:=This._pushError($inCode; $inParameters)
	
	If (This._internals._throwErrors)
		$error.deferred:=True
		throw($error)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _try
	
	CLEAR VARIABLE(ERROR)
	CLEAR VARIABLE(ERROR METHOD)
	CLEAR VARIABLE(ERROR LINE)
	CLEAR VARIABLE(ERROR FORMULA)
	
	ON ERR CALL("_catch"; ek errors from components)
	
	
	// ----------------------------------------------------
	
	
Function _finally
	
	ON ERR CALL(This._internals._throwErrors ? "_throwError" : ""; ek errors from components)
	
	
	// ----------------------------------------------------
	
	
Function _getErrorStack : Collection
	
	If (This._internals._errorStack=Null)
		This._internals._errorStack:=[]
	End if 
	return This._internals._errorStack
	
	
	// ----------------------------------------------------
	
	
Function _getLastError : Object
	
	If (This._getErrorStack().length>0)
		return This._getErrorStack().last()
	End if 
	return Null
	
	
	// ----------------------------------------------------
	
	
Function _getLastErrorCode : Integer
	
	return Num(This._getLastError().errCode)
	
	
	// ----------------------------------------------------
	
	
Function _clearErrorStack
	
	This._getErrorStack().clear()
	
	
	// ----------------------------------------------------
	
	
Function _throwErrors($inThrowErrors : Boolean) : Boolean
	
	var $oldValue : Boolean:=This._internals._throwErrors
	
	If (Bool($inThrowErrors))
		This._internals._throwErrors:=True
		This._resetErrorHandler()
	Else 
		This._installErrorHandler()
		This._internals._throwErrors:=False
		This._getErrorStack().clear()
	End if 
	
	return $oldValue
	
	
	// ----------------------------------------------------
	
	
Function _installErrorHandler($inErrorHandler : Text)
	
	This._internals._savedErrorHandler:=Method called on error
	ON ERR CALL((Length($inErrorHandler)>0) ? $inErrorHandler : "_errorHandler"; ek errors from components)
	
	
	// ----------------------------------------------------
	
	
Function _resetErrorHandler
	
	ON ERR CALL(This._internals._savedErrorHandler; ek errors from components)
	This._internals._savedErrorHandler:=""
