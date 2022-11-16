//%attributes = {}
var $builder : cs:C1710._Build

$builder:=cs:C1710._Build.new()
var $error : Object
$error:=$builder.Compile()
If ($error.success=True:C214)
	$error:=$builder.Build()
End if 

If ($error.success=True:C214)
	$error:=$builder.InstallComponent()
End if 

If ($error.success=False:C215)
	ALERT:C41(JSON Stringify:C1217($error; *))
Else 
	RESTART 4D:C1292
End if 

