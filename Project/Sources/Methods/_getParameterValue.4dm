//%attributes = {"invisible":true}
#DECLARE($headerValue : Text; $paramName : Text)->$paramValue : Text

var $startPos; $endPos : Integer
var $pattern : Text

ARRAY LONGINT($foundPosArr; 0)
ARRAY LONGINT($foundLenArr; 0)

$pattern:=$paramName+"=(\"|)([A-Za-z0-9-\\/\\:;??=&\\.]+)(\"|)"

If (Match regex($pattern; $headerValue; 1; $foundPosArr; $foundLenArr))
	If (Size of array($foundPosArr)=3)
		If ($foundLenArr{2}>0)
			$startPos:=$foundPosArr{2}
			$endPos:=$startPos+$foundLenArr{2}
		End if 
	End if 
End if 
If (($startPos>0) & ($endPos>$startPos))
	$paramValue:=Substring($headerValue; $startPos; $endPos-$startPos)
End if 
