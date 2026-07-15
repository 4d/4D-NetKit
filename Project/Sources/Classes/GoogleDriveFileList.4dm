/**
 * @class GoogleDriveFileList
 * @extends _GoogleBaseList
 * @description Paginated list of Google Drive files returned by the Drive API.
 *   Exposes `GoogleDriveItem` objects via the `files` getter.
 */

Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object; $inBaseURL : Text)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Object} $inParameters - `_GoogleBaseList` parameters object
 * @param {Text} $inBaseURL - Drive API base URL
 */
   
   Super($inProvider; $inParameters)
   This._internals._baseURL:=$inBaseURL
   
   
   // Mark: - [Public]
   // ----------------------------------------------------
   
   
Function get files() : Collection
/**
 * @function get files
 * @returns {Collection} Current page of GoogleDriveItem objects
 */
   
   var $result : Collection:=[]
   var $provider : cs.OAuth2Provider:=This._getOAuth2Provider()
   var $baseURL : Text:=This._internals._baseURL
   var $obj : Object
   For each ($obj; This._internals._list)
      $result.push(cs.GoogleDriveItem.new($provider; $baseURL; $obj))
   End for each 
   return $result