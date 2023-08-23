//%attributes = {"invisible":true}
#DECLARE() : Object

var $stack : Object

C_LONGINT(Error; Error line; $i)
C_TEXT(Error method; Error formula)

$stack:=New object("error"; Error; \
"line"; Error line; \
"method"; Error method; \
"formula"; Error formula)

ARRAY LONGINT($arrCodes; 0)
ARRAY TEXT($arrComponents; 0)
ARRAY TEXT($arrDescriptions; 0)

GET LAST ERROR STACK($arrCodes; $arrComponents; $arrDescriptions)

If (Size of array($arrCodes)>0)
	
	$stack.errors:=New collection
	
	For ($i; 1; Size of array($arrCodes))
		$stack.errors.push(New object("code"; $arrCodes{$i}; \
			"component"; $arrComponents{$i}; \
			"description"; $arrDescriptions{$i}))
	End for 
	
End if 

return $stack
