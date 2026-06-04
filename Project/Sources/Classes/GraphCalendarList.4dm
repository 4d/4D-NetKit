/**
 * @class GraphCalendarList
 * @description Pageable list of Outlook calendars returned by a Graph API query.
 *   The `calendars` getter returns the list as a `Collection` of plain objects.
 */

Class extends _GraphBaseList

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Text} $inURL - Initial Graph API URL
 * @param {Object} $inHeaders - Additional HTTP headers
 */
Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider; $inURL; $inHeaders)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
/**
 * @function get calendars
 * @returns {Collection} The current page of calendar objects
 */
Function get calendars() : Collection
	
	return This._internals._list
