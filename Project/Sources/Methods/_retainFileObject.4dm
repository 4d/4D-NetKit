//%attributes = {"invisible":true}
#DECLARE($inParameter : Variant) : 4D.File

If (Value type($inParameter)#Is undefined)
	
	var $platformPath : Text
	var $file : 4D.File
	
	If ((Value type($inParameter)=Is object) && \
		(OB Instance of($inParameter; 4D.File)))
		$platformPath:=$inParameter.platformPath
	Else 
		$platformPath:=String($inParameter)
	End if 
	$file:=File($platformPath; fk platform path)
	If ($file.exists)
		return $file
	End if 
End if 

return Null