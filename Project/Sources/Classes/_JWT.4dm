/*
Largely inspired by Tech Note: "JSON Web Tokens in 4D" from Thomas Maul
See: https://kb.4d.com/assetid=79100
*/

Class constructor($inParam : Object)
	
	This:C1470.header:=New object:C1471
	If (OB Is defined:C1231($inParam; "header"))
		This:C1470.header.alg:=OB Is defined:C1231($inParam.header; "alg") ? $inParam.header.alg : "RS256"
		This:C1470.header.typ:=OB Is defined:C1231($inParam.header; "typ") ? $inParam.header.typ : "JWT"
	Else 
		This:C1470.header.alg:="RS256"
		This:C1470.header.typ:="JWT"
	End if 
	
	If (OB Get type:C1230($inParam; "payload")=Is object:K8:27)
		This:C1470.payload:=$inParam.payload
	Else 
		This:C1470.payload:=New object:C1471
	End if 
	
	This:C1470.privateKey:=String:C10($inParam.privateKey)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function generate() : Text
	
	var $header; $payload; $algorithm; $signature : Text
	
	// Encode the Header and Payload
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.header); $header; *)
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.payload); $payload; *)
	
	// Parse Header for Algorithm Family
	$algorithm:=Substring:C12(This:C1470.header.alg; 1; 2)
	
	// Generate Verify Signature Hash based on Algorithm
	If ($algorithm="HS")
		$signature:=This:C1470._hashHS(This:C1470)  // HMAC Hash
	Else 
		$signature:=This:C1470._hashSign(This:C1470)  // All other Hashes
	End if 
	
	// Combine Encoded Header and Payload with Hashed Signature for the Token
	return ($header+"."+$payload+"."+$signature)
	
	
	// ----------------------------------------------------
	
	
Function validate($inJWT : Text; $inPrivateKey : Text) : Boolean
	
	// Split Token into the three parts: Header, Payload, Verify Signature
	var $parts : Collection
	$parts:=Split string:C1554($inJWT; ".")
	
	If ($parts.length>2)
		
		var $header; $payload; $algorithm; $signature : Text
		var $jwt : Object
		
		// Decode Header and Payload into Objects
		BASE64 DECODE:C896($parts[0]; $header; *)
		BASE64 DECODE:C896($parts[1]; $payload; *)
		$jwt:=New object:C1471("header"; JSON Parse:C1218($header); \
			"payload"; JSON Parse:C1218($payload); \
			"privateKey"; String:C10($inPrivateKey))
		
		// Parse Header for Algorithm Family
		$algorithm:=Substring:C12($jwt.header.alg; 1; 2)
		
		// Generate Hashed Verify Signature
		If ($algorithm="HS")
			$signature:=This:C1470._hashHS($jwt)
		Else 
			$signature:=This:C1470._hashSign($jwt)
		End if 
		
		//Compare Verify Signatures to return Result
		return ($signature=$parts[2])
		
	End if 
	
	return False:C215
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _hashHS($inJWT : Object)->$result : Text
	
	var $encodedHeader; $encodedPayload; $algorithm : Text
	var $headerBlob; $payloadBlob; $intermediateBlob; $privateBlob; $dataBlob : Blob
	var $blockSize; $i; $byte; $hashAlgorithm : Integer
	
	// Encode Header and Payload to build Message in Blob format
	BASE64 ENCODE:C895(JSON Stringify:C1217($inJWT.header); $encodedHeader; *)
	BASE64 ENCODE:C895(JSON Stringify:C1217($inJWT.payload); $encodedPayload; *)
	TEXT TO BLOB:C554($encodedHeader+"."+$encodedPayload; $dataBlob; UTF8 text without length:K22:17)
	
	// Parse Hashing Algorithm From Header
	$algorithm:=Substring:C12($inJWT.header.alg; 3)
	If ($algorithm="256")
		$hashAlgorithm:=SHA256 digest:K66:4
		$blockSize:=64
	Else 
		$hashAlgorithm:=SHA512 digest:K66:5
		$blockSize:=128
	End if 
	
	// Format Secret Key as Blob
	TEXT TO BLOB:C554($inJWT.privateKey; $privateBlob; UTF8 text without length:K22:17)
	
	// If Key is larger than Block, Hash the Key to reduce size
	If (BLOB size:C605($privateBlob)>$blockSize)
		BASE64 DECODE:C896(Generate digest:C1147($privateBlob; $hashAlgorithm; *); $privateBlob; *)
	End if 
	
	// If Key is smaller than Blob pad with 0's
	If (BLOB size:C605($privateBlob)<$blockSize)
		SET BLOB SIZE:C606($privateBlob; $blockSize; 0)
	End if 
	
	ASSERT:C1129(BLOB size:C605($privateBlob)=$blockSize)
	
	// Generate S bits
	SET BLOB SIZE:C606($headerBlob; $blockSize)
	SET BLOB SIZE:C606($payloadBlob; $blockSize)
	
	//S bits are based on the Formated Key XORed with specific pading bits
	//%r-
	For ($i; 0; $blockSize-1)
		$byte:=$privateBlob{$i}
		$payloadBlob{$i}:=$byte ^| 0x005C
		$headerBlob{$i}:=$byte ^| 0x0036
	End for 
	//%r+
	
	// append Message to S1 and Hash
	COPY BLOB:C558($dataBlob; $headerBlob; 0; $blockSize; BLOB size:C605($dataBlob))
	BASE64 DECODE:C896(Generate digest:C1147($headerBlob; $hashAlgorithm; *); $intermediateBlob; *)
	
	// append Append Hashed S1+Message to S2 and Hash to get the Hashed Verify Signature
	COPY BLOB:C558($intermediateBlob; $payloadBlob; 0; $blockSize; BLOB size:C605($intermediateBlob))
	$result:=Generate digest:C1147($payloadBlob; $hashAlgorithm; *)
	
	
	// ----------------------------------------------------
	
	
Function _hashSign($inJWT : Object)->$result : Text
	
	var $encodedHead; $encodedPayload; $algorithm; $privateKey : Text
	var $settings; $signOptions : Object
	var $hashAlgorithm : Integer
	var $cryptoKey : 4D:C1709.CryptoKey
	
	$privateKey:=(String:C10($inJWT.privateKey)#"") ? String:C10($inJWT.privateKey) : String:C10(This:C1470.privateKey)
	
	// Encode Header and Payload to build Message
	BASE64 ENCODE:C895(JSON Stringify:C1217($inJWT.header); $encodedHead; *)
	BASE64 ENCODE:C895(JSON Stringify:C1217($inJWT.payload); $encodedPayload; *)
	
	// Prepare CryptoKey settings
	If ($privateKey="")
		$settings:=New object:C1471("type"; "RSA")  // 4D will automatically create RSA key pair
	Else 
		$settings:=New object:C1471("type"; "PEM"; "pem"; $privateKey)  // Use specified PEM format Key
	End if 
	
	// Create new CryptoKey
	$cryptoKey:=4D:C1709.CryptoKey.new($settings)
	
	// Parse Header for Algorithm Family
	$algorithm:=Substring:C12($inJWT.header.alg; 3)
	If ($algorithm="256")
		$hashAlgorithm:=SHA256 digest:K66:4
	Else 
		$hashAlgorithm:=SHA512 digest:K66:5
	End if 
	
	// Sign Message with CryptoKey to generate hashed verify signature
	$signOptions:=New object:C1471("hash"; $hashAlgorithm; "pss"; $inJWT.header.alg="PS@"; "encoding"; "Base64URL")
	$result:=$cryptoKey.sign($encodedHead+"."+$encodedPayload; $signOptions)
	
	If (String:C10(This:C1470.privateKey)="")
		This:C1470.privateKey:=$cryptoKey.getPrivateKey()
	End if 
	