/**
 * @class GraphDriveItemList
 * @description Pageable list of Microsoft Graph Drive items returned by a Graph API query.
 *   The `items` getter returns the list as a `Collection` of `GraphDriveItem` objects.
 */

Class extends _GraphBaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object; $inDrivePath : Text)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Text} $inURL - Initial Graph API URL
 * @param {Object} $inHeaders - Additional HTTP headers
 * @param {Text} $inDrivePath - Drive path prefix (e.g. "me/drive")
 */
   
   Super($inProvider; $inURL; $inHeaders)
   This._internals._drivePath:=$inDrivePath
   
   
   // Mark: - [Public]
   // ----------------------------------------------------
   
   
Function get items() : Collection
/**
 * @function get items
 * @returns {Collection} The current page of GraphDriveItem objects
 */
   
   var $result : Collection:=[]
   var $provider : cs.OAuth2Provider:=This._getOAuth2Provider()
   var $drivePath : Text:=This._internals._drivePath
   var $obj : Object
   For each ($obj; This._internals._list)
      $result.push(cs.GraphDriveItem.new($provider; $drivePath; cs._Tools.me.cleanGraphObject($obj)))
   End for each 
   return $result
