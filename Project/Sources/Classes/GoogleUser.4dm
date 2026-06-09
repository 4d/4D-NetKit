/**
 * @class GoogleUser
 * @extends _GoogleAPI
 * @description Google People API client; provides read access to user profiles
 *   (names, email addresses, and other person fields) via the
 *   `people.get`, `people.getBatchGet`, and `people.listDirectoryPeople` endpoints.
 */

Class extends _GoogleAPI

Class constructor($inProvider : cs.OAuth2Provider)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @description Initialises the client with the People API base URL
 *   (`https://people.googleapis.com/v1/`) and sets the default person fields
 *   to `["names", "emailAddresses"]`
 */
	
	Super($inProvider; "https://people.googleapis.com/v1/")
	
	This._internals.defaultPersonFields:=["names"; "emailAddresses"]
	
	
	// ----------------------------------------------------
	// Mark: - [Private]


Function _get($inResourceName : Text; $inPersonFields : Variant) : Object
/**
 * @function _get
 * @private
 * @param {Text} $inResourceName - Person resource name (e.g. `"me"` or `"people/c123456"`);
 *   the `"people/"` prefix is added automatically if absent
 * @param {Variant} $inPersonFields - Fields to return: a Collection, a comma-separated Text,
 *   or omitted/empty to use `defaultPersonFields`
 * @returns {Object} Raw People API person resource object, or `Null` on error
 * @description Fires a GET request to `{baseURL}/{resourceName}?personFields=...`
 *   and returns the parsed JSON response; clears the error stack before each call
 */
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	var $resourceName : Text:=Length(String($inResourceName))>0 ? $inResourceName : ""
	var $personFields : Text
	
	If (Position("people/"; $resourceName)=0)
		$resourceName:="people/"+$resourceName
	End if 
	
	Case of 
		: ((Value type($inPersonFields)=Is collection) && ($inPersonFields.length>0))
			$personFields:=$inPersonFields.join(","; ck ignore null or empty)
		: ((Value type($inPersonFields)=Is text) && (Length(String($inPersonFields))>0))
			$personFields:=$inPersonFields
		Else 
			$personFields:=This._internals.defaultPersonFields.join(","; ck ignore null or empty)
	End case 
	
	$URL+=$resourceName+"?personFields="+$personFields
	
	var $headers : Object:={Accept: "application/json"}
	var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
/**
 * @function _getURLParamsFromObject
 * @private
 * @param {Object} $inParameters - Query options; recognised properties:
 *   - `select` {Text|Collection} — Person fields to return (`readMask`); defaults to
 *     `defaultPersonFields` (`["names","emailAddresses"]`) when omitted
 *   - `sources` {Text|Collection} — Directory source types to include; defaults to
 *     `["DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE"]` when omitted
 *   - `mergeSources` {Text|Collection} — Optional merge source types
 *   - `top` {Integer} — Maximum number of results per page (`pageSize`)
 *   - `pageToken` {Text} — Page token for pagination
 * @returns {Text} URL query string (including leading `?` when non-empty)
 * @description Overrides `_GoogleAPI._getURLParamsFromObject` with People-API–specific
 *   parameters; builds the query string for `listDirectoryPeople` requests
 */
	
	var $urlParams : cs._URL:=cs._URL.new()
	var $personFields : Text
	var $sources : Collection:=Null
	var $mergeSources : Collection:=Null
	
	Case of 
		: ((Value type($inParameters.select)=Is collection) && ($inParameters.select.length>0))
			$personFields:=$inParameters.select.join(","; ck ignore null or empty)
		: ((Value type($inParameters.select)=Is text) && (Length(String($inParameters.select))>0))
			$personFields:=$inParameters.select
		Else 
			$personFields:=This._internals.defaultPersonFields.join(","; ck ignore null or empty)
	End case 
	$urlParams.addQueryParameter("readMask"; $personFields)
	
	Case of 
		: ((Value type($inParameters.sources)=Is collection) && ($inParameters.sources.length>0))
			$sources:=$inParameters.sources
		: ((Value type($inParameters.sources)=Is text) && (Length(String($inParameters.sources))>0))
			$sources:=Split string($inParameters.sources; ","; sk ignore empty strings+sk trim spaces)
		Else 
			$sources:=["DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE"]
	End case 
	If (($sources#Null) && ($sources.length>0))
		var $source : Text
		For each ($source; $sources)
			If (Length($source)>0)
				$urlParams.addQueryParameter("sources"; $source)
			End if 
		End for each 
	End if 
	
	Case of 
		: ((Value type($inParameters.mergeSources)=Is collection) && ($inParameters.mergeSources.length>0))
			$mergeSources:=$inParameters.mergeSources
		: ((Value type($inParameters.mergeSources)=Is text) && (Length(String($inParameters.mergeSources))>0))
			$mergeSources:=Split string($inParameters.mergeSources; ","; sk ignore empty strings+sk trim spaces)
	End case 
	If (($mergeSources#Null) && ($mergeSources.length>0))
		var $mergeSource : Text
		For each ($mergeSource; $mergeSources)
			If (Length($mergeSource)>0)
				$urlParams.addQueryParameter("mergeSources"; $mergeSource)
			End if 
		End for each 
	End if 
	
	If (OB Is defined($inParameters; "top") && (Num($inParameters.top)>0))
		$urlParams.addQueryParameter("pageSize"; String($inParameters.top))
	End if 
	
	If (OB Is defined($inParameters; "pageToken") && (Value type($inParameters.pageToken)=Is text) && (Length(String($inParameters.pageToken))>0))
		$urlParams.addQueryParameter("pageToken"; String($inParameters.pageToken))
	End if 
	
	return $urlParams.toString()
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------


Function getCurrent($inPersonFields : Variant) : Object
/**
 * @function getCurrent
 * @param {Variant} $inPersonFields - Fields to return (Collection, comma-separated Text,
 *   or omitted to use `defaultPersonFields`)
 * @returns {Object} People API person resource for the authenticated user
 * @description Fetches the profile of the currently authenticated user
 *   by calling `_get("me", $inPersonFields)`
 */
	
	return This._get("me"; $inPersonFields)
	
	
	// ----------------------------------------------------
	
	
Function get($inResourceName : Text; $inPersonFields : Variant) : Object
/**
 * @function get
 * @param {Text} $inResourceName - Person resource name (e.g. `"people/c123456"`)
 * @param {Variant} $inPersonFields - Fields to return (Collection, comma-separated Text,
 *   or omitted to use `defaultPersonFields`)
 * @returns {Object} People API person resource object, or `Null` on error
 * @description Fetches a single user profile by resource name
 */
	
	return This._get($inResourceName; $inPersonFields)
	
	
	// ----------------------------------------------------
	
	
Function list($inParameters : Object) : cs.GoogleUserList
/**
 * @function list
 * @param {Object} $inParameters - Query options forwarded to `_getURLParamsFromObject`
 *   (`select`, `sources`, `mergeSources`, `top`, `pageToken`)
 * @returns {cs.GoogleUserList} Paginated list of directory people
 * @description Builds the `people:listDirectoryPeople` URL and returns a
 *   `GoogleUserList` instance for the first page; use `next()` / `previous()`
 *   on the returned object to navigate subsequent pages
 */
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()+"people:listDirectoryPeople"+This._getURLParamsFromObject($inParameters)
	var $headers : Object:={Accept: "application/json"}
	
	return cs.GoogleUserList.new(This._getOAuth2Provider(); $URL; $headers)
