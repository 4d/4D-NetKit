/**
 * @class GoogleUserList
 * @extends _GoogleBaseList
 * @description Paginated list of Google People API contacts returned by the
 *   `people.connections.list` endpoint. Exposes the raw person objects via the
 *   `users` getter; use `next()` / `previous()` inherited from `_BaseList`
 *   to navigate pages.
 */

Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Text} $inURL - Full URL of the People API list endpoint
 *   (including query parameters such as `personFields`, `pageSize`, etc.)
 * @param {Object} $inHeaders - Additional HTTP headers to include in each request
 *   (e.g. `{"X-Goog-Request-Reason": "..."}`)
 */
   
   Super($inProvider; {url: $inURL; elements: "people"; headers: $inHeaders})
   
   
   // Mark: - [Public]
   // ----------------------------------------------------
   
   
Function get users() : Collection
/**
 * @function get users
 * @returns {Collection} Current page of raw Google People resource objects
 * @description Returns the person objects from the current page as delivered
 *   by the API; call `next()` to advance to the following page
 */
   
   return This._internals._list