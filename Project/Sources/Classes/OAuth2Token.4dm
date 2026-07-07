/**
 * @class OAuth2Token
 * @description Wraps an OAuth2 access token and its expiration timestamp.
 *   Built from a parameter object; raw JSON and URL-encoded responses are
 *   handled through dedicated private loader methods.
 */

property token : Object
property tokenExpiration : Text

Class constructor($inParams : Object)
/**
 * @constructor
 * @param {Object} $inParams - Optional initial token data:
 *   - `token` {Object} — Token object (e.g. `{access_token; refresh_token; expires_in}`)
 *   - `tokenExpiration` {Text} — ISO 8601 expiration timestamp; computed from `expires_in`
 *     when absent
 */
	
	var $params : Object:=Null
	If (Count parameters>0)
		If ((Type($inParams)=Is object) && (Not(OB Is empty($inParams))))
			$params:=$inParams
		End if 
	End if 
	
	If ($params#Null)
		
		This._loadFromObject($params)
		
	End if 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _loadFromObject($inObject : Object)
/**
 * @function _loadFromObject
 * @private
 * @param {Object} $inObject - Object with `token` and optional `tokenExpiration`
 * @description Hydrates `This.token` and `This.tokenExpiration` from a plain object;
 *   computes `tokenExpiration` from `token.expires_in` when not provided
 */
	
	If (($inObject#Null) && (Not(OB Is empty($inObject))))
		
		If (OB Get type($inObject; "token")=Is object)
			This.token:=OB Copy($inObject.token)
		Else 
			This.token:={}
		End if 
		
		If (OB Is defined($inObject; "tokenExpiration") && ($inObject.tokenExpiration#Null))
			This.tokenExpiration:=$inObject.tokenExpiration
		Else 
			var $expiresInDelta : Integer:=Num($inObject.token.expires_in)
			If ($expiresInDelta<0)
				$expiresInDelta:=0
			End if 
			var $expires_in : Integer:=(Current time+0)+$expiresInDelta
			var $expirationDate : Date:=Current date
			var $secondsInDay : Integer:=(24*60*60)
			
			// Keep date/time coherent when expires_in pushes the time into next day(s)
			While ($expires_in>=$secondsInDay)
				$expires_in:=$expires_in-$secondsInDay
				$expirationDate:=$expirationDate+1
			End while 
			
			This.tokenExpiration:=String($expirationDate; ISO date; Time($expires_in))
		End if 
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromResponse($inResponseString : Text)
/**
 * @function _loadFromResponse
 * @private
 * @param {Text} $inResponseString - Raw JSON response body from the token endpoint
 * @description Parses the JSON string and delegates to `_loadFromObject`
 */
	
	var $token : Object:=Try(JSON Parse($inResponseString))
	
	If (($token#Null) && (Not(OB Is empty($token))))
		This._loadFromObject({token: $token})
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _loadFromURLEncodedResponse($inResponseString : Text)
/**
 * @function _loadFromURLEncodedResponse
 * @private
 * @param {Text} $inResponseString - URL-encoded response body (e.g. `token=foo&expires_in=3600`)
 * @description Parses a `application/x-www-form-urlencoded` response and delegates
 *   to `_loadFromObject`
 */
	
	var $URL : cs._URL:=cs._URL.new()
	$URL.parseQuery($inResponseString)
	var $token : Object:={}
	var $iter : Object
	
	For each ($iter; $URL.queryParams)
		$token[$iter.name]:=$iter.value
	End for each 
	
	If (Not(OB Is empty($token)))
		This._loadFromObject({token: $token})
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _normalizeExpirationString($inExpiration : Text) : Text
/**
 * @function _normalizeExpirationString
 * @private
 * @param {Text} $inExpiration - Expiration text to normalize
 * @returns {Text} ISO-like `YYYY-MM-DDTHH:MM:SS` when possible; empty text otherwise
 * @description Trims whitespace and removes common trailing timezone/fraction parts
 *   so `Date()` / `Time()` comparisons stay deterministic
 */
	
	var $result : Text:=Trim($inExpiration)
	
	If ((Length($result)>19) && (Position("T"; $result)=11))
		$result:=Substring($result; 1; 19)
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function _Expired($inParams : Text) : Boolean
/**
 * @function _Expired
 * @private
 * @param {Text} $inParams - Optional ISO 8601 expiration string to test;
 *   uses `This.tokenExpiration` when omitted
 * @returns {Boolean} `True` when the token is expired (or expiration is unknown);
 *   `False` when the token is still valid (with a 10-second safety margin)
 */
	
	var $result : Boolean:=True
	var $expiration : Text:=This._normalizeExpirationString(Choose((Count parameters>0); $inParams; This.tokenExpiration))
	
	If (Length($expiration)>0)
		Case of 
			: (Current date<Date($expiration))
				$result:=False
			: ((Current date=Date($expiration)) && \
				((Current time+0)<(Time($expiration)-10)))
				$result:=False
		End case 
	End if 
	
	return $result
