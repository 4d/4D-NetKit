/**
 * @class GraphCategoryList
 * @description Pageable list of Outlook master categories returned by a Graph API query.
 *   The `categories` getter returns the list as a `Collection` of plain objects.
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
	
	
Function get categories() : Collection
/**
 * @function get categories
 * @returns {Collection} The current page of master category objects
 */
	
	return This._internals._list
