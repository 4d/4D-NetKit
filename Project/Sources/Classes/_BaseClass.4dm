Class constructor()
	
	This._internals:=New object
	This._internals._errorStack:=Null
	This._internals._throwErrors:=True
	This._internals._savedErrorHandler:=""
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _pushError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack without throwing it
	var $description : Text
	
	$description:=Get localized string("ERR_4DNK_"+String($inCode))
	
	If (Not(OB Is empty($inParameters)))
		var $key : Text
		For each ($key; $inParameters)
			$description:=Replace string($description; "{"+$key+"}"; String($inParameters[$key]))
		End for each 
	End if 
	
	This._pushInErrorStack($inCode; $description)
	
	
	// ----------------------------------------------------
	
	
Function _pushInErrorStack($inErrorCode : Integer; $inErrorDescription : Text)
	
	// Push error into errorStack without throwing it
	var $error : Object
	
	$error:=New object("errCode"; $inErrorCode; "componentSignature"; "4DNK"; "message"; $inErrorDescription)
	If (This._internals._errorStack=Null)
		This._internals._errorStack:=New collection
	End if 
	This._internals._errorStack.push($error)
	
	
	// ----------------------------------------------------
	
	
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it
	This._pushError($inCode; $inParameters)
	
	If (This._internals._throwErrors)
		var $error : Object
		$error:=New object("code"; $inCode; "component"; "4DNK"; "deferred"; True)
		
		If (Not(OB Is empty($inParameters)))
			var $key : Text
			For each ($key; $inParameters)
				$error[$key]:=$inParameters[$key]
			End for each 
		End if 
		
		_4D THROW ERROR($error)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _try
	
	CLEAR VARIABLE(ERROR)
	CLEAR VARIABLE(ERROR METHOD)
	CLEAR VARIABLE(ERROR LINE)
	CLEAR VARIABLE(ERROR FORMULA)
	
	ON ERR CALL("_catch")
	
	
	// ----------------------------------------------------
	
	
Function _finally
	
	ON ERR CALL(This._internals._throwErrors ? "_throwError" : "")
	
	
	// ----------------------------------------------------
	
	
Function _getErrorStack : Collection
	
	If (This._internals._errorStack=Null)
		This._internals._errorStack:=New collection
	End if 
	return This._internals._errorStack
	
	
	// ----------------------------------------------------
	
	
Function _getLastError : Object
	
	If (This._getErrorStack().length>0)
		return This._getErrorStack()[This._getErrorStack().length-1]
	End if 
	return Null
	
	
	// ----------------------------------------------------
	
	
Function _getLastErrorCode : Integer
	
	return Num(This._getLastError().errCode)
	
	
	// ----------------------------------------------------
	
	
Function _clearErrorStack
	
	This._getErrorStack().clear()
	
	
	// ----------------------------------------------------
	
	
Function _throwErrors($inThrowErrors : Boolean)
	
	If (Bool($inThrowErrors))
		This._internals._throwErrors:=True
		This._resetErrorHandler()
	Else 
		This._installErrorHandler()
		This._internals._throwErrors:=False
		This._getErrorStack().clear()
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _installErrorHandler($inErrorHandler : Text)
	
	This._internals._savedErrorHandler:=Method called on error
	ON ERR CALL((Length($inErrorHandler)>0) ? $inErrorHandler : "_errorHandler")
	
	
	// ----------------------------------------------------
	
	
Function _resetErrorHandler
	
	ON ERR CALL(This._internals._savedErrorHandler)
	This._internals._savedErrorHandler:=""
