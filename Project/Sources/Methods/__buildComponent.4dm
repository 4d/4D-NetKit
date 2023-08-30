//%attributes = {}
/*
    Used by Dev Only and with a sources hierarchy such as:
    - //repos/4D-NetKit/Project/Sources/ (source folder)
    - //repos/4edimension/4DComponents/User Components/4D NetKit/Project/Sources/ (target folder)
*/

var $status : Object
$status:=Compile project

If ($status.success=True)
	
	var $sourceFolder; $targetFolder; $result : 4D.Folder
	var $netKitFolder : 4D.Folder
	
	$targetFolder:=Folder(Application file; fk platform path)
	$netKitFolder:=Folder($targetFolder.parent.parent.parent.parent.parent.platformPath+\
		"4DComponents"+Folder separator+"User Components"+Folder separator+"4D NetKit"+\
		Folder separator; fk platform path)
	
	If (Not($netKitFolder.exists))
		
		var $netKitFullPath : Text
		$netKitFullPath:=Select folder("Select 4D NetKit component folder"; $targetFolder.platformPath)
		$netKitFolder:=Folder($netKitFullPath; fk platform path)
	End if 
	
	// Copy Sources
	$sourceFolder:=Folder(Structure file; fk platform path)
	$sourceFolder:=Folder($sourceFolder.parent.platformPath+"Sources"; fk platform path)
	$targetFolder:=Folder($netKitFolder.platformPath+"Project"+Folder separator; fk platform path)
	
	$result:=$sourceFolder.copyTo($targetFolder; fk overwrite)
	
	// Copy Resources
	If ($result#Null)
		
		$sourceFolder:=Folder(Structure file; fk platform path)
		$sourceFolder:=Folder($sourceFolder.parent.parent.platformPath+"Resources"; fk platform path)
		$targetFolder:=Folder($netKitFolder.platformPath; fk platform path)
		
		$result:=$sourceFolder.copyTo($targetFolder; fk overwrite)
	End if 
	
	$status:=New object("success"; ($result#Null))
End if 

ALERT(JSON Stringify($status; *))
