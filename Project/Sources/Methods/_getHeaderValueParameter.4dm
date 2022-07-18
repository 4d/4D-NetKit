//%attributes = {"invisible":true}
#DECLARE($headerValue; $paramName; $defaultValue : Text)->$paramValue : Text

var $startPos; $endPos : Integer
var $pattern : Text

ARRAY LONGINT:C221($foundPosArr; 0)
ARRAY LONGINT:C221($foundLenArr; 0)

$pattern:=$paramName+"=(\"|)([A-Za-z0-9-\\/\\:;??=&\\.]+)(\"|)"

If (Match regex:C1019($pattern; $headerValue; 1; $foundPosArr; $foundLenArr))
	If (Size of array:C274($foundPosArr)=3)
		If ($foundLenArr{2}>0)
			$startPos:=$foundPosArr{2}
			$endPos:=$startPos+$foundLenArr{2}
		End if 
	End if 
End if 
If (($startPos>0) & ($endPos>$startPos))
	$paramValue:=Substring:C12($headerValue; $startPos; $endPos-$startPos)
Else 
	$paramValue:=$defaultValue
End if 
