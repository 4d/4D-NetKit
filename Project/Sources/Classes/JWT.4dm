property key : 4D.CryptoKey

Class constructor($inParam : Variant)
	
	This.key:=This._getCryptoKey($inParam)
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getCryptoKey($inKey : Variant; $inDefaultKey : 4D.CryptoKey) : 4D.CryptoKey
	
	var $key : 4D.CryptoKey
	Case of 
		: ((Value type($inKey)=Is object) && OB Instance of($inKey; 4D.CryptoKey))
			$key:=$inKey  // Use specified CryptoKey object
			
		: ((Value type($inKey)=Is text) && (Length(String($inKey))>0))
			$key:=Try(4D.CryptoKey.new({type: "PEM"; pem: $inKey}))  // Use specified PEM format Key
			
		Else 
			$key:=Null
	End case 
	
	// If no valid key provided, use default key if provided
	If (($key=Null) && ((Value type($inDefaultKey)=Is object) && (OB Instance of($inDefaultKey; 4D.CryptoKey))))
		$key:=$inDefaultKey
	End if 
	
	return $key
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function decode($inToken : Text) : Object
	
	var $header : Object:=Null
	var $payload : Object:=Null
	var signature : Text
	
	Case of 
		: ((Value type($inToken)#Is text) || (Length(String($inToken))=0))
			This._throwError(9; {which: "\"$inToken\""; function: "JWT.decode"})
			
		Else 
			var $parts : Collection:=Split string($inToken; ".")
			
			If ($parts.length>2)
				var $decodedHeader; $decodedPayload; $signature : Text
				BASE64 DECODE($parts[0]; $decodedHeader; *)
				BASE64 DECODE($parts[1]; $decodedPayload; *)
				$signature:=$parts[2]
				
				// Note: If JSON parsing fails, Try(JSON Parse(...)) will return Null for header or payload.
				$header:=Try(JSON Parse($decodedHeader))
				$payload:=Try(JSON Parse($decodedPayload))
			End if 
	End case 
	
	return {header: $header; payload: $payload; signature: $signature}
	
	
	// ----------------------------------------------------
	
	
Function generate($inParams : Object; $inKey : Variant) : Text
	
	var $result : Text:=""
	
	Case of 
		: ((Value type($inParams)#Is object) || (Value type($inParams.payload)#Is object) || (OB Is empty($inParams.payload)))
			This._throwError(9; {which: "\"$inParams.payload\""; function: "JWT.generate"})
			
		Else 
			var $alg : Text:=((Value type($inParams.header.alg)=Is text) && (Length($inParams.header.alg)>0)) ? $inParams.header.alg : "RS256"
			var $typ : Text:=((Value type($inParams.header.typ)=Is text) && (Length($inParams.header.typ)>0)) ? $inParams.header.typ : "JWT"
			var $x5t : Text:=(Value type($inParams.header.x5t)=Is text) ? $inParams.header.x5t : ""
			
			var $header : Object:=((Value type($inParams.header)=Is object) && Not(OB Is empty($inParams.header))) ? $inParams.header : {}
			var $payload : Object:=((Value type($inParams.payload)=Is object) && Not(OB Is empty($inParams.payload))) ? $inParams.payload : {}
			
			If (Value type($header.alg)=Is undefined)
				$header.alg:=$alg
			End if 
			If (Value type($header.typ)=Is undefined)
				$header.typ:=$typ
			End if 
			If ((Value type($header.x5t)=Is undefined) && (Length($x5t)>0))
				$header.x5t:=$x5t
			End if 
			
			var $encodedHeader; $encodedPayload; $signature : Text
			
			// Inject iat (issued at) if not already set by the caller
			If (Value type($payload.iat)=Is undefined)
				$payload.iat:=Num((Current date-!1970-01-01!)*86400)+Num(Current time)
			End if 
			
			// Inject jti (JWT ID) if not already set by the caller — enables replay attack detection
			If (Value type($payload.jti)=Is undefined)
				$payload.jti:=Generate UUID
			End if 
			
			// Encode the Header and Payload
			BASE64 ENCODE(JSON Stringify($header); $encodedHeader; *)
			BASE64 ENCODE(JSON Stringify($payload); $encodedPayload; *)
			
			// Parse Header for Algorithm Family
			var $algorithm : Text:=$header.alg
			var $webToken : Object:={header: $header; payload: $payload}
			var $cryptoKey : 4D.CryptoKey:=Null
			var $key : Text:=""
			If (Value type($inKey)=Is text) && (Length(String($inKey))>0)
				$key:=$inKey
			End if 
			
			// Generate Verify Signature Hash based on Algorithm
			Case of 
				: (Lowercase($algorithm)="none")
					This._throwError(16; {alg: $algorithm})  // Reject 'none' algorithm — prevents algorithm confusion attacks
				: ($algorithm="HS@")
					$signature:=This._hashHS($webToken; $key)  // HMAC Hash
				Else 
					$cryptoKey:=This._getCryptoKey($inKey; This.key)
					If ($cryptoKey#Null)
						$signature:=This._hashSign($webToken; $cryptoKey)  // All other Hashes
					Else 
						This._throwError(15)  // The private or public key doesn't seem to be valid PEM.
					End if 
			End case 
			
			// Combine Encoded Header and Payload with Hashed Signature for the Token
			If (Length($signature)>0)
				$result:=$encodedHeader+"."+$encodedPayload+"."+$signature
			End if 
	End case 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function validate($inJWT : Text; $inKey : Variant; $inOptions : Object) : Boolean
	
	var $success : Boolean:=False
	
	Case of 
		: ((Value type($inJWT)#Is text) || (Length(String($inJWT))=0))
			This._throwError(9; {which: "\"$inJWT\""; function: "JWT.validate"})
			
		Else 
			// Split Token into the three parts: Header, Payload, Verify Signature
			var $parts : Collection:=Split string($inJWT; ".")
			
			If ($parts.length>2)
				
				var $header; $payload; $signature : Text
				var $cryptoKey : 4D.CryptoKey:=Null
				var $key : Text:=""
				If (Value type($inKey)=Is text) && (Length(String($inKey))>0)
					$key:=$inKey
				End if 
				
				// Decode Header and Payload into Objects
				BASE64 DECODE($parts[0]; $header; *)
				BASE64 DECODE($parts[1]; $payload; *)
				var $webToken : Object:={header: Try(JSON Parse($header)); payload: Try(JSON Parse($payload))}
				
				var $algorithm : Text:=$webToken.header.alg
				Case of 
					: (Lowercase($algorithm)="none")
						This._throwError(16; {alg: $algorithm})  // Reject 'none' algorithm — prevents algorithm confusion attacks
					: ($algorithm="HS@")
						$signature:=This._hashHS($webToken; $key)  // HMAC Hash
						$success:=($signature=$parts[2])
					Else 
						$cryptoKey:=This._resolveKey($inKey; This.key; $webToken.header.kid)
						If ($cryptoKey#Null)
							var $status : Object
							var $message : Text:=$parts[0]+"."+$parts[1]
							var $options : Object:={hash: (Substring($webToken.header.alg; 3)="256") ? SHA256 digest : SHA512 digest; pss: Bool($webToken.header.alg="PS@"); encoding: "Base64URL"}
							$signature:=$parts[2]
							$status:=$cryptoKey.verify($message; $signature; $options)
							$success:=$status.success
						Else 
							This._throwError(15)  // The private or public key doesn't seem to be valid PEM.
						End if 
				End case 
				If ($success)
					$success:=This._validateClaims($webToken.payload; $inOptions)
				End if 
			End if 
	End case 
	
	return $success
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _hashHS($inJWT : Object; $inPrivateKey : Text) : Text
	
	var $encodedHeader; $encodedPayload : Text
	var $headerBlob; $payloadBlob; $intermediateBlob; $privateBlob; $dataBlob : Blob
	var $blockSize; $i; $byte; $hashAlgorithm : Integer
	
	// Encode Header and Payload to build Message in Blob format
	BASE64 ENCODE(JSON Stringify($inJWT.header); $encodedHeader; *)
	BASE64 ENCODE(JSON Stringify($inJWT.payload); $encodedPayload; *)
	TEXT TO BLOB($encodedHeader+"."+$encodedPayload; $dataBlob; UTF8 text without length)
	
	// Parse Hashing Algorithm From Header
	var $algorithm : Text:=Substring($inJWT.header.alg; 3)
	If ($algorithm="256")
		$hashAlgorithm:=SHA256 digest
		$blockSize:=64
	Else 
		$hashAlgorithm:=SHA512 digest
		$blockSize:=128
	End if 
	
	// Format Secret Key as Blob
	TEXT TO BLOB($inPrivateKey; $privateBlob; UTF8 text without length)
	
	// If Key is larger than Block, Hash the Key to reduce size
	If (BLOB size($privateBlob)>$blockSize)
		BASE64 DECODE(Generate digest($privateBlob; $hashAlgorithm; *); $privateBlob; *)
	End if 
	
	// If Key is smaller than Blob pad with 0's
	If (BLOB size($privateBlob)<$blockSize)
		SET BLOB SIZE($privateBlob; $blockSize; 0)
	End if 
	
	ASSERT(BLOB size($privateBlob)=$blockSize)
	
	// Generate S bits
	SET BLOB SIZE($headerBlob; $blockSize)
	SET BLOB SIZE($payloadBlob; $blockSize)
	
	//S bits are based on the Formated Key XORed with specific pading bits
	//%r-
	For ($i; 0; $blockSize-1)
		$byte:=$privateBlob{$i}
		$payloadBlob{$i}:=$byte ^| 0x005C
		$headerBlob{$i}:=$byte ^| 0x0036
	End for 
	//%r+
	
	// append Message to S1 and Hash
	COPY BLOB($dataBlob; $headerBlob; 0; $blockSize; BLOB size($dataBlob))
	BASE64 DECODE(Generate digest($headerBlob; $hashAlgorithm; *); $intermediateBlob; *)
	
	// append Append Hashed S1+Message to S2 and Hash to get the Hashed Verify Signature
	COPY BLOB($intermediateBlob; $payloadBlob; 0; $blockSize; BLOB size($intermediateBlob))
	
	return Generate digest($payloadBlob; $hashAlgorithm; *)
	
	
	// ----------------------------------------------------
	
	
Function _hashSign($inJWT : Object; $inCryptoKey : 4D.CryptoKey) : Text
	
	var $hash : Text
	
	var $cryptoKey : 4D.CryptoKey:=Null
	If ((Value type($inCryptoKey)=Is object) && (OB Instance of($inCryptoKey; 4D.CryptoKey)))
		$cryptoKey:=$inCryptoKey
	Else 
		$cryptoKey:=This.key
	End if 
	
	If ($cryptoKey#Null)
		
		var $encodedHead; $encodedPayload : Text
		
		// Encode Header and Payload to build Message
		BASE64 ENCODE(JSON Stringify($inJWT.header); $encodedHead; *)
		BASE64 ENCODE(JSON Stringify($inJWT.payload); $encodedPayload; *)
		
		// Parse Header for Algorithm Family
		var $algorithm : Text:=Substring($inJWT.header.alg; 3)
		var $hashAlgorithm : Integer
		If ($algorithm="256")
			$hashAlgorithm:=SHA256 digest
		Else 
			$hashAlgorithm:=SHA512 digest
		End if 
		
		// Sign Message with CryptoKey to generate hashed verify signature
		$hash:=$cryptoKey.sign(String($encodedHead+"."+$encodedPayload); {hash: $hashAlgorithm; pss: Bool($inJWT.header.alg="PS@"); encoding: "Base64URL"})
	Else 
		This._throwError(15)  // The private or public key doesn't seem to be valid PEM.
	End if 
	
	return $hash
	
	
	// ----------------------------------------------------
	
	
Function _validateClaims($inPayload : Object; $inOptions : Object) : Boolean
	
	var $success : Boolean:=True
	
	// Current Unix timestamp in seconds since 1970-01-01 (assumes server clock is UTC)
	var $now : Real:=Num((Current date-!1970-01-01!)*86400)+Num(Current time)
	
	// Clock skew tolerance in seconds (default 0) — allows small drift between server clocks
	var $leeway : Real:=((Value type($inOptions)=Is object) && (Value type($inOptions.leeway)=Is real) && ($inOptions.leeway>0)) ? $inOptions.leeway : 0
	
	// Check exp (expiration time) — token must not be expired, with leeway tolerance
	If (Value type($inPayload.exp)=Is real)
		If ($now>($inPayload.exp+$leeway))
			$success:=False
		End if 
	End if 
	
	// Check nbf (not before) — token must not be used before its valid period, with leeway tolerance
	If ($success && (Value type($inPayload.nbf)=Is real))
		If ($now<($inPayload.nbf-$leeway))
			$success:=False
		End if 
	End if 
	
	// Check iss (issuer) — if expected issuer is provided, verify it matches
	If ($success && (Value type($inOptions)=Is object) && (Value type($inOptions.iss)=Is text) && (Length($inOptions.iss)>0))
		If ($inPayload.iss#$inOptions.iss)
			$success:=False
		End if 
	End if 
	
	// Check aud (audience) — if expected audience is provided, verify it matches
	If ($success && (Value type($inOptions)=Is object) && (Value type($inOptions.aud)=Is text) && (Length($inOptions.aud)>0))
		Case of 
			: (Value type($inPayload.aud)=Is text)
				$success:=($inPayload.aud=$inOptions.aud)
			: (Value type($inPayload.aud)=Is collection)
				var $audCol : Collection:=$inPayload.aud
				$success:=($audCol.indexOf($inOptions.aud)>=0)
			Else 
				$success:=False
		End case 
	End if 
	
	return $success
	
	
	// ----------------------------------------------------
	
	
Function _resolveKey($inKey : Variant; $inDefaultKey : 4D.CryptoKey; $inKid : Text) : 4D.CryptoKey
	// Resolves a key that may be a 4D.CryptoKey, a PEM text, or a JWKS URL (https://...)
	
	Case of 
		: ((Value type($inKey)=Is object) && OB Instance of($inKey; 4D.CryptoKey))
			return $inKey  // Already a CryptoKey
			
		: (Value type($inKey)=Is text)
			var $keyStr : Text:=String($inKey)
			Case of 
				: (Length($keyStr)=0)
					// empty text, fall through to default
				: (Lowercase(Substring($keyStr; 1; 8))="https://")
					// JWKS URL — fetch keys and find match by kid
					var $keys : Collection:=This._fetchJWKS($keyStr)
					var $jwk : Object:=This._findJWK($keys; $inKid)
					If ($jwk#Null)
						return This._jwkToCryptoKey($jwk)
					End if 
					return Null
				Else 
					return Try(4D.CryptoKey.new({type: "PEM"; pem: $keyStr}))
			End case 
			
		Else 
			// Not a CryptoKey or text, fall through to default
	End case 
	
	If ((Value type($inDefaultKey)=Is object) && OB Instance of($inDefaultKey; 4D.CryptoKey))
		return $inDefaultKey
	End if 
	return Null
	
	
	// ----------------------------------------------------
	
	
Function _fetchJWKS($inUrl : Text) : Collection
	// Fetches and caches a JWKS from $inUrl — cache TTL is 3600 seconds (Storage-based)
	
	var $now : Real:=Num((Current date-!1970-01-01!)*86400)+Num(Current time)
	
	// Initialise cache bucket in Storage if needed (use OB Is defined — more reliable than =Null in compiled class methods)
	If (Not(OB Is defined(Storage; "jwksCache")))
		Use (Storage)
			If (Not(OB Is defined(Storage; "jwksCache")))
				Storage["jwksCache"]:=New shared object
			End if 
		End use 
	End if 
	
	// Return cached keys if still fresh
	var $entry : Object:=Storage["jwksCache"][$inUrl]
	If (($entry#Null) && (($now-$entry.fetchedAt)<3600))
		return JSON Parse($entry.json)
	End if 
	
	// Fetch from URL
	var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new($inUrl; {method: "GET"}).wait())
	If ($request=Null)
		return Null
	End if 
	If (Num($request["response"]["status"])#200)
		return Null
	End if 
	
	var $body : Variant:=$request["response"]["body"]
	var $keys : Collection
	Case of 
		: (Value type($body)=Is object)
			$keys:=$body.keys
		: (Value type($body)=Is text)
			var $parsed : Object:=Try(JSON Parse($body))
			If ($parsed#Null)
				$keys:=$parsed.keys
			End if 
		Else 
			return Null
	End case 
	
	If (($keys=Null) || ($keys.length=0))
		return Null
	End if 
	
	// Store in cache
	Use (Storage["jwksCache"])
		Storage["jwksCache"][$inUrl]:=New shared object("json"; JSON Stringify($keys); "fetchedAt"; $now)
	End use 
	
	return $keys
	
	
	// ----------------------------------------------------
	

Function _injectJWKSCache($inUrl : Text; $inKeys : Collection)
	// Injects a JWKS collection into the component's Storage cache (for testing only).
	// Must be called from within the component context so that Storage refers to the
	// component's storage — not the host database's storage.
	
	var $now : Real:=Num((Current date-!1970-01-01!)*86400)+Num(Current time)
	Use (Storage)
		If (Not(OB Is defined(Storage; "jwksCache")))
			Storage["jwksCache"]:=New shared object
		End if 
	End use 
	Use (Storage["jwksCache"])
		Storage["jwksCache"][$inUrl]:=New shared object("json"; JSON Stringify($inKeys); "fetchedAt"; $now)
	End use 
	

Function _findJWK($inKeys : Collection; $inKid : Text) : Object
	// Finds a JWK by kid in a JWKS keys collection
	// Uses For each instead of .query() for reliable matching on JSON-parsed objects
	
	If ($inKeys=Null)
		return Null
	End if 
	If (Length($inKid)>0)
		var $key : Object
		For each ($key; $inKeys)
			If ($key.kid=$inKid)
				return $key
			End if 
		End for each 
		return Null  // kid specified but not found in JWKS
	End if 
	// No kid in token header: use the only key if exactly one is present
	If ($inKeys.length=1)
		return $inKeys[0]
	End if 
	return Null
	
	
	// ----------------------------------------------------
	
	
Function _jwkToCryptoKey($inJwk : Object) : 4D.CryptoKey
	// Converts a JWK public key to a 4D.CryptoKey — RSA only
	
	If (($inJwk=Null) || (Value type($inJwk.kty)#Is text))
		return Null
	End if 
	If ($inJwk.kty="RSA")
		var $pem : Text:=This._jwkRsaToPem($inJwk)
		If (Length($pem)>0)
			return Try(4D.CryptoKey.new({type: "PEM"; pem: $pem}))
		End if 
	End if 
	return Null
	
	
	// ----------------------------------------------------
	
	
Function _jwkRsaToPem($inJwk : Object) : Text
	// Builds a PEM-encoded SubjectPublicKeyInfo from an RSA JWK public key
	
	// Decode modulus (n) and exponent (e) from base64url
	var $nBlob; $eBlob : Blob
	BASE64 DECODE($inJwk.n; $nBlob; *)
	BASE64 DECODE($inJwk.e; $eBlob; *)
	
	// RSAPublicKey: SEQUENCE { INTEGER n, INTEGER e }
	var $nInt : Blob:=This._asn1Integer($nBlob)
	var $eInt : Blob:=This._asn1Integer($eBlob)
	var $rsaBody : Blob
	COPY BLOB($nInt; $rsaBody; 0; 0; BLOB size($nInt))
	COPY BLOB($eInt; $rsaBody; 0; BLOB size($rsaBody); BLOB size($eInt))
	var $rsaPubKey : Blob:=This._asn1Wrap(0x0030; $rsaBody)
	
	// BIT STRING: 0x00 (no unused bits) || RSAPublicKey
	var $bsContent : Blob
	SET BLOB SIZE($bsContent; 1)
	$bsContent{0}:=0
	COPY BLOB($rsaPubKey; $bsContent; 0; 1; BLOB size($rsaPubKey))
	var $bitString : Blob:=This._asn1Wrap(0x0003; $bsContent)
	
	// AlgorithmIdentifier: SEQUENCE { OID rsaEncryption (1.2.840.113549.1.1.1), NULL }
	var $oidBytes : Blob
	SET BLOB SIZE($oidBytes; 9)
	$oidBytes{0}:=0x002A
	$oidBytes{1}:=0x0086
	$oidBytes{2}:=0x0048
	$oidBytes{3}:=0x0086
	$oidBytes{4}:=0x00F7
	$oidBytes{5}:=0x000D
	$oidBytes{6}:=0x0001
	$oidBytes{7}:=0x0001
	$oidBytes{8}:=0x0001
	var $oid : Blob:=This._asn1Wrap(0x0006; $oidBytes)
	var $nullBytes : Blob
	SET BLOB SIZE($nullBytes; 2)
	$nullBytes{0}:=0x0005
	$nullBytes{1}:=0x0000
	var $algIdBody : Blob
	COPY BLOB($oid; $algIdBody; 0; 0; BLOB size($oid))
	COPY BLOB($nullBytes; $algIdBody; 0; BLOB size($algIdBody); BLOB size($nullBytes))
	var $algId : Blob:=This._asn1Wrap(0x0030; $algIdBody)
	
	// SubjectPublicKeyInfo: SEQUENCE { AlgorithmIdentifier, BIT STRING }
	var $spkiBody : Blob
	COPY BLOB($algId; $spkiBody; 0; 0; BLOB size($algId))
	COPY BLOB($bitString; $spkiBody; 0; BLOB size($spkiBody); BLOB size($bitString))
	var $spki : Blob:=This._asn1Wrap(0x0030; $spkiBody)
	
	// Base64-encode and wrap in PEM headers (64-char lines)
	var $b64 : Text
	BASE64 ENCODE($spki; $b64)
	$b64:=Replace string(Replace string($b64; Char(13)+Char(10); ""); Char(10); "")
	var $pem : Text:="-----BEGIN PUBLIC KEY-----"+Char(10)
	var $i : Integer
	For ($i; 1; Length($b64); 64)
		$pem+=Substring($b64; $i; 64)+Char(10)
	End for 
	$pem+="-----END PUBLIC KEY-----"
	return $pem
	
	
	// ----------------------------------------------------
	
	
Function _asn1Length($inLen : Integer) : Blob
	// Returns the DER length field encoding for a given byte count
	var $result : Blob
	Case of 
		: ($inLen<128)
			SET BLOB SIZE($result; 1)
			$result{0}:=$inLen
		: ($inLen<256)
			SET BLOB SIZE($result; 2)
			$result{0}:=0x0081
			$result{1}:=$inLen
		Else 
			SET BLOB SIZE($result; 3)
			$result{0}:=0x0082
			$result{1}:=Int($inLen/256)
			$result{2}:=Mod($inLen; 256)
	End case 
	return $result
	
	
Function _asn1Wrap($inTag : Integer; $inContent : Blob) : Blob
	// Wraps $inContent with an ASN.1 TLV header (tag + DER length)
	var $lenBlob : Blob:=This._asn1Length(BLOB size($inContent))
	var $result : Blob
	SET BLOB SIZE($result; 1)
	$result{0}:=$inTag
	COPY BLOB($lenBlob; $result; 0; BLOB size($result); BLOB size($lenBlob))
	COPY BLOB($inContent; $result; 0; BLOB size($result); BLOB size($inContent))
	return $result
	
	
Function _asn1Integer($inData : Blob) : Blob
	// Encodes a blob as an ASN.1 DER INTEGER, prepending 0x00 if MSB is set
	var $data : Blob
	If ($inData{0}>=128)
		SET BLOB SIZE($data; BLOB size($inData)+1)
		$data{0}:=0
		COPY BLOB($inData; $data; 0; 1; BLOB size($inData))
	Else 
		COPY BLOB($inData; $data; 0; 0; BLOB size($inData))
	End if 
	return This._asn1Wrap(0x0002; $data)
	
	
	// ----------------------------------------------------
	
	
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it
	var $error : Object:=cs._Tools.me.makeError($inCode; $inParameters)
	$error.deferred:=True
	throw($error)
