//%attributes = {"invisible":true}
If (Not:C34(Is compiled mode:C492))  // for debug purposes
	
	C_LONGINT:C283(Error; Error line)
	C_TEXT:C284(Error method)
	
	ARRAY LONGINT:C221($arrCodes; 0)
	ARRAY TEXT:C222($arrComponents; 0)
	ARRAY TEXT:C222($arrDescriptions; 0)
	
	GET LAST ERROR STACK:C1015($arrCodes; $arrComponents; $arrDescriptions)
End if 
