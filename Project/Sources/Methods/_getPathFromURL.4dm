//%attributes = {"invisible":true}
#DECLARE($URL : Text)->$path : Text

ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)

If (Match regex:C1019("(?mi-s)^(?:https?:\\/\\/)?(?:[^?\\/\\s]+[?\\/])(.*)"; $URL; 1; $pos; $len))
	
	If (Size of array:C274($pos)>0)
		$path:="/"+Substring:C12($URL; $pos{1}; $len{1})
	End if 
	
End if 
