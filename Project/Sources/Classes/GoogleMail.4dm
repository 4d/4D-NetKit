Class extends _BaseClass

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "Google"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _returnStatus($inAdditionalInfo : Object)->$status : Object
	
	var $errorStack : Collection
	$errorStack:=Super:C1706._getErrorStack()
	$status:=New object:C1471
	
	If (Not:C34(OB Is empty:C1297($inAdditionalInfo)))
		var $keys : Collection
		var $key : Text
		
		$keys:=OB Keys:C1719($inAdditionalInfo)
		For each ($key; $keys)
			$status[$key]:=$inAdditionalInfo[$key]
		End for each 
	End if 
	
	If ($errorStack.length>0)
		$status.success:=False:C215
		$status.errors:=$errorStack
		$status.statusText:=$errorStack[0].message
	Else 
		$status.success:=True:C214
		$status.statusText:=Super:C1706._getStatusLine()
	End if 
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	return This:C1470._returnStatus(Null:C1517)
	