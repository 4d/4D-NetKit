/*
Largely inspired by Tech Note: "JSON Web Tokens in 4D" from Thomas Maul
See: https://kb.4d.com/assetid=79100
*/

property _header : Object
property _payload : Object

Class constructor()
	
	This._header:={}
	This._payload:={}
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function decode($inToken : Text) : Object
	
	var $parts : Collection:=Split string($inToken; ".")
	
	If ($parts.length>2)
		var $header; $payload; $signature : Text
		BASE64 DECODE($parts[0]; $header; *)
		BASE64 DECODE($parts[1]; $payload; *)
		$signature:=$parts[2]
		
		// Note: If JSON parsing fails, Try(JSON Parse(...)) will return Null for header or payload.
		This._header:=Try(JSON Parse($header))
		This._payload:=Try(JSON Parse($payload))
		return {header: This._header; payload: This._payload; signature: $signature}
		
	Else 
		return {header: Null; payload: Null}
	End if 
	
	
	// ----------------------------------------------------
	
	
Function generate($inParams : Object) : Text
	
	var result : Text:=""
	var $alg : Text:=(Value type($inParams.header.alg)=Is text) ? $inParams.header.alg : "RS256"
	var $typ : Text:=(Value type($inParams.header.typ)=Is text) ? $inParams.header.typ : "JWT"
	var $x5t : Text:=(Value type($inParams.header.x5t)=Is text) ? $inParams.header.x5t : ""
	var $privateKey : Text:=((Value type($inParams.privateKey)=Is text) && (Length($inParams.privateKey)>0)) ? $inParams.privateKey : ""
	
	Case of 
		: ((Value type($inParams.payload)#Is object) || (OB Is empty($inParams.payload)))
			This._throwError(9; {which: "\"$inParams.payload\""; function: "JWT.generate"})
			
		: ((Value type($privateKey)#Is text) || (Length(String($privateKey))=0))
			This._throwError(9; {which: "\"$inParams.privateKey\""; function: "JWT.generate"})
			
		Else 
			This._header:={alg: $alg; typ: $typ}
			If (Length($x5t)>0)
				This._header.x5t:=$x5t
			End if 
			
			This._payload:=(Value type($inParams.payload)=Is object) ? $inParams.payload : {}
			
			var $header; $payload; $signature : Text
			
			// Encode the Header and Payload
			BASE64 ENCODE(JSON Stringify(This._header); $header; *)
			BASE64 ENCODE(JSON Stringify(This._payload); $payload; *)
			
			// Parse Header for Algorithm Family
			var $algorithm : Text:=This._header.alg
			If (($algorithm="HS256") || ($algorithm="HS512"))
				$algorithm:="HS"
			Else 
				$algorithm:="RS"
			End if 
			
			// Generate Verify Signature Hash based on Algorithm
			If ($algorithm="HS")
				$signature:=This._hashHS(This; $privateKey)  // HMAC Hash
			Else 
				$signature:=This._hashSign(This; $privateKey)  // All other Hashes
			End if 
			
			// Combine Encoded Header and Payload with Hashed Signature for the Token
			result:=$header+"."+$payload+"."+$signature
			
	End case 
	
	return result
	
	
	// ----------------------------------------------------
	
	
Function validate($inJWT : Text; $inPrivateKey : Text) : Boolean
	
	Case of 
		: ((Value type($inJWT)#Is text) || (Length(String($inJWT))=0))
			This._throwError(9; {which: "\"$inJWT\""; function: "JWT.validate"})
			
		: ((Value type($inPrivateKey)#Is text) || (Length(String($inPrivateKey))=0))
			This._throwError(9; {which: "\"$inPrivateKey\""; function: "JWT.validate"})
			
		Else 
			// Split Token into the three parts: Header, Payload, Verify Signature
			var $parts : Collection:=Split string($inJWT; ".")
			
			If ($parts.length>2)
				
				var $header; $payload; $signature : Text
				var $privateKey : Text:=((Value type($inPrivateKey)=Is text) && (Length($inPrivateKey)>0)) ? $inPrivateKey : ""
				
				// Decode Header and Payload into Objects
				BASE64 DECODE($parts[0]; $header; *)
				BASE64 DECODE($parts[1]; $payload; *)
				var $jwt : Object:={_header: Try(JSON Parse($header)); _payload: Try(JSON Parse($payload))}
				
				// Parse Header for Algorithm Family
				var $algorithm : Text:=Substring($jwt._header.alg; 1; 2)
				
				// Generate Hashed Verify Signature
				If ($algorithm="HS")
					$signature:=This._hashHS($jwt; $privateKey)
				Else 
					$signature:=This._hashSign($jwt; $privateKey)
				End if 
				
				If (OB Is empty(This._header))
					This._header:=$jwt._header
				End if 
				If (OB Is empty(This._payload))
					This._payload:=$jwt._payload
				End if 
				
				//Compare Verify Signatures to return Result
				return ($signature=$parts[2])
				
			End if 
	End case 
	
	return False
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _hashHS($inJWT : cs.NetKit.JWT; $inPrivateKey : Text) : Text
	
	var $encodedHeader; $encodedPayload : Text
	var $headerBlob; $payloadBlob; $intermediateBlob; $privateBlob; $dataBlob : Blob
	var $blockSize; $i; $byte; $hashAlgorithm : Integer
	
	// Encode Header and Payload to build Message in Blob format
	BASE64 ENCODE(JSON Stringify($inJWT._header); $encodedHeader; *)
	BASE64 ENCODE(JSON Stringify($inJWT._payload); $encodedPayload; *)
	TEXT TO BLOB($encodedHeader+"."+$encodedPayload; $dataBlob; UTF8 text without length)
	
	// Parse Hashing Algorithm From Header
	var $algorithm : Text:=Substring($inJWT._header.alg; 3)
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
	
	
Function _hashSign($inJWT : cs.NetKit.JWT; $inPrivateKey : Text) : Text
	
	var $hash; $encodedHead; $encodedPayload : Text
	var $settings : Object
	var $privateKey : Text:=((Value type($inPrivateKey)=Is text) && (Length($inPrivateKey)>0)) ? $inPrivateKey : ""
	
	// Encode Header and Payload to build Message
	BASE64 ENCODE(JSON Stringify($inJWT._header); $encodedHead; *)
	BASE64 ENCODE(JSON Stringify($inJWT._payload); $encodedPayload; *)
	
	// Prepare CryptoKey settings
	If (Length($privateKey)=0)
		$settings:={type: "RSA"}  // 4D will automatically create RSA key pair
	Else 
		$settings:={type: "PEM"; pem: $privateKey}  // Use specified PEM format Key
	End if 
	
	// Create new CryptoKey
	var $cryptoKey : 4D.CryptoKey:=4D.CryptoKey.new($settings)
	If ($cryptoKey#Null)
		
		// Parse Header for Algorithm Family
		var $algorithm : Text:=Substring($inJWT._header.alg; 3)
		var $hashAlgorithm : Integer
		If ($algorithm="256")
			$hashAlgorithm:=SHA256 digest
		Else 
			$hashAlgorithm:=SHA512 digest
		End if 
		
		// Sign Message with CryptoKey to generate hashed verify signature
		$hash:=$cryptoKey.sign(String($encodedHead+"."+$encodedPayload); {hash: $hashAlgorithm; pss: Bool($inJWT._header.alg="PS@"); encoding: "Base64URL"})
	End if 
	
	return $hash
	
	
	// ----------------------------------------------------
	
	
Function _throwError($inCode : Integer; $inParameters : Object)
	
	// Push error into errorStack and throw it
	var $error : Object:=cs.Tools.me.makeError($inCode; $inParameters)
	$error.deferred:=True
	throw($error)
	
