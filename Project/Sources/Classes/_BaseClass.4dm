/**
 * @class _BaseClass
 * @description Base class for all NetKit API objects; provides an error stack,
 *   a status line, and helpers to build structured status responses
 */

property _internals : Object


Class constructor()
/**
 * @constructor
 * @description Initializes the internal error stack and status line
 */
	
	This._internals:={_errorStack: []; _statusLine: ""}
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _pushError($inCode : Integer; $inParameters : Object) : Object
/**
 * @function _pushError
 * @private
 * @param {Integer} $inCode - Error code
 * @param {Object} $inParameters - Key/value pairs merged into the error object
 * @returns {Object} The constructed error object
 * @description Builds a localized error object, merges $inParameters into it,
 *   and pushes it onto the internal error stack without throwing
 */
	
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
/**
 * @function _throwError
 * @private
 * @param {Integer} $inCode - Error code
 * @param {Object} $inParameters - Key/value pairs merged into the error object
 * @description Pushes an error onto the stack and immediately throws it as a deferred error
 */
	
	// Push error into errorStack and throw it as deferred
	var $error : Object:=This._pushError($inCode; $inParameters)
	$error.deferred:=True
	throw($error)
	
	
	// ----------------------------------------------------
	
	
Function _getErrorStack() : Collection
/**
 * @function _getErrorStack
 * @private
 * @returns {Collection} The full error stack
 */
	
	return This._internals._errorStack
	
	
	// ----------------------------------------------------
	
	
Function _getLastError() : Object
/**
 * @function _getLastError
 * @private
 * @returns {Object} The last error pushed onto the stack, or Null if the stack is empty
 */
	
	If (This._internals._errorStack.length>0)
		return This._internals._errorStack.last()
	End if 
	return Null
	
	
	// ----------------------------------------------------
	
	
Function _getLastErrorCode() : Integer
/**
 * @function _getLastErrorCode
 * @private
 * @returns {Integer} The errCode of the last error, or 0 if the stack is empty
 */
	
	var $lastError : Object:=This._getLastError()
	If ($lastError#Null)
		return Num($lastError.errCode)
	End if 
	return 0
	
	
	// ----------------------------------------------------
	
	
Function _clearErrorStack()
/**
 * @function _clearErrorStack
 * @private
 * @description Clears all errors from the internal error stack
 */
	
	This._internals._errorStack.clear()
	
	
	// ----------------------------------------------------
	
	
Function _getStatusLine() : Text
/**
 * @function _getStatusLine
 * @private
 * @returns {Text} The HTTP status line from the last request (e.g. "200 OK")
 */
	
	return String(This._internals._statusLine)
	
	
	// ----------------------------------------------------
	
	
Function _returnStatus($inAdditionalInfo : Object) : Object
/**
 * @function _returnStatus
 * @private
 * @param {Object} $inAdditionalInfo - Extra key/value pairs to merge into the status object
 * @returns {Object} Status object: {success; statusText; ?errors; ?status} merged with $inAdditionalInfo
 * @description Builds a standardized status response from the error stack;
 *   sets success=False and populates errors when the stack is non-empty
 */
	
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
