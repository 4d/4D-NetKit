/**
 * @class GoogleMailIdList
 * @extends _GoogleBaseList
 * @description Paginated list of Gmail message identifiers returned by the Gmail
 *   `users.messages.list` endpoint. Exposes the raw message-id objects (each with
 *   `id` and `threadId`) via the `mailIds` getter; use `next()` / `previous()`
 *   inherited from `_BaseList` to navigate pages.
 */

Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Text} $inURL - Full URL of the Gmail messages list endpoint
 *   (including query parameters such as `q`, `maxResults`, etc.)
 */
	
	Super($inProvider; {url: $inURL; elements: "messages"})
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get mailIds() : Collection
/**
 * @function get mailIds
 * @returns {Collection} Current page of message-id objects (`{id: Text; threadId: Text}`)
 * @description Returns the raw list items from the current page as delivered by the API;
 *   call `next()` to advance to the following page
 */
	
	return This._internals._list