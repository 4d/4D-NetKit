Class extends _GoogleAPI


Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider; "https://people.googleapis.com/v1/")
	
	This._internals.defaultPersonFields:="names,emailAddresses"
	This._internals.defaultSources:="DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE"
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _get($inResourceName : Text; $inPersonFields : Variant) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	var $resourceName : Text:=Length(String($inResourceName))>0 ? $inResourceName : ""
	var $personFields : Text:=This._internals.defaultPersonFields
	
	If (Position("people/"; $resourceName)=0)
		$resourceName:="people/"+$resourceName
	End if 
	
	Case of 
		: (Type($inPersonFields)=Is collection)
			$personFields:=$inPersonFields.join(",")
		: (Length(String($inPersonFields))>0)
			$personFields:=$inPersonFields
	End case 
	
	$URL+=$resourceName+"?personFields="+$personFields
	
	var $headers : Object:={}
	$headers["Content-Type"]:="application/json"
	var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
	
	return $response
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
	
	var $urlParams : Text:=""
	var $delimiter : Text:="?"
	var $personFields : Text:=This._internals.defaultPersonFields
	var $sources : Text:=This._internals.defaultSources
	
	If (Not(Value type($inParameters.select)=Is undefined))
		Case of 
			: (Type($inParameters.select)=Is collection)
				$personFields:=$inParameters.select.join(",")
			: (Length(String($inParameters.select))>0)
				$personFields:=$inParameters.select
		End case 
	End if 
	$urlParams+=$delimiter+"readMask="+$personFields
	$delimiter:="&"
	
	If (Length(String($inParameters.sources))>0)
		$sources:=$inParameters.sources
	End if 
	$urlParams+=($delimiter+"sources="+$sources)
	
	If (Length(String($inParameters.mergedSources))>0)
		$urlParams+=($delimiter+"mergeSources="+$sources)
	End if 
	If (Num($inParameters.top)>0)
		$urlParams+=($delimiter+"pageSize="+String($inParameters.top))
	End if 
	
	If (Bool($inParameters.requestSyncToken))
		$urlParams+=($delimiter+"requestSyncToken="+($inParameters.requestSyncToken ? "true" : "false"))
	End if 
	
	If (Length(String($inParameters.pageToken))>0)
		$urlParams+=($delimiter+"pageToken="+$inParameters.pageToken)
	End if 
	
	If (Length(String($inParameters.syncToken))>0)
		$urlParams+=($delimiter+"syncToken="+$inParameters.syncToken)
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
	
	var $parameters : Object:=($inParameters#Null) ? $inParameters : {}
	var $URL : Text:=Super._getURL()+"people:listDirectoryPeople"
	var $urlParams : Text:=This._getURLParamsFromObject($parameters)
	
	return cs.GoogleUserList.new(This._getOAuth2Provider(); $URL+$urlParams)
