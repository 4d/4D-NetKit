/**
 * @class Office365Category
 * @description Microsoft Graph API client for managing Outlook master categories.
 *   Wraps the `/outlook/masterCategories` endpoint.
 */

Class extends _GraphAPI

property userId : Text:=""

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `userId` {Text} — Graph user ID or UPN; defaults to `""` (uses `me` endpoint)
 */
	
	Super($inProvider)
	This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function list : cs.GraphCategoryList
/**
 * @function list
 * @returns {cs.GraphCategoryList} Pageable list of the user's Outlook master categories
 * @description Fetches all master categories via:
 *   `GET /me/outlook/masterCategories` or
 *   `GET /users/{id}/outlook/masterCategories`
 */
	
/*
        GET /me/outlook/masterCategories
        GET /users/{id|userPrincipalName}/outlook/masterCategories
*/
	Super._clearErrorStack()
	
	var $result : cs.GraphCategoryList
	
	Try
		var $headers : Object:={}
		var $urlParams : Text:=""
		
		If (Length(String(This.userId))>0)
			$urlParams:="users/"+This.userId
		Else 
			$urlParams:="me"
		End if 
		$urlParams+="/outlook/masterCategories"
		
		var $URL : Text:=This._getURL()+$urlParams
		$result:=cs.GraphCategoryList.new(This._getOAuth2Provider(); $URL; $headers)
	Catch
		// Errors are already in _errorStack via _throwError
	End try
	
	return $result
