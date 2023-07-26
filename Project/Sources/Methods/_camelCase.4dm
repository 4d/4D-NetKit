//%attributes = {"invisible":true}
#DECLARE($inString : Text)->$result : Text

var $string; $wordSep; $char : Text
var $uppercase : Boolean
var $i; $length : Integer

$string:=Lowercase($inString; *)
$wordSep:=" ,;:=?./\\±_@#&(!)*+=%\t\r\n"
$uppercase:=False
$length:=Length($string)
$result:=""

For ($i; 1; $length)
	$char:=Substring($string; $i; 1)
	
	Case of 
		: (Position($char; $wordSep; *)>0)
			$uppercase:=True
			
		Else 
			If ($uppercase)
				$result:=$result+Uppercase($char)
			Else 
				$result:=$result+$char
			End if 
			$uppercase:=False
	End case 
End for 
