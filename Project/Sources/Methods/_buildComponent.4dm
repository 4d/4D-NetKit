//%attributes = {}
/*
Used by Dev Only and with a sources hierarchy such as:
- //repos/4D-NetKit/Project/Sources/ (source folder)
- //repos/4edimension/4DComponents/User Components/4D NetKit/Project/Sources/ (target folder)
*/

var $status : Object
$status:=Compile project:C1760

If ($status.success=True:C214)
	
	var $srcFolder; $destFolder; $res : 4D:C1709.Folder
	var $files; $destFiles : Collection
	var $it : Object
	
	$destFiles:=New collection:C1472
	
	// Copy Sources
	$srcFolder:=Folder:C1567(Structure file:C489; fk platform path:K87:2)
	$srcFolder:=Folder:C1567($srcFolder.parent.platformPath+"Sources"; fk platform path:K87:2)
	$destFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2)
	$destFolder:=Folder:C1567($destFolder.parent.parent.parent.parent.parent.platformPath+\
		"4DComponents"+Folder separator:K24:12+"User Components"+Folder separator:K24:12+"4D NetKit"+\
		Folder separator:K24:12+"Project"+Folder separator:K24:12+"Sources"; \
		fk platform path:K87:2)
	
	$files:=$srcFolder.files(fk ignore invisible:K87:22+fk recursive:K87:7)
	For each ($it; $files)
		$res:=$it.copyTo($destFolder; fk overwrite:K87:5)
		If ($res=Null:C1517)
			break
		Else 
			$destFiles.push($res.fullName)
		End if 
	End for each 
	
	// Copy Resources
	If ($res#Null:C1517)
		$srcFolder:=Folder:C1567(Structure file:C489; fk platform path:K87:2)
		$srcFolder:=Folder:C1567($srcFolder.parent.parent.platformPath+"Resources"; fk platform path:K87:2)
		$destFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2)
		$destFolder:=Folder:C1567($destFolder.parent.parent.parent.parent.parent.platformPath+\
			"4DComponents"+Folder separator:K24:12+"User Components"+Folder separator:K24:12+"4D NetKit"+\
			Folder separator:K24:12+"Resources"; \
			fk platform path:K87:2)
		
		$files:=$srcFolder.files(fk ignore invisible:K87:22+fk recursive:K87:7)
		For each ($it; $files)
			$res:=$it.copyTo($destFolder; fk overwrite:K87:5)
			If ($res=Null:C1517)
				break
			Else 
				$destFiles.push($res.fullName)
			End if 
		End for each 
		
	End if 
	
	$status:=New object:C1471("success"; ($res#Null:C1517); "filesCopied"; $destFiles)
End if 

ALERT:C41(JSON Stringify:C1217($status; *))
