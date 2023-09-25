//%attributes = {"invisible":true}
#DECLARE($URL : Text; $paramName : Text)->$paramValue : Text

var $posQuery : Integer

$posQuery:=Position("?"; $URL)
If ($posQuery>0)
	
	var $queryString : Text
	var $parameter : Text
	var $parameters; $values : Collection
	
	$queryString:=Substring($URL; $posQuery+1)
	$parameters:=Split string($queryString; "&"; sk ignore empty strings)
	
	For each ($parameter; $parameters)
		
		$values:=Split string($parameter; "=")
		
		If ($values.length=2)
			If ($values[0]=$paramName)
				$paramValue:=$values[1]
				break
			End if 
		End if 
	End for each 
End if 
