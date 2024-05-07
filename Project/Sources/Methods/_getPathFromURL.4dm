//%attributes = {"invisible":true}
#DECLARE($URL : Text)->$path : Text

ARRAY LONGINT($pos; 0)
ARRAY LONGINT($len; 0)

var $pattern : Text:="(?mi-s)^(https?|wss?)://.*(:\\d*)(/?.*)"  //was "(?mi-s)^(?:https?:\\/\\/)?(?:[^?\\/\\s]+[?\\/])(.*)"

If (Match regex($pattern; $URL; 1; $pos; $len))
	
	If (Size of array($pos)>2)
		$path:=Substring($URL; $pos{3}+1; $len{3}-1)
	End if 
	
	$path:="/"+$path
	
End if 
