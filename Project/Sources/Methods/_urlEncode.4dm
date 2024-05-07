//%attributes = {"invisible":true}
#DECLARE($value : Text)->$escaped : Text

var $i; $j : Integer
var $length : Integer:=Length($value)

For ($i; 1; $length)
	
	var $char : Text:=Substring($value; $i; 1)
	var $code : Integer:=Character code($char)
	var $shouldEscape : Boolean:=False
	
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
		var $data : Blob
		CONVERT FROM TEXT($char; "utf-8"; $data)
		For ($j; 0; BLOB size($data)-1)
			var $hex : Text:=String($data{$j}; "&x")
			$escaped:=$escaped+"%"+Substring($hex; Length($hex)-1)
		End for 
	Else 
		$escaped:=$escaped+$char
	End if 
End for 
