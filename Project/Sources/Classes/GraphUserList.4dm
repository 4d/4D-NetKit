/**
 * @class GraphUserList
 * @description Pageable list of Azure AD users returned by a Graph API query.
 *   The `users` getter returns the list as a `Collection` of plain objects.
 */

Class extends _GraphBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Text} $inURL - Initial Graph API URL
 * @param {Object} $inHeaders - Additional HTTP headers
 */
	
	Super($inProvider; $inURL; $inHeaders)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get users() : Collection
/**
 * @function get users
 * @returns {Collection} The current page of Azure AD user objects
 */
	
	return This._internals._list
