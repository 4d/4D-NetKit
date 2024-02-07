//%attributes = {"invisible":true}
#DECLARE($URL : Text; $paramName : Text)->$paramValue : Text

var $posQuery : Integer:=Position("?"; $URL)
If ($posQuery>0)
	
	var $queryString : Text:=Substring($URL; $posQuery+1)
	var $parameters : Collection:=Split string($queryString; "&"; sk ignore empty strings)
	var $parameter : Text
	
	For each ($parameter; $parameters)
		
		var $values : Collection:=Split string($parameter; "=")
		
		If ($values.length=2)
			If ($values[0]=$paramName)
				$paramValue:=$values[1]
				break
			End if 
		End if 
	End for each 
End if 
