//%attributes = {"invisible":true}
/*
    Largely inspired from url_decode.4dm by Vincent de Lachaux
    See: https://github.com/4d/4D-SVG project
*/
#DECLARE($inURL : Text)->$result : Text

var $i : Integer
var $hexValues : Text:="123456789ABCDEF"
var $urlLength : Integer:=Length($inURL)

For ($i; 1; $urlLength; 1)
	
	If ($inURL[[$i]]="%")
		
		var $c : Integer:=(Position(Substring($inURL; $i+1; 1); $hexValues)*16)+(Position(Substring($inURL; $i+2; 1); $hexValues))
		$result+=Char($c)
		$i+=2
		
	Else 
		
		$result+=$inURL[[$i]]
		
	End if 
End for 

return $result
