//%attributes = {"invisible":true}
#DECLARE($URL : Text)->$port : Integer

ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)

If (Match regex:C1019("(?mi-s)^(https?|wss?)://.*(:\\d*)/"; $URL; 1; $pos; $len))
	
	var $scheme : Text
	
	$scheme:=Substring:C12($URL; $pos{1}; $len{1})
	If (Size of array:C274($pos)>1)
		$port:=Num:C11(Substring:C12($URL; $pos{2}+1; $len{2}-1))
	Else 
		$port:=Choose:C955((($scheme="http") | ($scheme="ws")); 80; 443)
	End if 
	
Else 
	$port:=Choose:C955((($URL="http:@") | ($URL="ws:@")); 80; 443)
End if 
