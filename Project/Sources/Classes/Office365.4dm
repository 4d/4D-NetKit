/**
 * @class Office365
 * @description Facade providing lazy-initialised access to Microsoft Graph API clients:
 *   `user` (`Office365User`), `mail` (`Office365Mail`), `calendar` (`Office365Calendar`),
 *   and `category` (`Office365Category`).
 *   Clients are instantiated on first access and reused for subsequent calls.
 *
 * @example
 *   var $o365 : cs.Office365 := cs.Office365.new($oAuth2Provider; {mailType: "Microsoft"})
 *   var $status : Object := $o365.mail.send($mail)
 */

property _internals : Object

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used by all Microsoft Graph API clients
 * @param {Object} $inParameters - Configuration forwarded to `Office365Mail`, `Office365Calendar`,
 *   and `Office365Category`; recognised properties:
 *   - `mailType` {Text} — Mail format: `"Microsoft"` (default), `"JMAP"`, or `"MIME"`
 *   - `userId` {Text} — Graph user ID or UPN (defaults to the authenticated user)
 */
Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	This._internals:={_oAuth2Provider: $inProvider; _user: Null; _mail: Null; _calendar: Null; _category: Null; _parameters: $inParameters}
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
/**
 * @function get user
 * @returns {cs.Office365User} Lazy-initialised `Office365User` client; the same instance
 *   is returned on every subsequent call
 */
Function get user : cs.Office365User
	
	If (This._internals._user=Null)
		This._internals._user:=cs.Office365User.new(This._internals._oAuth2Provider)
	End if 
	return This._internals._user
	
	
	// ----------------------------------------------------
	
	
/**
 * @function get mail
 * @returns {cs.Office365Mail} Lazy-initialised `Office365Mail` client; the same instance
 *   is returned on every subsequent call
 */
Function get mail : cs.Office365Mail
	
	If (This._internals._mail=Null)
		This._internals._mail:=cs.Office365Mail.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._mail
	
	
	// ----------------------------------------------------
	
	
/**
 * @function get calendar
 * @returns {cs.Office365Calendar} Lazy-initialised `Office365Calendar` client; the same instance
 *   is returned on every subsequent call
 */
Function get calendar : cs.Office365Calendar
	
	If (This._internals._calendar=Null)
		This._internals._calendar:=cs.Office365Calendar.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._calendar
	
	
	// ----------------------------------------------------
	
	
/**
 * @function get category
 * @returns {cs.Office365Category} Lazy-initialised `Office365Category` client; the same instance
 *   is returned on every subsequent call
 */
Function get category : cs.Office365Category
	
	If (This._internals._category=Null)
		This._internals._category:=cs.Office365Category.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._category
