//%attributes = {"invisible":true}
#DECLARE() : Object

var $stack : Object

C_LONGINT:C283(Error; Error line; $i)
C_TEXT:C284(Error method; Error formula)

$stack:=New object:C1471("error"; Error; \
"line"; Error line; \
"method"; Error method; \
"formula"; Error formula)

ARRAY LONGINT:C221($arrCodes; 0)
ARRAY TEXT:C222($arrComponents; 0)
ARRAY TEXT:C222($arrDescriptions; 0)

GET LAST ERROR STACK:C1015($arrCodes; $arrComponents; $arrDescriptions)

If (Size of array:C274($arrCodes)>0)
	
	$stack.errors:=New collection:C1472
	
	For ($i; 1; Size of array:C274($arrCodes))
		$stack.errors.push(New object:C1471("code"; $arrCodes{$i}; \
			"component"; $arrComponents{$i}; \
			"description"; $arrDescriptions{$i}))
	End for 
	
End if 

return $stack
