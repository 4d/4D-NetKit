//%attributes = {"invisible":true}
#DECLARE($inString : Text)->$result : Text

var $string : Text:=Lowercase($inString; *)
var $wordSep : Text:=" ,;:=?./\\±_@#&(!)*+=%\t\r\n"
var $uppercase : Boolean:=False
var $length : Integer:=Length($string)
var $i : Integer
$result:=""

For ($i; 1; $length)
	
	var $char : Text:=Substring($string; $i; 1)
	
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
