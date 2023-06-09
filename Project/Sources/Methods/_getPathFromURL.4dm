//%attributes = {"invisible":true}
#DECLARE($URL : Text)->$path : Text

var $pattern : Text

ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)

$pattern:="(?mi-s)^(https?|wss?)://.*(:\\d*)(/?.*)"  //was "(?mi-s)^(?:https?:\\/\\/)?(?:[^?\\/\\s]+[?\\/])(.*)"

If (Match regex:C1019($pattern; $URL; 1; $pos; $len))
	
	If (Size of array:C274($pos)>2)
		$path:=Substring:C12($URL; $pos{3}+1; $len{3}-1)
	End if 
	
	$path:="/"+$path
	
End if 
