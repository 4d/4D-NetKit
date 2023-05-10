Class extends _GoogleAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object)
	
	Super:C1705($inProvider)
	
	This:C1470.mailType:=(Length:C16(String:C10($inParameters.mailType))>0) ? String:C10($inParameters.mailType) : "Google"
	This:C1470.userId:=(Length:C16(String:C10($inParameters.userId))>0) ? String:C10($inParameters.userId) : ""
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function send($inMail : Variant) : Object
	
	return This:C1470._returnStatus(Null:C1517)
	