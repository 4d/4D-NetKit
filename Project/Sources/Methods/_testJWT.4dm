//%attributes = {"invisible":true}
var $jwt : cs:C1710._JWT
var $invalidToken; $validToken; $secretKey : Text

$secretKey:="-----BEGIN CERTIFICATE-----\rMIICLDCCAdKgAwIBAgIBADAKBggqhkjOPQQDAjB9MQswCQYDVQQGEwJCRTEPMA0G\rA1UEChMGR251VExTMSUwIwYDVQQLExxHbnVUTFMgY2VydGlmaWNhdGUgYXV0aG9y\raXR5MQ8wDQYDVQQIEwZMZXV2ZW4xJTAjBgNVBAMTHEdudVRMUyBjZXJ0aWZpY2F0\rZSBhdXRob3JpdHkwHhcNMTEwNTIz"+"MjAzODIxWhcNMTIxMjIyMDc0MTUxWjB9MQsw\rCQYDVQQGEwJCRTEPMA0GA1UEChMGR251VExTMSUwIwYDVQQLExxHbnVUTFMgY2Vy\rdGlmaWNhdGUgYXV0aG9yaXR5MQ8wDQYDVQQIEwZMZXV2ZW4xJTAjBgNVBAMTHEdu\rdVRMUyBjZXJ0aWZpY2F0ZSBhdXRob3JpdHkwWTATBgcqhkjOPQIBBggqhkjOPQMB\rBwNCAARS2I0jiuNn14Y"+"2sSALCX3IybqiIJUvxUpj+oNfzngvj/Niyv2394BWnW4X\ruQ4RTEiywK87WRcWMGgJB5kX/t2no0MwQTAPBgNVHRMBAf8EBTADAQH/MA8GA1Ud\rDwEB/wQFAwMHBgAwHQYDVR0OBBYEFPC0gf6YEr+1KLlkQAPLzB9mTigDMAoGCCqG\rSM49BAMCA0gAMEUCIDGuwD1KPyG+hRf88MeyMQcqOFZD0TbVleF+UsAGQ4enAiEA\rl4wOuDwKQa"+"+upc8GftXE2C//4mKANBC6It01gUaTIpo=\r-----END CERTIFICATE-----"

// Test case 1: Encode a payload and decode it back
$jwt:=cs:C1710._JWT.new({privateKey: $secretKey; payload: {sub: "1234567890"; name: "John Doe"; iat: 1516239022}})
$validToken:=$jwt.generate()
ASSERT:C1129($jwt.validate($validToken; $secretKey))

// Test case 2: Decode an invalid token
$jwt:=cs:C1710._JWT.new({privateKey: $secretKey})
$invalidToken:="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
ASSERT:C1129(Not:C34($jwt.validate($invalidToken; $secretKey)))

// Test case 3: Decode a valid token with an invalid signature
$jwt:=cs:C1710._JWT.new({privateKey: $secretKey})
$validToken:="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NSIsIm5hbWUiOiJKb2huIERvZSIsImlhdCI6MTUxNjIzOTAyMn0.9h7Q4Q8Z6ZQ4ZQZQZQZQZQZQZQZQZQZQZQZQZQZQZQ"
ASSERT:C1129(Not:C34($jwt.validate($validToken; $secretKey)))

// Test case 4: Decode a valid token with a valid signature
$jwt:=cs:C1710._JWT.new({privateKey: $secretKey})
$validToken:="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NSIsIm5hbWUiOiJKb2huIERvZSIsImlhdCI6MTUxNjIzOTAyMn0.H-Y29o4WDgakXGmXqv1uCmcfI2r9-XiZ7zDcg0hi1_0"
ASSERT:C1129($jwt.validate($validToken; $secretKey))
