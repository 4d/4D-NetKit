/**
 * @class Office365User
 * @description Microsoft Graph API client for querying Azure AD users.
 *   Wraps the `/users` and `/me` endpoints.
 */

Class extends _GraphAPI

Class constructor($inProvider : cs.OAuth2Provider)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 */
	
	Super($inProvider)
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getUserInfo($inURL : Text) : Object
/**
 * @function _getUserInfo
 * @private
 * @param {Text} $inURL - Full Graph API URL for the user endpoint
 * @returns {Object} Cleaned user object, or `Null` on failure
 * @description Sends a `GET` request and returns a sanitised Graph user object
 */
	
	var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $inURL)
	If (Value type($response)=Is object)
		return cs._Tools.me.cleanGraphObject($response)
	End if 
	
	return Null
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getCurrent($inSelect : Text) : Object
/**
 * @function getCurrent
 * @param {Text} $inSelect - Comma-separated list of properties to return (OData `$select`)
 * @returns {Object} Current authenticated user's properties, or `Null` on failure
 * @description Fetches the currently authenticated user via `GET /me`
 */
	
	var $urlParams : Text
	
	If (Length(String($inSelect))>0)
		$urlParams:="?$select="+$inSelect
	End if 
	
	var $URL : Text:=This._getURL()+"me"+$urlParams
	
	return This._getUserInfo($URL)
	
	
	// ----------------------------------------------------
	
	
Function get($inID : Text; $inSelect : Text) : Object
/**
 * @function get
 * @param {Text} $inID - Azure AD user ID or user principal name
 * @param {Text} $inSelect - Comma-separated list of properties to return (OData `$select`)
 * @returns {Object} User properties object, or `Null` when not found or on error
 * @description Fetches a specific user via `GET /users/{id}`;
 *   throws error 9 when `$inID` is empty
 */
	
	Super._clearErrorStack()
	
	If (Length($inID)>0)
		
		var $urlParams : Text:=String($inID)
		
		If (Length(String($inSelect))>0)
			$urlParams:=$urlParams+"?$select="+$inSelect
		End if 
		
		var $URL : Text:=This._getURL()+"users/"+$urlParams
		
		return This._getUserInfo($URL)
	Else 
		Try
			This._throwError(9; {which: 1; function: "office365.user.get"})
		Catch
			// Errors are already in _errorStack via _throwError
		End try
		return Null
	End if 
	
	
	// ----------------------------------------------------
	
	
Function list($inParameters : Object) : Object
/**
 * @function list
 * @param {Object} $inParameters - Query options:
 *   - `search` {Text} — OData `$search` expression; automatically sets `ConsistencyLevel: eventual`
 *   - `filter` {Text} — OData `$filter` expression
 *   - `select` {Text} — Comma-separated property names (`$select`)
 *   - `top` {Text|Integer} — Maximum number of results per page (`$top`)
 *   - `orderBy` {Text} — Sort expression (`$orderBy`)
 * @returns {cs.GraphUserList} Pageable list of Azure AD users
 * @description Lists Azure AD users via `GET /users` with optional OData query parameters
 */
	
	var $headers : Object
	var $URL : cs._URL:=cs._URL.new(This._getURL()+"users")
	var $URLString : Text
	
	If (Length(String($inParameters.search))>0)
		$URL.addQueryParameter("$search"; $inParameters.search)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	If (Length(String($inParameters.filter))>0)
		$URL.addQueryParameter("$filter"; $inParameters.filter)
	End if 
	If (Length(String($inParameters.select))>0)
		$URL.addQueryParameter("$select"; $inParameters.select)
	End if 
	If (Not(Value type($inParameters.top)=Is undefined))
		$URL.addQueryParameter("$top"; Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
	End if 
	If (Length(String($inParameters.orderBy))>0)
		$URL.addQueryParameter("$orderBy"; $inParameters.orderBy)
	End if 
	$URLString:=$URL.toString()
	
	return cs.GraphUserList.new(This._getOAuth2Provider(); $URLString; $headers)
	
	
	// ----------------------------------------------------
	
	
Function count($inParameters : Object) : Object
/**
 * @function count
 * @param {Object} $inParameters - Query options (same as `list`); `$count=true` and
 *   `ConsistencyLevel: eventual` are added automatically:
 *   - `search` {Text} — OData `$search` expression
 *   - `filter` {Text} — OData `$filter` expression
 *   - `select` {Text} — OData `$select`
 *   - `top` {Text|Integer} — OData `$top`
 *   - `orderBy` {Text} — OData `$orderBy`
 * @returns {cs.GraphUserList} Pageable list with total count included in the response
 * @description Lists Azure AD users with `$count=true` via `GET /users`;
 *   requires `ConsistencyLevel: eventual` (set automatically)
 */
	
	var $headers : Object
	var $URL : cs._URL:=cs._URL.new(This._getURL()+"users")
	var $URLString : Text
	
	If (Length(String($inParameters.search))>0)
		$URL.addQueryParameter("$search"; $inParameters.search)
		$headers:={ConsistencyLevel: "eventual"}
	End if 
	If (Length(String($inParameters.filter))>0)
		$URL.addQueryParameter("$filter"; $inParameters.filter)
	End if 
	If (Length(String($inParameters.select))>0)
		$URL.addQueryParameter("$select"; $inParameters.select)
	End if 
	If (Not(Value type($inParameters.top)=Is undefined))
		$URL.addQueryParameter("$top"; Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
	End if 
	If (Length(String($inParameters.orderBy))>0)
		$URL.addQueryParameter("$orderBy"; $inParameters.orderBy)
	End if 
	$URL.addQueryParameter("$count"; "true")
	$headers:={ConsistencyLevel: "eventual"}
	$URLString:=$URL.toString()
	
	return cs.GraphUserList.new(This._getOAuth2Provider(); $URLString; $headers)
	
