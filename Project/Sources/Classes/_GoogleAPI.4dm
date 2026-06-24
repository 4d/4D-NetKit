/**
 * @class _GoogleAPI
 * @extends _BaseAPI
 * @description Base class for Google API clients; initialises the base URL used by all
 *   Google service subclasses (Gmail, Calendar, …) and provides shared URL-parameter
 *   building and mail-object conversion helpers.
 */

Class extends _BaseAPI

Class constructor($inProvider : cs.OAuth2Provider; $inBaseURL : Text)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Text} $inBaseURL - Base URL for the Google API endpoint;
 *   defaults to `"https://gmail.googleapis.com/gmail/v1/"` when empty
 */
	
	Super($inProvider)
	
	This._internals._URL:=(Length(String($inBaseURL))>0) ? $inBaseURL : "https://gmail.googleapis.com/gmail/v1/"
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
/**
 * @function _getURLParamsFromObject
 * @private
 * @param {Object} $inParameters - Filter/pagination options; recognised properties:
 *   - `search` {Text} — Gmail search query (`q` parameter)
 *   - `top` {Integer} — Maximum number of results (`maxResults`)
 *   - `includeSpamTrash` {Boolean} — Whether to include Spam and Trash in results
 *   - `labelIds` {Collection} — Array of label IDs to filter by (repeated param)
 *   - `format` {Text} — Message format: `"raw"` (default), `"minimal"`, or `"metadata"`
 *   - `headers` {Collection} — Metadata headers to return (only when `format="metadata"`)
 * @returns {Text} URL query string (including leading `?` when non-empty)
 * @description Builds the query string appended to Gmail list/get requests from a
 *   structured options object; invalid `format` values are normalised to `"raw"`
 */
	
	var $URLParams : cs._URL:=cs._URL.new()
	
	If (Length(String($inParameters.search))>0)
		$URLParams.addQueryParameter("q"; cs._Tools.me.urlEncode($inParameters.search))
	End if 
	If (Value type($inParameters.top)#Is undefined)
		$URLParams.addQueryParameter("maxResults"; String($inParameters.top))
	End if 
	If (Value type($inParameters.includeSpamTrash)=Is boolean)
		$URLParams.addQueryParameter("includeSpamTrash"; ($inParameters.includeSpamTrash ? "true" : "false"))
	End if 
	If (Value type($inParameters.labelIds)=Is collection)
		var $labelId : Text
		For each ($labelId; $inParameters.labelIds)
			If (Length($labelId)>0)
				$URLParams.addQueryParameter("labelIds"; $labelId)
			End if 
		End for each 
	End if 
	If (Length(String($inParameters.format))>0)
		var $format : Text:=String($inParameters.format)
		$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
		If (($format="metadata") && (Value type($inParameters.headers)=Is collection))
			var $header : Text
			For each ($header; $inParameters.headers)
				If (Length($header)>0)
					$URLParams.addQueryParameter("metadataHeaders"; $header)
				End if 
			End for each 
		End if 
		$URLParams.addQueryParameter("format"; $format)
	End if 
	
	return $URLParams.toString()
	
	
	// ----------------------------------------------------
	
	
Function _convertMailObjectToJMAP($inMail : Object) : Object
/**
 * @function _convertMailObjectToJMAP
 * @private
 * @param {Object} $inMail - Raw Gmail message object returned by the API
 *   (minimal or metadata format)
 * @returns {Object} JMAP-shaped mail object with standard property names
 * @description Converts a Gmail API message object to a JMAP-compatible shape by mapping
 *   Gmail field names through `_Tools.getJMAPAttribute`; processes top-level fields as well
 *   as `payload.headers`, handling email-address headers via `_EmailAddress` and keyword
 *   arrays (labelIds / Keywords) as JMAP keyword maps (`{keyword: true, …}`)
 */
	
	var $result : Object:={}
	var $keys : Collection:=OB Keys($inMail)
	var $key; $name; $string : Text
	var $email : cs._EmailAddress
	
	For each ($key; $keys)
		$name:=cs._Tools.me.getJMAPAttribute($key)
		If (Length($name)>0)
			If ($key="labelIds")
				If (Num($inMail.labelIds.length)>0)
					$string:=$inMail.labelIds.join("=true,"; ck ignore null or empty)+"=true"
					$result[$name]:=Split string($string; ","; sk trim spaces)
				End if 
			Else 
				$result[$name]:=$inMail[$key]
			End if 
		End if 
	End for each 
	
	If (OB Is defined($inMail; "payload"))
		$keys:=OB Keys($inMail.payload)
		For each ($key; $keys)
			If ($key="headers")
				var $header : Object
				For each ($header; $inMail.payload.headers)
					$name:=cs._Tools.me.getJMAPAttribute($header.name)
					If (Length($name)>0)
						Case of 
							: ($header.name="Keywords")
								If (Length($header.value)>0)
									$string:=$header.value.join("=true,"; ck ignore null or empty)+"=true"
									$result[$name]:=Split string($string; ","; sk trim spaces)
								End if 
							: (cs._Tools.me.isEmailAddressHeader($header.name))
								If (Length($header.value)>0)
									$email:=cs._EmailAddress.new($header.value)
									$result[$name]:=$email
								End if 
							Else 
								$result[$name]:=$header.value
						End case 
					End if 
				End for each 
			End if 
		End for each 
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function _extractRawMessage($result : Object; $format : Text; $mailType : Text) : Variant
/**
 * @function _extractRawMessage
 * @private
 * @param {Object} $result - Raw Gmail API response object
 * @param {Text} $format - Requested format: `"raw"`, `"minimal"`, or `"metadata"`
 * @param {Text} $mailType - Output type when format is `"raw"`: `"JMAP"` (4D mail object),
 *   `"MIME"` (4D.Blob of raw MIME bytes), or any other value to trigger an error
 * @returns {Variant} Converted message — a 4D mail object, a `4D.Blob`, a JMAP-shaped
 *   object, or `Null` on error
 * @description Dispatches message extraction based on `$format` and `$mailType`:
 *   - `raw` + `JMAP`: base64url-decodes the raw MIME, converts via `MAIL Convert from MIME`,
 *     then re-attaches `id`, `threadId`, and `labelIds` from the original response
 *   - `raw` + `MIME`: base64url-decodes to a `4D.Blob`
 *   - `minimal` / `metadata`: delegates to `_convertMailObjectToJMAP`
 *   - any other `$format` value: pushes error 10 (unreachable in practice because
 *     `_getURLParamsFromObject` normalises the format before the request)
 */
	
	var $response : Variant:=Null
	
	If ($result#Null)
		
		Case of 
			: (($format="raw") && (($mailType="MIME") || ($mailType="JMAP")))
				If (Value type($result.raw)=Is text)
					
					var $rawMessage : Text:=cs._Tools.me.base64UrlSafeDecode($result.raw)
					If ($mailType="JMAP")
						
						var $copy : Object:=$result
						$response:=MAIL Convert from MIME($rawMessage)
						$response.id:=String($copy.id)
						$response.threadId:=String($copy.threadId)
						$response.labelIds:=OB Is defined($copy; "labelIds") ? $copy.labelIds : []
					Else 
						
						var $blob : Blob
						CONVERT FROM TEXT((Length($rawMessage)>0) ? $rawMessage : $result.raw; "UTF-8"; $blob)
						$response:=4D.Blob.new($blob)
					End if 
				End if 
				
			: (($format="minimal") || ($format="metadata"))
				$response:=This._convertMailObjectToJMAP($result)
				
			Else 
				Super._throwError(10; {which: "\"format\""; function: "extractRawMessage"})
				
		End case 
		
	End if 
	
	return $response
