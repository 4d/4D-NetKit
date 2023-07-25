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
	var $files; $folders; $handled : Collection
	var $file; $folder : Object
	
	$handled:=New collection
	
	// Copy Sources
	$sourceFolder:=Folder(Structure file; fk platform path)
	$sourceFolder:=Folder($sourceFolder.parent.platformPath+"Sources"; fk platform path)
	$targetFolder:=Folder(Application file; fk platform path)
	$targetFolder:=Folder($targetFolder.parent.parent.parent.parent.parent.platformPath+\
		"4DComponents"+Folder separator+"User Components"+Folder separator+"4D NetKit"+\
		Folder separator+"Project"+Folder separator+"Sources"; \
		fk platform path)
	
	$files:=$sourceFolder.files(fk ignore invisible)
	For each ($file; $files)
		$result:=$file.copyTo($targetFolder; fk overwrite)
		If ($result=Null)
			break
		Else 
			$handled.push($result.fullName)
		End if 
	End for each 
	
	$folders:=$sourceFolder.folders()
	For each ($folder; $folders)
		$result:=$folder.copyTo($targetFolder; fk overwrite)
		If ($result=Null)
			break
		Else 
			$files:=Folder($result.platformPath; 1).files().flatMap(Formula(New collection($1.value.fullName)))
			$handled:=$handled.combine($files)
		End if 
	End for each 
	
	// Copy Resources
	If ($result#Null)
		$sourceFolder:=Folder(Structure file; fk platform path)
		$sourceFolder:=Folder($sourceFolder.parent.parent.platformPath+"Resources"; fk platform path)
		$targetFolder:=Folder(Application file; fk platform path)
		$targetFolder:=Folder($targetFolder.parent.parent.parent.parent.parent.platformPath+\
			"4DComponents"+Folder separator+"User Components"+Folder separator+"4D NetKit"+\
			Folder separator+"Resources"; \
			fk platform path)
		
		$files:=$sourceFolder.files(fk ignore invisible)
		For each ($file; $files)
			$result:=$file.copyTo($targetFolder; fk overwrite)
			If ($result=Null)
				break
			Else 
				$handled.push($result.fullName)
			End if 
		End for each 
		
		$folders:=$sourceFolder.folders()
		For each ($folder; $folders)
			$result:=$folder.copyTo($targetFolder; fk overwrite)
			If ($result=Null)
				break
			Else 
				$files:=Folder($result.platformPath; 1).files().flatMap(Formula(New collection($1.value.fullName)))
				$handled:=$handled.combine($files)
			End if 
		End for each 
	End if 
	
	$status:=New object("success"; ($result#Null); "filesCopied"; $handled)
End if 

ALERT(JSON Stringify($status; *))
