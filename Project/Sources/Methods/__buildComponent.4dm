//%attributes = {}
/*
    Used by Dev Only and with a sources hierarchy such as:
    - //repos/4D-NetKit/Project/Sources/ (source folder)
    - //repos/4edimension/4DComponents/User Components/4D NetKit/Project/Sources/ (target folder)
*/

var $errorFile:=File(Folder(fk logs folder).platformPath+"compilationErrors.json"; fk platform path)
If ($errorFile.exists)
	$errorFile.delete()
End if 

var $status : Object:=Compile project({typeInference: "all"})

If ($status.success=True)
	
	var $targetFolder : 4D.Folder:=Folder(Application file; fk platform path)
	var $netKitFolder : 4D.Folder:=Folder($targetFolder.parent.parent.parent.parent.parent.platformPath+\
		"4DComponents"+Folder separator+"User Components"+Folder separator+"4D NetKit"+\
		Folder separator; fk platform path)
	
	If (Not($netKitFolder.exists))
		
		var $netKitFullPath : Text:=Select folder("Select 4D NetKit component folder"; $targetFolder.platformPath)
		$netKitFolder:=Folder($netKitFullPath; fk platform path)
	End if 
	
	// Copy Sources
	var $sourceFolder : 4D.Folder:=Folder(Structure file; fk platform path)
	$sourceFolder:=Folder($sourceFolder.parent.platformPath+"Sources"; fk platform path)
	$targetFolder:=Folder($netKitFolder.platformPath+"Project"+Folder separator; fk platform path)
	
	var $result : 4D.Folder:=$sourceFolder.copyTo($targetFolder; fk overwrite)
	
	// Copy Resources
	If ($result#Null)
		
		$sourceFolder:=Folder(Structure file; fk platform path)
		$sourceFolder:=Folder($sourceFolder.parent.parent.platformPath+"Resources"; fk platform path)
		$targetFolder:=Folder($netKitFolder.platformPath; fk platform path)
		
		$result:=$sourceFolder.copyTo($targetFolder; fk overwrite)
	End if 
	
	$status:={success: Bool($result#Null)}
Else 
	TEXT TO DOCUMENT($errorFile.platformPath; JSON Stringify($status; *))
	SHOW ON DISK($errorFile.platformPath)
End if 

ALERT(JSON Stringify($status))
