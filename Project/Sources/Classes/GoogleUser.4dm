Class extends _GoogleAPI


Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider; "https://people.googleapis.com/v1/")
	
	This._internals.defaultPersonFields:=["names"; "emailAddresses"]
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _get($inResourceName : Text; $inPersonFields : Variant) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	var $resourceName : Text:=Length(String($inResourceName))>0 ? $inResourceName : ""
	var $personFields : Text
	
	If (Position("people/"; $resourceName)=0)
		$resourceName:="people/"+$resourceName
	End if 
	
	Case of 
		: ((Value type($inPersonFields)=Is collection) && ($inPersonFields.length>0))
			$personFields:=$inPersonFields.join(","; ck ignore null or empty)
		: ((Value type($inPersonFields)=Is text) && (Length(String($inPersonFields))>0))
			$personFields:=$inPersonFields
		Else 
			$personFields:=This._internals.defaultPersonFields.join(","; ck ignore null or empty)
	End case 
	
	$URL+=$resourceName+"?personFields="+$personFields
	
	var $headers : Object:={Accept: "application/json"}
	var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
	
	var $urlParams; $personFields : Text
	var $delimiter : Text:="?"
	var $sources : Collection:=Null
	var $mergeSources : Collection:=Null
	
	Case of 
		: ((Value type($inParameters.select)=Is collection) && ($inParameters.select.length>0))
			$personFields:=$inParameters.select.join(","; ck ignore null or empty)
		: ((Value type($inParameters.select)=Is text) && (Length(String($inParameters.select))>0))
			$personFields:=$inParameters.select
		Else 
			$personFields:=This._internals.defaultPersonFields.join(","; ck ignore null or empty)
	End case 
	$urlParams+=$delimiter+"readMask="+$personFields
	$delimiter:="&"
	
	Case of 
		: ((Value type($inParameters.sources)=Is collection) && ($inParameters.sources.length>0))
			$sources:=$inParameters.sources
		: ((Value type($inParameters.sources)=Is text) && (Length(String($inParameters.sources))>0))
			$sources:=Split string($inParameters.sources; ","; sk ignore empty strings+sk trim spaces)
		Else 
			$sources:=["DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE"]
	End case 
	If (($sources#Null) && ($sources.length>0))
		$urlParams+=($delimiter+"sources="+$sources.join("&sources="; ck ignore null or empty))
	End if 
	
	Case of 
		: ((Value type($inParameters.mergeSources)=Is collection) && ($inParameters.mergeSources.length>0))
			$mergeSources:=$inParameters.mergeSources
		: ((Value type($inParameters.mergeSources)=Is text) && (Length(String($inParameters.mergeSources))>0))
			$sources:=Split string($inParameters.mergeSources; ","; sk ignore empty strings+sk trim spaces)
	End case 
	If (($mergeSources#Null) && ($mergeSources.length>0))
		$urlParams+=($delimiter+"mergeSources="+$mergeSources.join("&mergeSources="; ck ignore null or empty))
	End if 
	
	If (OB Is defined($inParameters; "top") && (Num($inParameters.top)>0))
		$urlParams+=($delimiter+"pageSize="+String($inParameters.top))
	End if 
	
	If (OB Is defined($inParameters; "requestSyncToken") && (Value type($inParameters.requestSyncToken)=Is boolean))
		$urlParams+=($delimiter+"requestSyncToken="+(Bool($inParameters.requestSyncToken) ? "true" : "false"))
	End if 
	
	If (OB Is defined($inParameters; "pageToken") && (Value type($inParameters.pageToken)=Is text) && (Length(String($inParameters.pageToken))>0))
		$urlParams+=($delimiter+"pageToken="+String($inParameters.pageToken))
	End if 
	
	If (OB Is defined($inParameters; "syncToken") && (Value type($inParameters.syncToken)=Is text) && (Length(String($inParameters.syncToken))>0))
		$urlParams+=($delimiter+"syncToken="+String($inParameters.syncToken))
	End if 
	
	return $urlParams
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function getCurrent($inPersonFields : Variant) : Object
	
	return This._get("me"; $inPersonFields)
	
	
	// ----------------------------------------------------
	
	
Function get($inResourceName : Text; $inPersonFields : Variant) : Object
	
	return This._get($inResourceName; $inPersonFields)
	
	
	// ----------------------------------------------------
	
	
Function list($inParameters : Object) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()+"people:listDirectoryPeople"+This._getURLParamsFromObject($inParameters)
	var $headers : Object:={Accept: "application/json"}
	var $requestSyncToken : Boolean:=OB Is defined($inParameters; "requestSyncToken") ? Bool($inParameters.requestSyncToken) : False
	
	return cs.GoogleUserList.new(This._getOAuth2Provider(); $URL; $headers; $requestSyncToken)
