Class extends _BaseAPI

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	This._internals._URL:="https://gmail.googleapis.com/gmail/v1/"
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
	
	var $urlParams; $delimiter : Text
	
	$urlParams:=""
	$delimiter:="?"

	If (Length(String($inParameters.search))>0)
		$urlParams+=($delimiter+"q="+_urlEncode($inParameters.search))
		$delimiter:="&"
	End if 
	If (Value type($inParameters.top)#Is undefined)
		$urlParams+=($delimiter+"maxResults="+String($inParameters.top))
		$delimiter:="&"
	End if 
	If (Value type($inParameters.includeSpamTrash)=Is boolean)
		$urlParams+=($delimiter+"includeSpamTrash="+($inParameters.includeSpamTrash ? "true" : "false"))
		$delimiter:="&"
	End if 
	If (Value type($inParameters.labelIds)=Is collection)
		$urlParams+=($delimiter+"labelIds="+$inParameters.labelIds.join("&labelIds="; ck ignore null or empty))
		$delimiter:="&"
	End if 
	If(Length(String($inParameters.format))>0)
		var $format : Text:=String($inParameters.format)
		$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
		If (($format="metadata") && (Value type($inParameters.headers)=Is collection))
			$urlParams+=($delimiter+"metadataHeaders="+$inParameters.headers.join("&metadataHeaders="; ck ignore null or empty))
			$delimiter:="&"
		End if 
		$urlParams+=($delimiter+"format="+$format)
	End if

	return $urlParams

