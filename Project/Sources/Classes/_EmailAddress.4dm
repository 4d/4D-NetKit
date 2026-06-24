/**
 * @class _EmailAddress
 * @description Parses and manages email addresses with optional display name
 * @example
 *   var $email := cs._EmailAddress.new("John Doe <john@example.com>")
 *   $email.name   // "John Doe"
 *   $email.email  // "john@example.com"
 */

property name : Text
property email : Text

Class constructor($inName : Text; $inAddress : Text)
/**
 * @constructor
 * @param {Text} $inName - Display name or full address string ("Name <email@domain>")
 * @param {Text} $inAddress - Email address (used when two parameters are provided)
 */
	
	This._init()
	
	Case of 
		: (Count parameters=1)
			
			This.fromString($inName)
		Else 
			
			This.name:=This._normalizeDisplayName($inName)
			This.email:=cs._Tools.me.trimSpaces($inAddress)
	End case 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
Function _init()
/**
 * @function _init
 * @private
 * @description Resets name and email values
 */
	
	This.name:=""
	This.email:=""
	
	
	// ----------------------------------------------------


Function _normalizeDisplayName($inName : Text) : Text
/**
 * @function _normalizeDisplayName
 * @private
 * @param {Text} $inName - Raw display name
 * @returns {Text} Normalized display name (trimmed, optional surrounding quotes removed)
 */
	
	var $name : Text:=cs._Tools.me.trimSpaces($inName)
	If (Length($name)>=2)
		If ((Character code($name[[1]])=34) && (Character code($name[[Length($name)]])=34))
			$name:=Substring($name; 2; Length($name)-2)
		End if 
	End if 
	
	return $name
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function fromString($inValue : Text)
/**
 * @function fromString
 * @param {Text} $inValue - Address string ("Name <email@domain>" or "email@domain")
 * @description Parses and sets name/email from a string
 */
	
	This._init()
	
	var $value : Text:=cs._Tools.me.trimSpaces($inValue)
	var $email : Text:=""
	If (Length($value)=0)
		return 
	End if 
	
	var $startMailPos : Integer:=Position("<"; $value)
	var $endMailPos : Integer:=($startMailPos>0) ? Position(">"; $value; $startMailPos+1) : 0
	
	If (($startMailPos>0) && ($endMailPos>$startMailPos))
		
		This.name:=This._normalizeDisplayName(Substring($value; 1; $startMailPos-1))
		$email:=cs._Tools.me.trimSpaces(Substring($value; $startMailPos+1; $endMailPos-$startMailPos-1))
		If (cs._Tools.me.isValidEmail($email))
			This.email:=$email
		End if 
	Else 
		
		$email:=$value
		If (cs._Tools.me.isValidEmail($email))
			This.email:=$email
		End if 
	End if 
	
	
	// ----------------------------------------------------
	
	
Function toString() : Text
/**
 * @function toString
 * @returns {Text} String representation ("Name <email@domain>" or "email@domain")
 */
	
	If (Length(This.name)=0)
		return This.email
	Else 
		return String(This.name+" <"+This.email+">")
	End if 
	
	
	// ----------------------------------------------------
	
	
Function toJSON() : Object
/**
 * @function toJSON
 * @returns {Object} JSON representation for JMAP-style email objects
 */
	
	return {name: This.name; email: This.email}
	
	
	// ----------------------------------------------------
	
	
Function toGraphJSON() : Object
/**
 * @function toGraphJSON
 * @returns {Object} JSON representation for Microsoft Graph recipient emailAddress
 * @example
 *   {address: "john@example.com"; name: "John Doe"}
 */
	
	var $result : Object:={address: This.email}
	If (Length(This.name)>0)
		$result.name:=This.name
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function isValid() : Boolean
/**
 * @function isValid
 * @returns {Boolean} True if the email address is valid
 */
	
	return cs._Tools.me.isValidEmail(This.email)
