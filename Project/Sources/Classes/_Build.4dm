Class constructor
	This:C1470._SettingsUsed:=""
	This:C1470._Source:=""
	This:C1470._Target:=""
	
	
Function Compile($options : Object)->$error : Object
	If (Count parameters:C259>0)
		$error:=Compile project:C1760($options)
	Else 
		$error:=Compile project:C1760
	End if 
	
	
Function Build($PathToSettings : Text)->$error : Object
	// this function uses LAUNCH EXTERNAL PROCESS and not 4D.SystemWorker to allow v19 LTS to use the class
	If (Count parameters:C259>0)
		This:C1470._SettingsUsed:=$PathToSettings
	Else 
		This:C1470._SettingsUsed:=File:C1566(Build application settings file:K5:60).platformPath
	End if 
	BUILD APPLICATION:C871(This:C1470._SettingsUsed)
	
	var $errortext : Text
	If (OK=0)
		$errortext:=File:C1566(Build application log file:K5:46).getText()
		$error:=New object:C1471("success"; False:C215; "log"; $errortext)
	Else 
		$error:=New object:C1471("success"; True:C214)
	End if 
	
	
Function InstallComponent($sourcepath : Text; $targetpath : Text)->$error : Object
	// if $sourcepath is ommitted, it reads path from settings
	var $settings; $settingsXML; $value; $source; $target; $found : Text
	var $sourceFolder; $targetFolder : 4D:C1709.Folder
	var $sourcefolderfiles : Collection
	
	If (Count parameters:C259=0)
		If (This:C1470._SettingsUsed#"")
			$settings:=File:C1566(This:C1470._SettingsUsed; fk platform path:K87:2).getText()
			$settingsXML:=DOM Parse XML variable:C720($settings)
			If (Is Windows:C1573)
				$Found:=DOM Find XML element:C864($settingsXML; "/Preferences4D/BuildApp/BuildWinDestFolder")
			Else 
				$Found:=DOM Find XML element:C864($settingsXML; "/Preferences4D/BuildApp/BuildMacDestFolder")
			End if 
			If (ok=1)
				var $size : Integer
				DOM GET XML ELEMENT VALUE:C731($Found; $value)
				Case of 
					: ((Is macOS:C1572 & ($value="::@")) || (Is Windows:C1573 & ($value="..@")))
						// cannot use Folder(fk database folder).parent, as we need to go outside of protected area
						$size:=Is macOS:C1572 ? 3 : 4
						$sourceFolder:=Folder:C1567(Get 4D folder:C485(Database folder:K5:14); fk platform path:K87:2)
						$sourceFolder:=Folder:C1567($sourceFolder.parent.platformPath+Substring:C12($value; $size)+"Components"; fk platform path:K87:2)
						$sourcefolderfiles:=$sourceFolder.folders()
						If ($sourcefolderfiles.length>0)
							$source:=$sourcefolderfiles[0].platformPath
						End if 
					: ((Is macOS:C1572 & ($value=":@")) || (Is Windows:C1573 & ($value=".@")))
						$size:=Is macOS:C1572 ? 2 : 3
						$sourceFolder:=Folder:C1567(Folder:C1567(fk database folder:K87:14).platformPath+Substring:C12($value; $size)+"Components"; fk platform path:K87:2)
						$sourcefolderfiles:=$sourceFolder.folders()
						If ($sourcefolderfiles.length>0)
							$source:=$sourcefolderfiles[0].platformPath
						End if 
					Else 
						$source:=$value
				End case 
			End if 
			DOM CLOSE XML:C722($settingsXML)
		End if 
	Else 
		$source:=$sourcepath
	End if 
	This:C1470._Source:=$source
	
	If (Count parameters:C259<2)
		$targetFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2)
		$targetFolder:=Folder:C1567($targetFolder.parent.platformPath+"Components"; fk platform path:K87:2)
		$target:=$targetFolder.platformPath
	Else 
		$target:=$targetpath
	End if 
	This:C1470._Target:=$target
	
	// now we can finally zip
	If (($source#"") & ($target#""))
		
		$sourceFolder:=Folder:C1567($source; fk platform path:K87:2)
		$targetFolder:=Folder:C1567($target; fk platform path:K87:2)
		$targetFolder:=$sourceFolder.copyTo($targetFolder; fk overwrite:K87:5)
		
		$error:=New object:C1471("success"; True:C214)
		
	Else 
		$error:=New object:C1471("success"; False:C215; "reason"; "source or target path empty")
	End if 
	