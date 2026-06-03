//%attributes = {"invisible":true,"shared":true}
#DECLARE() : Object

var $startupParam : Text:=""
var $dbParamResult : Real:=Get database parameter(User param value; $startupParam)

var $config : Object
If (Length($startupParam)>0)
	$config:=Try(JSON Parse($startupParam))
Else 
	$config:={}
End if 
If (Value type($config)#Is object)
	$config:={}
End if 

var $options : Object:={}
$options.typeInference:=(Length(String($config.typeInference))>0) ? String($config.typeInference) : "direct"

If (Value type($config.targets)=Is collection)
	$options.targets:=$config.targets
Else 
	var $targetsText : Text:=String($config.targets)
	If (Length($targetsText)>0)
		$options.targets:=Split string($targetsText; ","; sk trim spaces)
	End if 
End if 

var $failOnWarning : Boolean:=Bool($config.failOnWarning)
var $reportPath : Text:=(Length(String($config.reportPath))>0) ? String($config.reportPath) : "ciCompileReport.json"

// Delete previous result files to avoid stale data from a previous compilation
var $reportFile : 4D.File:=Folder(fk database folder).file($reportPath)
If ($reportFile.exists)
	$reportFile.delete()
End if 

var $startTime : Text:=Timestamp
var $startMs : Real:=Milliseconds

var $status : Object:=Compile project($options)

var $duration : Real:=(Milliseconds-$startMs)

var $hasErrors : Boolean:=False
var $hasWarnings : Boolean:=False
var $errors : Collection:=[]
var $warnings : Collection:=[]

If (Value type($status.errors)=Is collection)
	var $entry : Object
	For each ($entry; $status.errors)
		If (Bool($entry.isError))
			$hasErrors:=True
			$errors.push($entry)
		Else 
			$hasWarnings:=True
			$warnings.push($entry)
		End if 
	End for each 
End if 

var $success : Boolean:=Bool($status.success) & (Not($hasErrors)) & (Not($failOnWarning & $hasWarnings))
var $4dVersion : Text:=Application version(*)
var $projectName : Text:=File(Structure file; fk platform path).name
$status.errors:=$errors
$status.warnings:=$warnings
var $result : Object:=New object("success"; $success; "hasErrors"; $hasErrors; "hasWarnings"; $hasWarnings; "errorsCount"; $errors.length; "warningsCount"; $warnings.length; "failOnWarning"; $failOnWarning; "timestamp"; $startTime; "duration"; $duration; "4dVersion"; $4dVersion; "projectName"; $projectName; "compileOptions"; $options; "status"; $status)

// Write machine-readable report for CI inspection.
$reportFile.setText(JSON Stringify($result; *))

return $result