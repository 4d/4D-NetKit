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
		: ((Value type($inParams.payload)#Is object) || (OB Is empty($inParams.payload)))
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
			If ($algorithm="HS@")
				$signature:=This._hashHS($webToken; $key)  // HMAC Hash
			Else 
				$cryptoKey:=This._getCryptoKey($inKey; This.key)
				If ($cryptoKey#Null)
					$signature:=This._hashSign($webToken; $cryptoKey)  // All other Hashes
				Else 
					This._throwError(15)  // The private or public key doesn't seem to be valid PEM.
				End if 
			End if 
			
			// Combine Encoded Header and Payload with Hashed Signature for the Token
			If (Length($signature)>0)
				$result:=$encodedHeader+"."+$encodedPayload+"."+$signature
			End if 
	End case 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function validate($inJWT : Text; $inKey : Variant) : Boolean
	
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
				If ($algorithm="HS@")
					$signature:=This._hashHS($webToken; $key)  // HMAC Hash
					$success:=($signature=$parts[2])
				Else 
					$cryptoKey:=This._getCryptoKey($inKey; This.key)
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
	
	
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it
	var $error : Object:=cs.Tools.me.makeError($inCode; $inParameters)
	$error.deferred:=True
	throw($error)
