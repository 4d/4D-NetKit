//%attributes = {"invisible":true}

#DECLARE($inText : Text)->$result : Text

var $startPos : Integer:=1
var $endPos : Integer:=Length($inText)

While (($startPos<=$endPos) && ($inText[[$startPos]]=" "))
    $startPos+=1
End while 

While (($endPos>=$startPos) && ($inText[[$endPos]]=" "))
    $endPos-=1
End while 

$result:=Substring($inText; $startPos; $endPos-$startPos+1)
