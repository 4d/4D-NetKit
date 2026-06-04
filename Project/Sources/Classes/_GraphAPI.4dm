/**
 * @class _GraphAPI
 * @description Base class for all Microsoft Graph API clients.
 *   Sets the base URL to `https://graph.microsoft.com/v1.0/`, provides helpers for
 *   building OData query strings, copying Graph message objects, and loading JSON
 *   responses into `This` properties.
 */

Class extends _BaseAPI

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 */
Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	This._internals._URL:="https://graph.microsoft.com/v1.0/"
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
/**
 * @function _copyGraphMessage
 * @private
 * @param {Object} $inMessage - A `GraphMessage` instance or a plain message object
 * @returns {Object} A plain object copy of `$inMessage` suitable for a Graph API request;
 *   strips `_internals`, `@`-prefixed, and `webLink` keys; converts `attachments`
 *   entries via `_Tools.convertToGraphAttachment`
 * @description Creates a serialisable copy of a Graph message object,
 *   converting any typed attachment objects to plain Graph attachment objects.
 *   If `$inMessage` is not a `GraphMessage` instance it is returned as-is.
 */
Function _copyGraphMessage($inMessage : Object) : Object
	
	If (OB Instance of($inMessage; cs.GraphMessage))
		
		var $result : Object:={}
		var $message : Object:=OB Copy($inMessage)
		If (OB Is defined($message; "attachments") && ($message.attachments#Null))
			$result.attachments:=[]
		End if 
		var $key : Text
		var $keys : Collection:=OB Keys($message)
		For each ($key; $keys)
			
			Case of 
				: (($key="_internals") || (Position("@"; $key)=1) || ($key="webLink"))
					// do not copy
					
				: ($key="attachments")
					var $iter : Object
					For each ($iter; $message.attachments)
						var $attachment : Object:=cs._Tools.me.convertToGraphAttachment($iter)
						$result.attachments.push($attachment)
					End for each 
					
				Else 
					$result[$key]:=$message[$key]
					
			End case 
			
		End for each 
		
		return $result
		
	Else 
		
		return $inMessage
	End if 
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _loadFromObject
 * @private
 * @param {Object} $inObject - JSON response object from the Graph API
 * @description Copies every key-value pair from `$inObject` onto `This`,
 *   effectively hydrating the current instance with the API response data.
 *   No-op when `$inObject` is `Null` or empty.
 */
Function _loadFromObject($inObject : Object)
	
	If (($inObject#Null) && (Not(OB Is empty($inObject))))
		
		var $key : Text
		var $keys : Collection:=OB Keys($inObject)
		
		For each ($key; $keys)
			This[$key]:=$inObject[$key]
		End for each 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _getURLParamsFromObject
 * @private
 * @param {Object} $inParameters - OData query options:
 *   - `search` {Text} — OData `$search`
 *   - `filter` {Text} — OData `$filter`
 *   - `select` {Text|Collection} — OData `$select` (collection joined with `,`)
 *   - `top` {Text|Integer} — OData `$top`
 *   - `orderBy` {Text} — OData `$orderBy`
 *   - `includeHiddenFolders` {Boolean} — Adds `includeHiddenFolders=true` (folders only)
 * @param {Boolean} $inCount - When `True`, appends `$count=true`
 * @returns {Text} URL query string (may be empty)
 * @description Builds an OData query string from a parameter object.
 *   Overridden by `Office365Calendar` to add `startDateTime` and `endDateTime`.
 */
Function _getURLParamsFromObject($inParameters : Object; $inCount : Boolean) : Text
	
	var $URLParams : cs._URL:=cs._URL.new()
	
	If ((Value type($inParameters.search)=Is text) && (Length(String($inParameters.search))>0))
		$URLParams.addQueryParameter("$search"; $inParameters.search)
	End if 
	If ((Value type($inParameters.filter)=Is text) && (Length(String($inParameters.filter))>0))
		$URLParams.addQueryParameter("$filter"; $inParameters.filter)
	End if 
	If (Not(Value type($inParameters.select)=Is undefined))
		var $select : Text
		Case of 
			: (Value type($inParameters.select)=Is text)
				$select:=$inParameters.select
			: (Value type($inParameters.select)=Is collection)
				$select:=$inParameters.select.join(","; ck ignore null or empty)
			Else 
				$select:=String($inParameters.select)
		End case 
		If (Length($select)>0)
			$URLParams.addQueryParameter("$select"; $select)
		End if 
	End if 
	If (Not(Value type($inParameters.top)=Is undefined))
		$URLParams.addQueryParameter("$top"; Choose(Value type($inParameters.top)=Is text; $inParameters.top; String($inParameters.top)))
	End if 
	If ((Value type($inParameters.orderBy)=Is text) && (Length(String($inParameters.orderBy))>0))
		$URLParams.addQueryParameter("$orderBy"; $inParameters.orderBy)
	End if 
	
	// Specific to .getFolder / .getFolderList
	If (Bool($inParameters.includeHiddenFolders))
		$URLParams.addQueryParameter("includeHiddenFolders"; "true")
	End if 
	If (Bool($inCount))
		$URLParams.addQueryParameter("$count"; "true")
	End if 
	
	return $URLParams.toString()
