//%attributes = {"invisible":true}
#DECLARE($headerValue; $paramName; $defaultValue : Text)->$paramValue : Text

$paramValue:=_getParameterValue($headerValue; $paramName)
If (Length($paramValue)=0)
	$paramValue:=$defaultValue
End if 
