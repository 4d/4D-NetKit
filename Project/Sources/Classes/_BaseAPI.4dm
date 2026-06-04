/**
 * @class _BaseAPI
 * @extends _BaseClass
 * @description Base class for NetKit API clients; manages an OAuth2 provider,
 *   handles token retrieval, and sends authenticated HTTP requests
 */

Class extends _BaseClass


/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used to obtain access tokens
 */
Class constructor($inProvider : cs.OAuth2Provider)
	
	Super()
	
	This._internals._URL:=""
	This._internals._statusLine:=""
	This._internals._oAuth2Provider:=Null
	If (OB Class($inProvider)=cs.OAuth2Provider)
		This._internals._oAuth2Provider:=$inProvider
	Else 
		This._throwError(14; {which: "\"$inProvider\""; function: "\"_BaseAPI:constructor\""; type: "\"cs.OAuth2Provider\""})
	End if 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
/**
 * @function _getToken
 * @private
 * @returns {Object} OAuth2 token object
 * @description Refreshes the token if needed via the OAuth2 provider, then returns it;
 *   propagates provider errors into the error stack and re-throws them
 */
Function _getToken() : Object
	
	Try
		If (OB Class(This._internals._oAuth2Provider)=cs.OAuth2Provider)
			This._internals._oAuth2Provider.getToken()
		End if 
		
		return This._internals._oAuth2Provider.token
	Catch
		// Propagate the OAuth2 error into _BaseAPI's error stack
		var $caughtErrors : Collection:=Last errors
		If ($caughtErrors.length>0)
			var $err : Object
			For each ($err; $caughtErrors)
				This._internals._errorStack.push($err)
			End for each 
			
			// Re-throw the first error
			var $firstError : Object:=OB Copy($caughtErrors.first())
			OB REMOVE($firstError; "deferred")
			throw($firstError)
		End if 
		
		// Defensive fallback when Last errors is unexpectedly empty
		This._throwError(13; {function: "_BaseAPI._getToken"; message: "Unknown error while retrieving OAuth2 token"})
	End try
	
	return Null
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _getAccessToken
 * @private
 * @returns {Text} The access_token string from the current OAuth2 token
 * @description Calls _getToken() and extracts the access_token value;
 *   propagates errors and returns "" on failure
 */
Function _getAccessToken() : Text
	
	Try
		return String(This._getToken().access_token)
	Catch
		// Propagate the OAuth2 error into _BaseAPI's error stack
		var $caughtErrors : Collection:=Last errors
		If ($caughtErrors.length>0)
			var $err : Object
			For each ($err; $caughtErrors)
				This._internals._errorStack.push($err)
			End for each 
			
			// Re-throw the first error
			var $firstError : Object:=OB Copy($caughtErrors.first())
			OB REMOVE($firstError; "deferred")
			throw($firstError)
		End if 
		
		// Defensive fallback when Last errors is unexpectedly empty
		This._throwError(13; {function: "_BaseAPI._getAccessToken"; message: "Unknown error while retrieving OAuth2 access token"})
	End try
	
	return ""
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _getAccessTokenType
 * @private
 * @returns {Text} The token type (e.g. "Bearer"); defaults to "Bearer" if not present in the token
 */
Function _getAccessTokenType() : Text
	
	var $tokenType : Text
	
	Try
		var $token : Object:=This._getToken()
	Catch
		// Propagate the OAuth2 error into _BaseAPI's error stack
		var $caughtErrors : Collection:=Last errors
		If ($caughtErrors.length>0)
			var $err : Object
			For each ($err; $caughtErrors)
				This._internals._errorStack.push($err)
			End for each 
		End if 
		
		// Re-throw the first error
		var $firstError : Object:=OB Copy($caughtErrors.first())
		OB REMOVE($firstError; "deferred")
		throw($firstError)
	End try
	
	Case of 
		: (Value type($token.token_type)=Is text)
			$tokenType:=String($token.token_type)
			
		: (Value type($token.type)=Is text)
			$tokenType:=String($token.type)
			
		Else 
			$tokenType:="Bearer"
			
	End case 
	
	return $tokenType
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _sendRequestAndWaitResponse
 * @private
 * @param {Text} $inMethod - HTTP method (GET, POST, PATCH, DELETE, …)
 * @param {Text} $inURL - Full request URL
 * @param {Object} $inHeaders - Additional HTTP headers to merge (may be Null)
 * @param {Variant} $inBody - Request body (Text, Object, Blob, or Null)
 * @returns {Variant} Parsed response: Object (JSON), Text, 4D.Blob, multipart Text, or Null
 * @description Sends an authenticated HTTP request with the OAuth2 Bearer token and waits
 *   for the response; parses the body according to Content-Type; throws on non-2xx status
 */
Function _sendRequestAndWaitResponse($inMethod : Text; $inURL : Text; $inHeaders : Object; $inBody : Variant) : Variant
	
	var $response : Variant:=Null
	
	Try
		var $options : Object:={headers: {}}
		var $token : Text:=This._getAccessToken()
		
		If (($inHeaders#Null) && (Value type($inHeaders)=Is object))
			$options.headers:=OB Copy($inHeaders)
		End if 
		If (Length(String($token))>0)
			$options.headers["Authorization"]:=This._getAccessTokenType()+" "+$token
		End if 
		If (Length(String($inMethod))>0)
			$options.method:=Uppercase($inMethod)
		End if 
		Case of 
			: ((Value type($inBody)=Is text) || (Value type($inBody)=Is object))
				$options.body:=$inBody
				$options.dataType:=(Value type($inBody)=Is text) ? "text" : "object"
			Else 
				$options.body:=$inBody
				$options.dataType:="auto"
		End case 
		
		var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new($inURL; $options).wait())
		var $status : Integer:=Num($request["response"]["status"])
		var $statusText : Text:=String($request["response"]["statusText"])
		This._internals._statusLine:=String($status)+" "+$statusText
		
		If (Int($status/100)=2)  // 200 OK, 201 Created, 202 Accepted... are valid status codes
			
			var $contentType : Text:=String($request["response"]["headers"]["content-type"])
			var $charset : Text:=cs._Tools.me.getHeaderValueParameter($contentType; "charset"; "UTF-8")
			
			If (OB Is defined($request.response; "body"))
				var $text : Text
				Case of 
					: (Value type($request["response"]["body"])=Is object)
						$response:=$request["response"]["body"]
						
					: (($contentType="application/json@") || ($contentType="text/plain@"))
						If (Value type($request["response"]["body"])=Is text)
							$text:=$request["response"]["body"]
						Else 
							$text:=Try(Convert to text($request["response"]["body"]; $charset))
						End if 
						If ($contentType="application/json@")
							$response:=Try(JSON Parse($text))
						Else 
							$response:=$text
						End if 
						
					: ((OB Is defined($request.response; "body") && (Value type($request["response"]["body"])=Is BLOB)))
						$response:=4D.Blob.new($request["response"]["body"])
						
					: ($contentType="multipart/@")
						var $headers : Text:="HTTP/1.1 "+This._internals._statusLine+"\r\n"
						var $keys : Collection:=OB Keys($request.response.headers)
						var $key : Text
						For each ($key; $keys)
							$headers+=$key+": "+$request.response.headers[$key]+"\r\n"
						End for each 
						$headers+="\r\n"
						If (Value type($request["response"]["body"])=Is text)
							$text:=$request["response"]["body"]
						Else 
							$text:=Try(Convert to text($request["response"]["body"]; $charset))
						End if 
						$response:=$headers+$text
						
				End case 
				
			Else 
				
				$response:=Null
			End if 
			
		Else 
			
			var $message : Text
			
			Case of 
				: (Value type($request["response"]["body"])=Is text)
					$message:=$request["response"]["body"]
					
				: (Value type($request["response"]["body"])=Is object)
					$message:=Try(JSON Stringify($request["response"]["body"]))
					
				Else 
					$message:=Try(Convert to text($request["response"]["body"]; "UTF-8"))
					
			End case 
			
			This._throwError(8; {status: $status; explanation: $statusText; message: $message})
			$response:=Null
			
		End if 
	Catch
		// Re-throw so the error propagates to the caller
		var $caughtErrors : Collection:=Last errors
		If ($caughtErrors.length>0)
			var $firstError : Object:=OB Copy($caughtErrors.first())
			OB REMOVE($firstError; "deferred")  // Force immediate (non-deferred) throw
			throw($firstError)
		End if 
	End try
	
	return $response
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _getURL
 * @private
 * @returns {Text} The base URL stored in the internals
 */
Function _getURL() : Text
	
	return This._internals._URL
	
	
	// ----------------------------------------------------
	
	
/**
 * @function _getOAuth2Provider
 * @private
 * @returns {cs.OAuth2Provider} The OAuth2 provider associated with this API client
 */
Function _getOAuth2Provider() : cs.OAuth2Provider
	
	return This._internals._oAuth2Provider
