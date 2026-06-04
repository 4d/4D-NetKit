/**
 * @class GraphMessageList
 * @description Pageable list of Outlook messages returned by a Graph API query.
 *   The `mails` getter returns the current page as a `Collection` of `GraphMessage` instances.
 *   Each item is wrapped lazily on first access and cached.
 */

Class extends _GraphBaseList

/**
 * @constructor
 * @param {cs.Office365Mail} $inMail - The `Office365Mail` client owning this list
 *   (used to resolve `userId` when hydrating `GraphMessage` instances)
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Text} $inURL - Initial Graph API URL
 * @param {Object} $inHeaders - Additional HTTP headers
 */
Class constructor($inMail : cs.Office365Mail; $inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider; $inURL; $inHeaders)
	This._internals._mail:=$inMail
	This._internals._mails:=Null
	This._internals._update:=True
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
/**
 * @function get mails
 * @returns {Collection} Current page as a `Collection` of `GraphMessage` instances;
 *   computed once and cached until the next page is loaded
 */
Function get mails() : Collection
	
	If (This._internals._update)
		
		var $iter : Object
		var $provider : cs.OAuth2Provider:=This._internals._oAuth2Provider
		
		This._internals._mails:=[]
		For each ($iter; This._internals._list)
			var $mail : cs.GraphMessage:=cs.GraphMessage.new($provider; {userId: String(This._internals._mail.userId)}; $iter)
			This._internals._mails.push($mail)
		End for each 
		
		This._internals._update:=False
	End if 
	
	return This._internals._mails
	
	

