//%attributes = {}
/*
Used by Dev Only and with a sources hierarchy such as:
- //repos/4D-NetKit/Project/Sources/ (source folder)
- //repos/4edimension/4DComponents/User Components/4D NetKit/Project/Sources/ (target folder)
*/

var $status : Object
$status:=Compile project:C1760

If ($status.success=True:C214)
	
	var $sourceFolder; $targetFolder; $result : 4D:C1709.Folder
	var $files; $folders; $handled : Collection
	var $file; $folder : Object
	
	$handled:=New collection:C1472
	
	// Copy Sources
	$sourceFolder:=Folder:C1567(Structure file:C489; fk platform path:K87:2)
	$sourceFolder:=Folder:C1567($sourceFolder.parent.platformPath+"Sources"; fk platform path:K87:2)
	$targetFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2)
	$targetFolder:=Folder:C1567($targetFolder.parent.parent.parent.parent.parent.platformPath+\
		"4DComponents"+Folder separator:K24:12+"User Components"+Folder separator:K24:12+"4D NetKit"+\
		Folder separator:K24:12+"Project"+Folder separator:K24:12+"Sources"; \
		fk platform path:K87:2)
	
	$files:=$sourceFolder.files(fk ignore invisible:K87:22)
	For each ($file; $files)
		$result:=$file.copyTo($targetFolder; fk overwrite:K87:5)
		If ($result=Null:C1517)
			break
		Else 
			$handled.push($result.fullName)
		End if 
	End for each 
	
	$folders:=$sourceFolder.folders()
	For each ($folder; $folders)
		$result:=$folder.copyTo($targetFolder; fk overwrite:K87:5)
		If ($result=Null:C1517)
			break
		Else 
			$files:=Folder:C1567($result.platformPath; 1).files().flatMap(Formula:C1597(New collection:C1472($1.value.fullName)))
			$handled:=$handled.combine($files)
		End if 
	End for each 
	
	// Copy Resources
	If ($result#Null:C1517)
		$sourceFolder:=Folder:C1567(Structure file:C489; fk platform path:K87:2)
		$sourceFolder:=Folder:C1567($sourceFolder.parent.parent.platformPath+"Resources"; fk platform path:K87:2)
		$targetFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2)
		$targetFolder:=Folder:C1567($targetFolder.parent.parent.parent.parent.parent.platformPath+\
			"4DComponents"+Folder separator:K24:12+"User Components"+Folder separator:K24:12+"4D NetKit"+\
			Folder separator:K24:12+"Resources"; \
			fk platform path:K87:2)
		
		$files:=$sourceFolder.files(fk ignore invisible:K87:22)
		For each ($file; $files)
			$result:=$file.copyTo($targetFolder; fk overwrite:K87:5)
			If ($result=Null:C1517)
				break
			Else 
				$handled.push($result.fullName)
			End if 
		End for each 
		
		$folders:=$sourceFolder.folders()
		For each ($folder; $folders)
			$result:=$folder.copyTo($targetFolder; fk overwrite:K87:5)
			If ($result=Null:C1517)
				break
			Else 
				$files:=Folder:C1567($result.platformPath; 1).files().flatMap(Formula:C1597(New collection:C1472($1.value.fullName)))
				$handled:=$handled.combine($files)
			End if 
		End for each 
	End if 
	
	$status:=New object:C1471("success"; ($result#Null:C1517); "filesCopied"; $handled)
End if 

ALERT:C41(JSON Stringify:C1217($status; *))
