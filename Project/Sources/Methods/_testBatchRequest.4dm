//%attributes = {"invisible":true}
// Test case for _BatchRequest

// Create a new _BatchRequest object
C_OBJECT($batchRequest)
$batchRequest:=New object("id"; 1; "verb"; "GET"; "URL"; "https://example.com"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a body
C_OBJECT($batchRequestWithBody)
$batchRequestWithBody:=New object("id"; 2; "verb"; "POST"; "URL"; "https://example.com"; "body"; "test body"; "headers"; New collection())

// Create a new _BatchRequest object with headers
C_OBJECT($batchRequestWithHeaders)
$batchRequestWithHeaders:=New object("id"; 3; "verb"; "GET"; "URL"; "https://example.com"; "body"; ""; "headers"; New collection(New object("name"; "Authorization"; "value"; "Bearer token")))

// Create a new _BatchRequest object with headers and a body
C_OBJECT($batchRequestWithHeadersAndBody)
$batchRequestWithHeadersAndBody:=New object("id"; 4; "verb"; "POST"; "URL"; "https://example.com"; "body"; "test body"; "headers"; New collection(New object("name"; "Authorization"; "value"; "Bearer token")))

// Create a new _BatchRequest object with a URL that contains query parameters
C_OBJECT($batchRequestWithQueryParameters)
$batchRequestWithQueryParameters:=New object("id"; 5; "verb"; "GET"; "URL"; "https://example.com?param1=value1&param2=value2"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains special characters
C_OBJECT($batchRequestWithSpecialCharacte)
$batchRequestWithSpecialCharacte:=New object("id"; 6; "verb"; "GET"; "URL"; "https://example.com/path/to/resource?param=value&param2=value%202"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains spaces
C_OBJECT($batchRequestWithSpaces)
$batchRequestWithSpaces:=New object("id"; 7; "verb"; "GET"; "URL"; "https://example.com/path/to/resource with spaces"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains Unicode characters
C_OBJECT($batchRequestWithUnicode)
$batchRequestWithUnicode:=New object("id"; 8; "verb"; "GET"; "URL"; "https://example.com/こんにちは"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains a fragment identifier
C_OBJECT($batchRequestWithFragmentIdentif)
$batchRequestWithFragmentIdentif:=New object("id"; 9; "verb"; "GET"; "URL"; "https://example.com/path/to/resource#fragment"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains a port number
C_OBJECT($batchRequestWithPortNumber)
$batchRequestWithPortNumber:=New object("id"; 10; "verb"; "GET"; "URL"; "https://example.com:8080/path/to/resource"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains a username and password
C_OBJECT($batchRequestWithUsernameAndPass)
$batchRequestWithUsernameAndPass:=New object("id"; 11; "verb"; "GET"; "URL"; "https://user:password@example.com/path/to/resource"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains an IPv4 address
C_OBJECT($batchRequestWithIPv4Address)
$batchRequestWithIPv4Address:=New object("id"; 12; "verb"; "GET"; "URL"; "https://192.168.0.1/path/to/resource"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains an IPv6 address
C_OBJECT($batchRequestWithIPv6Address)
$batchRequestWithIPv6Address:=New object("id"; 13; "verb"; "GET"; "URL"; "https://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/path/to/resource"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains a domain name with multiple levels
C_OBJECT($batchRequestWithMultipleLevels)
$batchRequestWithMultipleLevels:=New object("id"; 14; "verb"; "GET"; "URL"; "https://www.example.com/path/to/resource"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains a domain name with a single level
C_OBJECT($batchRequestWithSingleLevel)
$batchRequestWithSingleLevel:=New object("id"; 15; "verb"; "GET"; "URL"; "https://example/path/to/resource"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains a domain name with a hyphen
C_OBJECT($batchRequestWithHyphen)
$batchRequestWithHyphen:=New object("id"; 16; "verb"; "GET"; "URL"; "https://example-domain.com/path/to/resource"; "body"; ""; "headers"; New collection())

// Create a new _BatchRequest object with a URL that contains a domain name with an underscore
C_OBJECT($batchRequestWithUnderscore)
$batchRequestWithUnderscore:=New object("id"; 17; "verb"; "GET"; "URL"; "https://example_domain.com/path/to/resource"; "body"; ""; "headers"; New collection())

// Test the body of a _BatchRequest object with no body
ASSERT(cs._BatchRequest.new($batchRequest).body="Content-Type: application/http\r\nContent-ID: 1\r\n\r\nGET https://example.com HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a body
ASSERT(cs._BatchRequest.new($batchRequestWithBody).body="Content-Type: application/http\r\nContent-ID: 2\r\n\r\nPOST https://example.com HTTP/1.1\r\n\r\ntest body\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with headers
ASSERT(cs._BatchRequest.new($batchRequestWithHeaders).body="Content-Type: application/http\r\nContent-ID: 3\r\n\r\nGET https://example.com HTTP/1.1\r\nAuthorization: Bearer token\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with headers and a body
ASSERT(cs._BatchRequest.new($batchRequestWithHeadersAndBody).body="Content-Type: application/http\r\nContent-ID: 4\r\n\r\nPOST https://example.com HTTP/1.1\r\nAuthorization: Bearer token\r\n\r\ntest body\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains query parameters
ASSERT(cs._BatchRequest.new($batchRequestWithQueryParameters).body="Content-Type: application/http\r\nContent-ID: 5\r\n\r\nGET https://example.com?param1=value1&param2=value2 HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains special characters
ASSERT(cs._BatchRequest.new($batchRequestWithSpecialCharacte).body="Content-Type: application/http\r\nContent-ID: 6\r\n\r\nGET https://example.com/path/to/resource?param=value&param2=value%202 HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains spaces
ASSERT(cs._BatchRequest.new($batchRequestWithSpaces).body="Content-Type: application/http\r\nContent-ID: 7\r\n\r\nGET https://example.com/path/to/resource with spaces HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains Unicode characters
ASSERT(cs._BatchRequest.new($batchRequestWithUnicode).body="Content-Type: application/http\r\nContent-ID: 8\r\n\r\nGET https://example.com/こんにちは HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains a fragment identifier
ASSERT(cs._BatchRequest.new($batchRequestWithFragmentIdentif).body="Content-Type: application/http\r\nContent-ID: 9\r\n\r\nGET https://example.com/path/to/resource#fragment HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains a port number
ASSERT(cs._BatchRequest.new($batchRequestWithPortNumber).body="Content-Type: application/http\r\nContent-ID: 10\r\n\r\nGET https://example.com:8080/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains a username and password
ASSERT(cs._BatchRequest.new($batchRequestWithUsernameAndPass).body="Content-Type: application/http\r\nContent-ID: 11\r\n\r\nGET https://user:password@example.com/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains an IPv4 address
ASSERT(cs._BatchRequest.new($batchRequestWithIPv4Address).body="Content-Type: application/http\r\nContent-ID: 12\r\n\r\nGET https://192.168.0.1/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains an IPv6 address
ASSERT(cs._BatchRequest.new($batchRequestWithIPv6Address).body="Content-Type: application/http\r\nContent-ID: 13\r\n\r\nGET https://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains a domain name with multiple levels
ASSERT(cs._BatchRequest.new($batchRequestWithMultipleLevels).body="Content-Type: application/http\r\nContent-ID: 14\r\n\r\nGET https://www.example.com/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains a domain name with a single level
ASSERT(cs._BatchRequest.new($batchRequestWithSingleLevel).body="Content-Type: application/http\r\nContent-ID: 15\r\n\r\nGET https://example/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains a domain name with a hyphen
ASSERT(cs._BatchRequest.new($batchRequestWithHyphen).body="Content-Type: application/http\r\nContent-ID: 16\r\n\r\nGET https://example-domain.com/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")

// Test the body of a _BatchRequest object with a URL that contains a domain name with an underscore
ASSERT(cs._BatchRequest.new($batchRequestWithUnderscore).body="Content-Type: application/http\r\nContent-ID: 17\r\n\r\nGET https://example_domain.com/path/to/resource HTTP/1.1\r\n\r\n--batch\r\n")
