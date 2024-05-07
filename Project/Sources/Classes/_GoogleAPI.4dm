Class extends _BaseAPI

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	This._internals._URL:="https://gmail.googleapis.com/gmail/v1/"
	
	
	// ----------------------------------------------------
	
	
Function _getURLParamsFromObject($inParameters : Object) : Text
	
	var $urlParams : Text:=""
	var $delimiter : Text:="?"
	
	If (Length(String($inParameters.search))>0)
		$urlParams+=($delimiter+"q="+cs.Tools.me.urlEncode($inParameters.search))
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
	If (Length(String($inParameters.format))>0)
		var $format : Text:=String($inParameters.format)
		$format:=(($format="minimal") || ($format="metadata")) ? $format : "raw"
		If (($format="metadata") && (Value type($inParameters.headers)=Is collection))
			$urlParams+=($delimiter+"metadataHeaders="+$inParameters.headers.join("&metadataHeaders="; ck ignore null or empty))
			$delimiter:="&"
		End if 
		$urlParams+=($delimiter+"format="+$format)
	End if 
	
	return $urlParams
	
	
	// ----------------------------------------------------
	
	
Function _convertMailObjectToJMAP($inMail : Object) : Object
	
	var $result : Object:={}
	var $keys : Collection:=OB Keys($inMail)
	var $key; $name; $string : Text
	var $email : cs.EmailAddress
	
	For each ($key; $keys)
		$name:=cs.Tools.me.getJMAPAttribute($key)
		If (Length($name)>0)
			If ($key="labelIds")
				If (Num($inMail.labelIds.length)>0)
					$string:=$inMail.labelIds.join("=true,"; ck ignore null or empty)+"=true"
					$result[$name]:=Split string($string; ","; sk trim spaces)
				End if 
			Else 
				$result[$name]:=$inMail[$key]
			End if 
		End if 
	End for each 
	
	If (OB Is defined($inMail; "payload"))
		$keys:=OB Keys($inMail.payload)
		For each ($key; $keys)
			If ($key="headers")
				var $header : Object
				For each ($header; $inMail.payload.headers)
					$name:=cs.Tools.me.getJMAPAttribute($header.name)
					If (Length($name)>0)
						Case of 
							: ($header.name="Keywords")
								If (Length($header.value)>0)
									$string:=$header.value.join("=true,"; ck ignore null or empty)+"=true"
									$result[$name]:=Split string($string; ","; sk trim spaces)
								End if 
							: (cs.Tools.me.IsEmailAddressHeader($header.name))
								If (Length($header.value)>0)
									$email:=cs.EmailAddress.new($header.value)
									$result[$name]:=$email
								End if 
							Else 
								$result[$name]:=$header.value
						End case 
					End if 
				End for each 
			End if 
		End for each 
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function _extractRawMessage($result : Object; $format : Text; $mailType : Text)->$response : Variant
	
	If ($result#Null)
		
		Case of 
			: (($format="raw") && (($mailType="MIME") || ($mailType="JMAP")))
				If (Value type($result.raw)=Is text)
					
					var $rawMessage : Text:=cs.Tools.me.base64UrlSafeDecode($result.raw)
					If ($mailType="JMAP")
						
						var $copy : Object:=$result
						$response:=MAIL Convert from MIME($rawMessage)
						$response.id:=String($copy.id)
						$response.threadId:=String($copy.threadId)
						$response.labelIds:=OB Is defined($copy; "labelIds") ? $copy.labelIds : []
					Else 
						
						var $blob : Blob
						CONVERT FROM TEXT((Length($rawMessage)>0) ? $rawMessage : $result.raw; "UTF-8"; $blob)
						$response:=4D.Blob.new($blob)
					End if 
				End if 
				
			: (($format="minimal") || ($format="metadata"))
				$response:=This._convertMailObjectToJMAP($result)
				
			Else 
				Super._throwError(10; {which: "\"format\""; function: "extractRawMessage"})
				
		End case 
		
	End if 
