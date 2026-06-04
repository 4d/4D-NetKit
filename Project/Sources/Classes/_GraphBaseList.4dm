/**
 * @class _GraphBaseList
 * @description Base class for pageable Microsoft Graph API list responses.
 *   Extends `_BaseList` with Graph-specific behaviour: fetches the first page
 *   on construction, follows `@odata.nextLink` for pagination, and exposes
 *   `isLastPage`, `success`, and `statusText` properties.
 */

Class extends _BaseList

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Text} $inURL - Initial Graph API URL for the first page
 * @param {Object} $inHeaders - Additional HTTP headers (e.g. `ConsistencyLevel`)
 */
Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider)
	
	This._internals._headers:=$inHeaders
	This._internals._history:=[$inURL]
	This._internals._nextToken:=""
	
	Try
		This._getList($inURL)
	Catch
		// Errors are already in _errorStack via _throwError
		This._handleListError()
	End try
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
/**
 * @function _getList
 * @private
 * @param {Text} $inURL - Graph API URL to fetch
 * @returns {Boolean} `True` when the page was fetched successfully; `False` on error
 * @description Fetches one page of results, pushes cleaned objects into `_internals._list`,
 *   and sets `_internals._nextToken` to the `@odata.nextLink` URL when available.
 *   Also handles `@odata.count` to detect last page.
 */
Function _getList($inURL : Text) : Boolean
	
	This.isLastPage:=False
	This.success:=False
	This._internals._nextToken:=""
	This._internals._list:=[]
	
	var $response : Object
	Try
		$response:=Super._sendRequestAndWaitResponse("GET"; $inURL; This._internals._headers)
	Catch
		// Errors are already in _errorStack via _throwError
		This.statusText:=Super._getStatusLine()
		This._handleListError()
		return False
	End try
	
	This.statusText:=Super._getStatusLine()
	
	If ($response#Null)
		
		var $result : Collection:=($response["value"]#Null) ? $response["value"] : []
		var $object : Object
		For each ($object; $result)
			This._internals._list.push(cs._Tools.me.cleanGraphObject($object))
		End for each 
		This.success:=True
		var $nextLink : Text:=String($response["@odata.nextLink"])
		var $count : Integer:=Num($response["@odata.count"])
		If ((Length($nextLink)>0) && (This._internals._list.length=$count))
			$nextLink:=""
		End if 
		This._internals._nextToken:=$nextLink
		This.isLastPage:=(Length(This._internals._nextToken)=0)
		return True
	Else 
		This._handleListError()
		return False
	End if 
