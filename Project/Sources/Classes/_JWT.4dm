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
	
	This:C1470.secretKey:=String:C10($inParam.secretKey)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function generate()->$result : Text
	
	C_TEXT:C284($header)
	C_TEXT:C284($payload)
	C_TEXT:C284($algorithm)
	C_TEXT:C284($signature)
	
	// Encode the Header and Payload
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.header); $header; *)
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.payload); $payload; *)
	
	// Parse Header for Algorithm Family
	$algorithm:=Substring:C12(This:C1470.header.alg; 1; 2)
	
	// Generate Verify Signature Hash based on Algorithm
	If ($algorithm="HS")
		$signature:=This:C1470._hashHS()  // HMAC Hash
	Else 
		$signature:=This:C1470._hashSign()  // All other Hashes
	End if 
	
	// Combine Encoded Header and Payload with Hashed Signature for the Token
	$result:=$header+"."+$payload+"."+$signature
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _hashHS->$result : Text
	
	var $encodedHeader; $encodedPayload; $algorithm : Text
	var $headerBlob; $payloadBlob; $intermediateBlob; $secretBlob; $dataBlob : Blob
	var $blockSize; $i; $byte; $hashAlgorithm : Integer
	
	// Encode Header and Payload to build Message in Blob format
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.header); $encodedHeader; *)
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.payload); $encodedPayload; *)
	TEXT TO BLOB:C554($encodedHeader+"."+$encodedPayload; $dataBlob; UTF8 text without length:K22:17)
	
	// Parse Hashing Algorithm From Header
	$algorithm:=Substring:C12(This:C1470.header.alg; 3)
	If ($algorithm="256")
		$hashAlgorithm:=SHA256 digest:K66:4
		$blockSize:=64
	Else 
		$hashAlgorithm:=SHA512 digest:K66:5
		$blockSize:=128
	End if 
	
	// Format Secret Key as Blob
	TEXT TO BLOB:C554(This:C1470.secretKey; $secretBlob; UTF8 text without length:K22:17)
	
	// If Key is larger than Block, Hash the Key to reduce size
	If (BLOB size:C605($secretBlob)>$blockSize)
		BASE64 DECODE:C896(Generate digest:C1147($secretBlob; $hashAlgorithm; *); $secretBlob; *)
	End if 
	
	// If Key is smaller than Blob pad with 0's
	If (BLOB size:C605($secretBlob)<$blockSize)
		SET BLOB SIZE:C606($secretBlob; $blockSize; 0)
	End if 
	
	ASSERT:C1129(BLOB size:C605($secretBlob)=$blockSize)
	
	// Generate S bits
	SET BLOB SIZE:C606($headerBlob; $blockSize)
	SET BLOB SIZE:C606($payloadBlob; $blockSize)
	
	//S bits are based on the Formated Key XORed with specific pading bits
	//%r-
	For ($i; 0; $blockSize-1)
		$byte:=$secretBlob{$i}
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
	
	
Function _hashSign->$result : Text
	
	var $encodedHead; $encodedPayload; $algorithm : Text
	var $settings; $signOptions : Object
	var $hashAlgorithm : Integer
	var $cryptoKey : 4D:C1709.CryptoKey
	
	// Encode Header and Payload to build Message
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.header); $encodedHead; *)
	BASE64 ENCODE:C895(JSON Stringify:C1217(This:C1470.payload); $encodedPayload; *)
	
	// Prepare CryptoKey settings
	If (String:C10(This:C1470.secretKey)="")
		$settings:=New object:C1471("type"; "RSA")  // 4D will automatically create RSA key pair
	Else 
		$settings:=New object:C1471("type"; "PEM"; "pem"; This:C1470.secretKey)  // Use specified PEM format Key
	End if 
	
	// Create new CryptoKey
	$cryptoKey:=4D:C1709.CryptoKey.new($settings)
	
	// Parse Header for Algorithm Family
	$algorithm:=Substring:C12(This:C1470.header.alg; 3)
	If ($algorithm="256")
		$hashAlgorithm:=SHA256 digest:K66:4
	Else 
		$hashAlgorithm:=SHA512 digest:K66:5
	End if 
	
	// Sign Message with CryptoKey to generate hashed verify signature
	$signOptions:=New object:C1471("hash"; $hashAlgorithm; "pss"; This:C1470.header.alg="PS@"; "encoding"; "Base64URL")
	$result:=$cryptoKey.sign($encodedHead+"."+$encodedPayload; $signOptions)
	