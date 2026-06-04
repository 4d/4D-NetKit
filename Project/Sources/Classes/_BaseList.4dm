/**
 * @class _BaseList
 * @extends _BaseAPI
 * @description Base class for paginated NetKit list resources; provides next/previous
 *   page navigation using server-issued page tokens
 */

Class extends _BaseAPI

property page : Integer
property isLastPage : Boolean
property statusText : Text
property success : Boolean
property errors : Collection


Class constructor($inProvider : cs.OAuth2Provider)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider passed through to _BaseAPI
 */
	
	Super($inProvider)
	
	This.page:=1
	This.isLastPage:=False
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inToken : Text) : Boolean
/**
 * @function _getList
 * @private
 * @param {Text} $inToken - Page token for the page to fetch
 * @returns {Boolean} True on success; overridden by subclasses to perform the actual API call
 */
	
	return False
	
	
	// ----------------------------------------------------
	
	
Function _handleListError()
/**
 * @function _handleListError
 * @private
 * @description Copies the error stack into the public errors property and sets statusText
 *   from the first error message
 */
	
	var $errorStack : Collection:=Super._getErrorStack()
	
	If ($errorStack.length>0)
		This.errors:=$errorStack
		This.statusText:=$errorStack.first().message
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function next() : Boolean
/**
 * @function next
 * @returns {Boolean} True if the next page was fetched successfully, False if there is no next page
 * @description Fetches the next page using the server-issued next page token;
 *   increments page and appends the token to the navigation history on success
 */
	
	var $nextToken : Text:=String(This._internals._nextToken)
	
	If (Length($nextToken)>0)
		
		var $bIsOK : Boolean:=This._getList($nextToken)
		
		If ($bIsOK)
			This._internals._history.push($nextToken)
			This.page+=1
		End if 
		
		This._internals._update:=$bIsOK
		return $bIsOK
		
	Else 
		
		This.statusText:=Localized string("List_No_Next_Page")
		This.isLastPage:=True
		This._internals._update:=False
		return False
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
/**
 * @function previous
 * @returns {Boolean} True if the previous page was fetched successfully, False if already on the first page
 * @description Navigates back one page using the token history;
 *   decrements page and trims the history on success
 */
	
	If ((Num(This._internals._history.length)>0) && (This.page>1))
		
		var $index : Integer:=This.page-1
		var $token : Text:=String(This._internals._history[$index-1])
		var $bIsOK : Boolean:=This._getList($token)
		
		If ($bIsOK)
			This.page-=1
			This._internals._history.resize(This.page)
		End if 
		
		This._internals._update:=$bIsOK
		return $bIsOK
		
	Else 
		
		This.statusText:=Localized string("List_No_Previous_Page")
		This.isLastPage:=True
		This._internals._update:=False
		return False
		
	End if 
