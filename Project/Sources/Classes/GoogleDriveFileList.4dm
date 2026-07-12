/**
 * @class GoogleDriveFileList
 * @extends _GoogleBaseList
 * @description Paginated list of Google Drive files returned by the Drive API.
 *   Exposes the raw file objects via the `files` getter.
 */

Class extends _GoogleBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Object} $inParameters - `_GoogleBaseList` parameters object
 */
    
    Super($inProvider; $inParameters)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get files() : Collection
/**
 * @function get files
 * @returns {Collection} Current page of raw Google Drive file objects
 */
    
    return This._internals._list