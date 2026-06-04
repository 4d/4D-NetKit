//%attributes = {"invisible":true}
/**
 * @method _ciCompileProject
 * @description CI compilation entry point. Reads `typeInference` and `targets` from
 *   the `--user-param` startup parameter, compiles the project via `Compile project`,
 *   and writes a JSON report to `ciCompileReport.json` (path configurable via
 *   `reportPath` in the startup parameter).
 * @returns {Object} Report object:
 *   - `success` {Boolean} — `True` when compilation succeeded with no errors
 *   - `hasErrors` {Boolean} — `True` when at least one error was found
 *   - `hasWarnings` {Boolean} — `True` when at least one warning was found
 *   - `errorsCount` {Integer} — Number of compilation errors
 *   - `warningsCount` {Integer} — Number of warnings
 *   - `failOnWarning` {Boolean} — Whether warnings were treated as failures
 *   - `timestamp` {Text} — ISO 8601 start time
 *   - `duration` {Real} — Elapsed compilation time in milliseconds
 *   - `4dVersion` {Text} — 4D application version string
 *   - `projectName` {Text} — Project file name
 *   - `compileOptions` {Object} — Options passed to `Compile project`
 *   - `status` {Object} — Raw output of `Compile project`
 */
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