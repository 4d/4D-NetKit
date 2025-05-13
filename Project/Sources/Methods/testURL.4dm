//%attributes = {}
//--------------------------------------------------------
var $URLString : Text:="http://www.example.com:8080/path/to/resource?query=param#hash"
var $URL : cs:C1710.URL:=cs:C1710.URL.new($URLString)
ASSERT:C1129($URL.scheme="http")
ASSERT:C1129($URL.host="www.example.com")
ASSERT:C1129($URL.port=8080)
ASSERT:C1129($URL.path="/path/to/resource")
ASSERT:C1129($URL.query="query=param")
ASSERT:C1129($URL.ref="hash")
ASSERT:C1129($URL.toString()=$URLString)

$URL.addQueryParameter("q2=v2")
$URL.addQueryParameter("q3"; "v3")
$URL.addQueryParameter({name: "q4"; value: "v4"})
ASSERT:C1129($URL.query="query=param&q2=v2&q3=v3&q4=v4")

//--------------------------------------------------------
$URLString:="https://www.example.com/path/to/resource"
$URL:=cs:C1710.URL.new($URLString)
ASSERT:C1129($URL.scheme="https")
ASSERT:C1129($URL.host="www.example.com")
ASSERT:C1129($URL.port=443)
ASSERT:C1129($URL.path="/path/to/resource")
ASSERT:C1129($URL.toString()=$URLString)

//--------------------------------------------------------
$URLString:="http://www.example.com/"
$URL:=cs:C1710.URL.new($URLString)
ASSERT:C1129($URL.scheme="http")
ASSERT:C1129($URL.host="www.example.com")
ASSERT:C1129($URL.port=80)
ASSERT:C1129($URL.path="/")
ASSERT:C1129($URL.toString()=$URLString)

//--------------------------------------------------------
$URLString:=""
$URL:=cs:C1710.URL.new($URLString)
$URL.addQueryParameter("query=param")
$URL.addQueryParameter("q2=v2")
$URL.addQueryParameter("q3"; "v3")
$URL.addQueryParameter({name: "q4"; value: "v4"})

ASSERT:C1129($URL.scheme="")
ASSERT:C1129($URL.host="")
ASSERT:C1129($URL.port=0)
ASSERT:C1129($URL.path="")
ASSERT:C1129($URL.query="query=param&q2=v2&q3=v3&q4=v4")
$URLString:=$URL.toString()

//--------------------------------------------------------
$URLString:="?query=param&q2=v2&q3=v3&q4=v4"
$URL:=cs:C1710.URL.new($URLString)
ASSERT:C1129($URL.scheme="")
ASSERT:C1129($URL.host="")
ASSERT:C1129($URL.port=0)
ASSERT:C1129($URL.path="")
ASSERT:C1129($URL.query="query=param&q2=v2&q3=v3&q4=v4")
$URLString:=$URL.toString()

//--------------------------------------------------------
$URLString:=""
$URL:=cs:C1710.URL.new($URLString)
$URL.host:="www.example.com"
$URL.port:=8080
$URL.path:="path/to/resource"
$URL.addQueryParameter("query=param")
$URL.addQueryParameter("q2=v2")
$URL.addQueryParameter("q3"; "v3")
$URL.addQueryParameter({name: "q4"; value: "v4"})

ASSERT:C1129($URL.scheme="")
ASSERT:C1129($URL.host="www.example.com")
ASSERT:C1129($URL.port=8080)
ASSERT:C1129($URL.path="/path/to/resource")
ASSERT:C1129($URL.query="query=param&q2=v2&q3=v3&q4=v4")
$URLString:=$URL.toString()

//--------------------------------------------------------
$URLString:="http://www.example.com:8080/path/to/resource?query=param#hash"
$URL:=cs:C1710.URL.new("")
$URL.parse($URLString)

ASSERT:C1129($URL.scheme="http")
ASSERT:C1129($URL.host="www.example.com")
ASSERT:C1129($URL.port=8080)
ASSERT:C1129($URL.path="/path/to/resource")
ASSERT:C1129($URL.query="query=param")
ASSERT:C1129($URL.ref="hash")
ASSERT:C1129($URL.toString()=$URLString)
