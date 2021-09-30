//%attributes = {"invisible":true}
#DECLARE($inString : Text)->$result : Text

var $string; $wordSep; $char : Text
var $uppercase : Boolean
var $i; $length : Integer

$string:=Lowercase:C14($inString; *)
$wordSep:=" ,;:=?./\\±_@#&(!)*+=%\t\r\n"
$uppercase:=False:C215
$length:=Length:C16($string)
$result:=""

For ($i; 1; $length)
	$char:=Substring:C12($string; $i; 1)
	
	Case of 
		: (Position:C15($char; $wordSep; *)>0)
			$uppercase:=True:C214
			
		Else 
			If ($uppercase)
				$result:=$result+Uppercase:C13($char)
			Else 
				$result:=$result+$char
			End if 
			$uppercase:=False:C215
	End case 
End for 
