/**
 * @class Google
 * @description Facade providing lazy-initialised access to Google API clients:
 *   `mail` (`GoogleMail`), `user` (`GoogleUser`), and `calendar` (`GoogleCalendar`).
 *   Clients are instantiated on first access and reused for subsequent calls.
 *
 * @example
 *   var $google : cs.Google := cs.Google.new($oAuth2Provider; {mailType: "JMAP"})
 *   var $status : Object := $google.mail.send($mail)
 */

property _internals : Object

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used by all Google API clients
 * @param {Object} $inParameters - Configuration forwarded to `GoogleMail` and
 *   `GoogleCalendar`; recognised properties:
 *   - `mailType` {Text} — Mail output format: `"JMAP"` (default) or `"MIME"`
 *   - `userId` {Text} — Gmail user ID (defaults to `"me"`)
 */
Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	This._internals:={_oAuth2Provider: $inProvider; _parameters: $inParameters; _mail: Null; _user: Null; _calendar: Null}
	
	
	// Mark: - [Public]
	// ----------------------------------------------------


/**
 * @function get mail
 * @returns {cs.GoogleMail} Lazy-initialised `GoogleMail` client; the same instance
 *   is returned on every subsequent call
 */
Function get mail : cs.GoogleMail
	
	If (This._internals._mail=Null)
		This._internals._mail:=cs.GoogleMail.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._mail
	
	
	// ----------------------------------------------------
	
	
/**
 * @function get user
 * @returns {cs.GoogleUser} Lazy-initialised `GoogleUser` client; the same instance
 *   is returned on every subsequent call
 */
Function get user : cs.GoogleUser
	
	If (This._internals._user=Null)
		This._internals._user:=cs.GoogleUser.new(This._internals._oAuth2Provider)
	End if 
	return This._internals._user
	
	
	// ----------------------------------------------------
	
	
/**
 * @function get calendar
 * @returns {cs.GoogleCalendar} Lazy-initialised `GoogleCalendar` client; the same
 *   instance is returned on every subsequent call
 */
Function get calendar : cs.GoogleCalendar
	
	If (This._internals._calendar=Null)
		This._internals._calendar:=cs.GoogleCalendar.new(This._internals._oAuth2Provider; This._internals._parameters)
	End if 
	return This._internals._calendar
