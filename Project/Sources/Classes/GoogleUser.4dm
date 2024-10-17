Class extends _GoogleAPI


Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider; "https://people.googleapis.com/v1/")
	
	This._internals.defaultPersonFields:=["names"; "emailAddresses"]
	This._internals.defaultSources:=["DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE"]
	This._internals.defaultMergeSources:=["DIRECTORY_MERGE_SOURCE_TYPE_CONTACT"]
	
	
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
	
	var $urlParams; $personFields; $sources : Text
	var $delimiter : Text:="?"
	
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
			$sources:=$inParameters.sources.join("&sources="; ck ignore null or empty)
		: ((Value type($inParameters.sources)=Is text) && (Length(String($inParameters.sources))>0))
			$sources:=$inParameters.sources
		Else 
			$sources:=This._internals.defaultSources.join("&sources="; ck ignore null or empty)
	End case 
	$urlParams+=($delimiter+"sources="+$sources)
	
	Case of 
		: ((Value type($inParameters.mergeSources)=Is collection) && ($inParameters.mergeSources.length>0))
			$urlParams+=($delimiter+"mergeSources="+$inParameters.mergeSources.join("&mergeSources="; ck ignore null or empty))
		: ((Value type($inParameters.mergeSources)=Is text) && (Length(String($inParameters.mergeSources))>0))
			$urlParams+=($delimiter+"mergeSources="+$inParameters.mergeSources)
		else
			$sources:=This._internals.defaultMergeSources.join("&mergeSources="; ck ignore null or empty)
	End case 
	
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
