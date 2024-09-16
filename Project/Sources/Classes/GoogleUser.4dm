Class extends _GoogleAPI


Class constructor($inProvider : cs.OAuth2Provider)

	Super($inProvider;"https://people.googleapis.com/v1/")
	
	This._internals._defaultPersonFields:="names,emailAddresses,photos"
	
	
	// ----------------------------------------------------
	// Mark: - [Private]
	
	
Function _get($inResourceName : Text; $inPersonFields : Variant) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	var $resourceName : Text:=Length(String($inResourceName))>0 ? String($inResourceName) : "me"
	var $personFields : Text
	
	Case of 
		: (Type($inOptions)=Is collection)
			$personFields:=$inPersonFields.join(",")
		: (Type($inOptions)=Is text)
			$personFields:=$inPersonFields
		Else 
			$personFields:=This._internals._defaultPersonFields
	End case 
	
	$URL+="people/"+$resourceName+"?personFields="+$personFields
	
	var $headers : Object:={}
	$headers["Content-Type"]:="application/json"
	var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL; $headers)
	
	return $response
	
	
	// Mark: - [Public]
	// Mark: - Mails
	// ----------------------------------------------------
	
	
Function getCurrent($inPersonFields : Variant) : Object
	
	return This._get("me"; $inPersonFields)
	
	
	// ----------------------------------------------------
	
	
Function get($inResourceName : Text; $inPersonFields : Variant) : Object
	
	return This._get($inResourceName; $inPersonFields)
	
	
	// ----------------------------------------------------
	
	
Function list($inParameter : Object) : Object
	
	Super._clearErrorStack()
	
	var $URL : Text:=Super._getURL()
	var $personFields : Text
	var $sources : Text
	
	Case of 
		: (Type($inParameter.select)=Is collection)
			$personFields:=$inParameter.select.join(",")
		: (Type($inParameter.select)=Is text)
			$personFields:=$inParameter.select
		Else 
			$personFields:=This._internals._defaultPersonFields
	End case 
	
	If ((Type($inParameter.sources)=Is text) && (Length($inParameter.sources)>0))
		$sources:=$inParameter.sources
	Else 
		$sources:="DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE"
	End if 
	
	$URL+="people:listDirectoryPeople?readMask="+$personFields
	$URL+="&sources="+$sources
	
	If ((Type($inParameter.mergedSources)=Is text) && (Length($inParameter.mergedSources)>0))
		$URL+="&sources="+$sources
	End if 
	
	If (Type($inParameter.top)=Is integer)
		var $pageSize : Integer:=(($inParameter.top>0) && ($inParameter.top<=1000)) ? $inParameter.top : 100
		$URL+="&pageSize="+String($pageSize)
	End if 
	
	If (Type($inParameter.requestSyncToken)=Is boolean)
		$URL+="&requestSyncToken="+$inParameter.requestSyncToken ? "true" : "false"
	End if 
	
	return cs.GoogleUserList.new(This._getOAuth2Provider(); $URL)
