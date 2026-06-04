/**
 * @class GoogleCalendarList
 * @extends _GoogleBaseList
 * @description Paginated list of Google Calendar entries returned by the
 *   `calendarList.list` endpoint. Exposes the raw calendar objects via the
 *   `calendars` getter; use `next()` / `previous()` inherited from `_BaseList`
 *   to navigate pages.
 */

Class extends _GoogleBaseList

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Object} $inParameters - `_GoogleBaseList` parameters object;
 *   pass at minimum `{url: Text}` pointing to the `calendarList.list` endpoint
 */
Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)

	Super($inProvider; $inParameters)


	// Mark: - [Public]
	// ----------------------------------------------------


/**
 * @function get calendars
 * @returns {Collection} Current page of Google Calendar list-entry objects
 * @description Returns the raw calendar objects from the current page as delivered
 *   by the API; call `next()` to advance to the following page
 */
Function get calendars() : Collection
    
    return This._internals._list