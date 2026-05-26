property _internals : Object

Class constructor()
	
	This._internals:={_errorStack: []; _statusLine: ""}
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _pushError($inCode : Integer; $inParameters : Object) : Object
	
	// Push error into errorStack without throwing it
	var $error : Object:=cs._Tools.me.makeError($inCode; $inParameters)
	If (Not(OB Is empty($inParameters)))
		var $key : Text
		For each ($key; $inParameters)
			$error[$key]:=$inParameters[$key]
		End for each 
	End if 
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


	// ----------------------------------------------------
	
	
Function _getStatusLine() : Text
	
	return String(This._internals._statusLine)


	// ----------------------------------------------------
	
	
Function _returnStatus($inAdditionalInfo : Object) : Object
	
	var $status : Object:={}
	var $errorStack : Collection:=This._getErrorStack()
	
	If (Not(OB Is empty($inAdditionalInfo)))
		$status:=OB Copy($inAdditionalInfo)
	End if 
	
	If ($errorStack.length>0)
		var $firstError : Object:=$errorStack.first()
		$status.success:=False
		$status.errors:=$errorStack
		$status.statusText:=String($firstError.message)
		If (OB Is defined($firstError; "status"))
			$status.status:=Num($firstError.status)
		End if 
	Else 
		$status.success:=True
		$status.statusText:=This._getStatusLine()
	End if 
	
	return $status
