//%attributes = {"invisible":true}
var $jwt : cs:C1710._JWT
var $invalidToken; $validToken; $secretKey : Text

$secretKey:="-----BEGIN CERTIFICATE-----\rMIIDQDCCAigCCQC3o0lHIi/G4jANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJG\rUjEMMAoGA1UECAwDQlpIMQ8wDQYDVQQHDAZWYW5uZXMxEjAQBgNVBAMMCXl0cmlu\raC5mcjEgMB4GCSqGSIb3DQEJARYReWFubmlja0B5dHJpbmguZnIwHhcNMjMwOTI2\rMTIwNTUwWhcNMzMwOTIzMTIwNTUw"+"WjBiMQswCQYDVQQGEwJGUjEMMAoGA1UECAwD\rQlpIMQ8wDQYDVQQHDAZWYW5uZXMxEjAQBgNVBAMMCXl0cmluaC5mcjEgMB4GCSqG\rSIb3DQEJARYReWFubmlja0B5dHJpbmguZnIwggEiMA0GCSqGSIb3DQEBAQUAA4IB\rDwAwggEKAoIBAQDRgoA+QPDW73X50gyIFX0U2sBzRvSr+r2tvBNlVSpy6+BR09Ib\rVrQpcpqnwxzSSkP3/MQ"+"pkoHR9zSR9fZ9AHC/urxOJO5PMSU5k0KxPC7nfEA4yVhV\r4zvBIaJc9Oj9LkOEZL81cREejrw9FwBLAJRPmwmlitGzHkyzeIvaGuX3sXziDZcD\rEZ7uS7ozDJDTYcESBkf7eN7bD2KjedelKcikJ1xGeL/Eb9rla8b6y9rqJa7l+zL5\r3e81z3yIJkQIsEhDSnmLpPHS6Xo9rNaMfsBeC+kWgicNiW+vZK3g7r7irkgs+/46\rqQDaH/M6aa"+"o3d3UCBZVDTgprzLNUG3pEmCrZAgMBAAEwDQYJKoZIhvcNAQELBQAD\rggEBAGqu50DUV/Nk7vJ9cc2M6kpAVuXwzMaHxtC1fUby2r+GwolPHYaO5QEGrh36\rqpzsPZKiW66JVfQO6FEMJkLGz7IMmJyUjhPqf3QXMfkH2lETbNWEyxQJK5Jkohov\rAbIncEluMAnINFQruq2Ju793S5Ptoh+2DtMlJFVXM5Mv9vVOCifRSeEO3PJk0Axp\rw"+"PYBh+wGupzQD1CqgwiFbOqmHDjLJNER7RFJUtUKJRd8Dz05yBiu01hgeNoYI/tC\r1sLvmQxhbx7gQx61wPf6C5I2dePnPtzsKig/mSN7cMYX6kWEim4ds9NGXxjG+Am5\rJioP923/A2ggwlFnE24RJCHmKF8=\r-----END CERTIFICATE-----\r"

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
$validToken:="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NSIsIm5hbWUiOiJKb2huIERvZSIsImlhdCI6MTUxNjIzOTAyMn0.DEJUMDCzweNAT9sHA7oUjUYh1wzNbC_PIJD0ZgBbfR8"
ASSERT:C1129($jwt.validate($validToken; $secretKey))
