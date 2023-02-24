//%attributes = {"invisible":true}
#DECLARE($inParameter : Variant)->$file : 4D:C1709.File

If (Value type:C1509($inParameter)#Is undefined:K8:13)
	var $platformPath : Text
	If ((Value type:C1509($inParameter)=Is object:K8:27) && \
		(OB Instance of:C1731($inParameter; 4D:C1709.File)))
		$platformPath:=$inParameter.platformPath
	Else 
		$platformPath:=String:C10($inParameter)
	End if 
	If (File:C1566($platformPath).exists)
		$file:=File:C1566($platformPath; fk platform path:K87:2)
	End if 
End if 
