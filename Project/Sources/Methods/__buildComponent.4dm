//%attributes = {}
/*
    Used by Dev Only and with a sources hierarchy such as:
    - //repos/4D-NetKit/Project/Sources/ (source folder)
    - //repos/4edimension/4DComponents/User Components/4D NetKit/Project/Sources/ (target folder)
*/

var $errorFile : 4D.File:=File("/LOGS/compilationErrors.json")
If ($errorFile.exists)
	$errorFile.delete()
End if 

var $status : Object:=Compile project({typeInference: "all"})

If ($status.success=True)
	
	var $targetFolder : 4D.Folder:=Folder(Application file; fk platform path).parent
	var $netKitFolder : 4D.Folder:=Folder($targetFolder.parent.parent.parent.parent.platformPath+\
		"4DComponents"+Folder separator+"User Components"+Folder separator+"4D NetKit"+\
		Folder separator; fk platform path)
	
	If (Not($netKitFolder.exists))
		var $netKitFullPath : Text:=Select folder("Select 4D NetKit component folder"; $targetFolder.platformPath)
		$netKitFolder:=Folder($netKitFullPath; fk platform path)
	End if 
	
	// Copy Sources
	var $sourceFolder : 4D.Folder:=Folder("/PACKAGE/Project/Sources/")
	$targetFolder:=Folder($netKitFolder.platformPath+"Project"+Folder separator; fk platform path)
	If (Not($targetFolder.exists))
		$targetFolder.create()
	End if 
	
	var $result : Object:=$sourceFolder.copyTo($targetFolder; fk overwrite)
	
	// Copy Resources
	If ($result#Null)
		$sourceFolder:=Folder("/PACKAGE/Resources/")
		$targetFolder:=Folder($netKitFolder.platformPath; fk platform path)
		$result:=$sourceFolder.copyTo($targetFolder; fk overwrite)
	End if 
	
	// Copy Documentation
	If ($result#Null)
		$sourceFolder:=Folder("/PACKAGE/Documentation/")
		$targetFolder:=Folder($netKitFolder.platformPath; fk platform path)
		$result:=$sourceFolder.copyTo($targetFolder; fk overwrite)
	End if 
	
	// Copy make.json
	If ($result#Null)
		var $makeJsonFile : 4D.File:=File("/PACKAGE/make.json")
		$targetFolder:=Folder($netKitFolder.platformPath; fk platform path)
		$result:=$makeJsonFile.copyTo($targetFolder; fk overwrite)
	End if 
	
	$status:={success: Bool($result#Null)}
Else 
	TEXT TO DOCUMENT($errorFile.platformPath; JSON Stringify($status; *))
	SHOW ON DISK($errorFile.platformPath)
End if 

ALERT(JSON Stringify($status))
