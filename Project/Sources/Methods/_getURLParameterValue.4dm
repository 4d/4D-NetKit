//%attributes = {"invisible":true}
#DECLARE($URL : Text; $paramName : Text)->$paramValue : Text

var $posQuery : Integer

$posQuery:=Position:C15("?"; $URL)
If ($posQuery>0)
	
	var $queryString : Text
	var $parameter : Text
	var $parameters; $values : Collection
	
	$queryString:=Substring:C12($URL; $posQuery+1)
	$parameters:=Split string:C1554($queryString; "&"; sk ignore empty strings:K86:1)
	
	For each ($parameter; $parameters)
		
		$values:=Split string:C1554($parameter; "=")
		
		If ($values.length=2)
			If ($values[0]=$paramName)
				$paramValue:=$values[1]
				break
			End if 
		End if 
	End for each 
End if 
