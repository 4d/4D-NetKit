/**
 * @class GraphRecipient
 * @description Represents a Microsoft Graph email recipient (`{emailAddress: {address; name}}`).
 *   Validates the address on construction and throws a deferred error (code 2) when invalid.
 */

property emailAddress : Object

Class constructor($inAddress : Text; $inName : Text)
/**
 * @constructor
 * @param {Text} $inAddress - Email address (validated via `_EmailAddress`)
 * @param {Text} $inName - Optional display name
 * @description Creates a Graph recipient object. Throws a deferred error with
 *   `{code: 2; component: "4DNK"; attribute: "address"}` when the address is invalid.
 */
	
	var $parsed : cs._EmailAddress:=cs._EmailAddress.new($inName; $inAddress)
	If ($parsed.isValid())
		
		This.emailAddress:={address: $parsed.email}
		If (Length($parsed.name)>0)
			This.emailAddress.name:=$parsed.name
		End if 
	Else 
		
		throw({code: 2; component: "4DNK"; deferred: True; attribute: "address"})
	End if 
