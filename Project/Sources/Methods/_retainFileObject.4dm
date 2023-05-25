//%attributes = {"invisible":true}
#DECLARE($inParameter : Variant) : 4D:C1709.File

If (Value type:C1509($inParameter)#Is undefined:K8:13)
	
	var $platformPath : Text
	var $file : 4D:C1709.File
	
	If ((Value type:C1509($inParameter)=Is object:K8:27) && \
		(OB Instance of:C1731($inParameter; 4D:C1709.File)))
		$platformPath:=$inParameter.platformPath
	Else 
		$platformPath:=String:C10($inParameter)
	End if 
	$file:=File:C1566($platformPath; fk platform path:K87:2)
	If ($file.exists)
		return $file
	End if 
End if 

return Null:C1517