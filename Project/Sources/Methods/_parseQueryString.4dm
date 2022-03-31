//%attributes = {}
#DECLARE($queryString : Text)->$result : Object
var $keyValues; $items : Collection
var $keyValue : Text

$result:=New object:C1471()

If ($queryString#"")
	$keyValues:=Split string:C1554($queryString; "&")
	
	For each ($keyValue; $keyValues)
		$items:=Split string:C1554($keyValue; "=")
		
		If ($items.length=2)
			$result[$items[0]]:=$items[1]
		End if 
		
	End for each 
End if 