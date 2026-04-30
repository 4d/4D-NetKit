property _internals : Object

Class constructor()
	
	This._internals:={_errorStack: []}
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _pushError($inCode : Integer; $inParameters : Object) : Object
	
	// Push error into errorStack without throwing it
	var $error : Object:=cs._Tools.me.makeError($inCode; $inParameters)
	This._internals._errorStack.push($error)
	
	return $error
	
	
	// ----------------------------------------------------
	
	
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it as deferred
	var $error : Object:=This._pushError($inCode; $inParameters)
	$error.deferred:=True
	throw($error)
	
	
	// ----------------------------------------------------
	
	
Function _getErrorStack() : Collection
	
	return This._internals._errorStack
	
	
	// ----------------------------------------------------
	
	
Function _getLastError() : Object
	
	If (This._internals._errorStack.length>0)
		return This._internals._errorStack.last()
	End if 
	return Null
	
	
	// ----------------------------------------------------
	
	
Function _getLastErrorCode() : Integer
	
	var $lastError : Object:=This._getLastError()
	If ($lastError#Null)
		return Num($lastError.errCode)
	End if 
	return 0
	
	
	// ----------------------------------------------------
	
	
Function _clearErrorStack()
	
	This._internals._errorStack.clear()
