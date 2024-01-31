//%attributes = {"invisible":true}
#DECLARE($value : Text)->$escaped : Text

var $i; $j; $code; $length : Integer
var $char; $hex : Text
var $shouldEscape : Boolean
var $data : Blob

$length:=Length($value)
For ($i; 1; $length)
	$char:=Substring($value; $i; 1)
	$code:=Character code($char)
	$shouldEscape:=False
	
	Case of 
		: ($code=45)
		: ($code=46)
		: ($code>47) && ($code<58)
		: ($code>63) && ($code<91)
		: ($code=95)
		: ($code>96) && ($code<123)
		: ($code=126)
		Else 
			$shouldEscape:=True
	End case 
	
	If ($shouldEscape)
		CONVERT FROM TEXT($char; "utf-8"; $data)
		For ($j; 0; BLOB size($data)-1)
			$hex:=String($data{$j}; "&x")
			$escaped:=$escaped+"%"+Substring($hex; Length($hex)-1)
		End for 
	Else 
		$escaped:=$escaped+$char
	End if 
End for 
