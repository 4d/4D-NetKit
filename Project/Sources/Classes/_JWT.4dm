/*
Largely inspired by Tech Note: "JSON Web Tokens in 4D" from Thomas Maul
See: https://kb.4d.com/assetid=79100
*/

property header : Object
property payload : Object
property privateKey : Text

Class constructor($inParam : Object)
	
	var $alg : Text:=(OB Is defined($inParam; "header") && OB Is defined($inParam.header; "alg")) ? $inParam.header.alg : "RS256"
	var $typ : Text:=(OB Is defined($inParam; "header") && OB Is defined($inParam.header; "typ")) ? $inParam.header.typ : "JWT"
	var $x5t : Text:=(OB Is defined($inParam; "header") && OB Is defined($inParam.header; "x5t")) ? $inParam.header.x5t : ""
	
	This.header:={alg: $alg; typ: $typ}
	If ($x5t#"")
		This.header.x5t:=$x5t
	End if 
	
	
	If (OB Get type($inParam; "payload")=Is object)
		This.payload:=$inParam.payload
	Else 
		This.payload:={}
	End if 
	
	This.privateKey:=String($inParam.privateKey)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function generate() : Text
	
	var $header; $payload; $signature : Text
	
	// Encode the Header and Payload
	BASE64 ENCODE(JSON Stringify(This.header); $header; *)
	BASE64 ENCODE(JSON Stringify(This.payload); $payload; *)
	
	// Parse Header for Algorithm Family
	var $algorithm : Text:=Substring(This.header.alg; 1; 2)
	
	// Generate Verify Signature Hash based on Algorithm
	If ($algorithm="HS")
		$signature:=This._hashHS(This)  // HMAC Hash
	Else 
		$signature:=This._hashSign(This)  // All other Hashes
	End if 
	
	// Combine Encoded Header and Payload with Hashed Signature for the Token
	return ($header+"."+$payload+"."+$signature)
	
	
	// ----------------------------------------------------
	
	
Function validate($inJWT : Text; $inPrivateKey : Text) : Boolean
	
	// Split Token into the three parts: Header, Payload, Verify Signature
	var $parts : Collection:=Split string($inJWT; ".")
	
	If ($parts.length>2)
		
		var $header; $payload; $signature : Text
		
		// Decode Header and Payload into Objects
		BASE64 DECODE($parts[0]; $header; *)
		BASE64 DECODE($parts[1]; $payload; *)
		var $jwt : Object:={header: Try(JSON Parse($header)); payload: Try(JSON Parse($payload)); privateKey: String($inPrivateKey)}
		
		// Parse Header for Algorithm Family
		var $algorithm : Text:=Substring($jwt.header.alg; 1; 2)
		
		// Generate Hashed Verify Signature
		If ($algorithm="HS")
			$signature:=This._hashHS($jwt)
		Else 
			$signature:=This._hashSign($jwt)
		End if 
		
		This.header:=$jwt.header
		This.payload:=$jwt.payload
		
		//Compare Verify Signatures to return Result
		return ($signature=$parts[2])
		
	End if 
	
	return False
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _hashHS($inJWT : Object) : Text
	
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
	TEXT TO BLOB($inJWT.privateKey; $privateBlob; UTF8 text without length)
	
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
	
	
Function _hashSign($inJWT : Object)->$hash : Text
	
	var $encodedHead; $encodedPayload : Text
	var $settings : Object
	var $privateKey : Text:=(String($inJWT.privateKey)#"") ? String($inJWT.privateKey) : String(This.privateKey)
	
	// Encode Header and Payload to build Message
	BASE64 ENCODE(JSON Stringify($inJWT.header); $encodedHead; *)
	BASE64 ENCODE(JSON Stringify($inJWT.payload); $encodedPayload; *)
	
	// Prepare CryptoKey settings
	If ($privateKey="")
		$settings:={type: "RSA"}  // 4D will automatically create RSA key pair
	Else 
		$settings:={type: "PEM"; pem: $privateKey}  // Use specified PEM format Key
	End if 
	
	// Create new CryptoKey
	var $cryptoKey : 4D.CryptoKey:=4D.CryptoKey.new($settings)
	If ($cryptoKey#Null)
		If (String(This.privateKey)="")
			This.privateKey:=$cryptoKey.getPrivateKey()
		End if 
		
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
	End if 
