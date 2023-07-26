//%attributes = {"invisible":true}
#DECLARE($URL : Text)->$port : Integer

var $pattern : Text

ARRAY LONGINT($pos; 0)
ARRAY LONGINT($len; 0)

$pattern:="(?mi-s)^(https?|wss?)://.*(:\\d*)/?.*"

If (Match regex($pattern; $URL; 1; $pos; $len))
	
	var $scheme : Text
	
	$scheme:=Substring($URL; $pos{1}; $len{1})
	If (Size of array($pos)>1)
		$port:=Num(Substring($URL; $pos{2}+1; $len{2}-1))
	Else 
		$port:=Choose((($scheme="http") | ($scheme="ws")); 80; 443)
	End if 
	
Else 
	$port:=Choose((($URL="http:@") | ($URL="ws:@")); 80; 443)
End if 
