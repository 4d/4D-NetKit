Class extends _GoogleAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text; $inName : Text)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._URL:=$inURL
	This:C1470._internals._attribute:=$inName
	This:C1470._internals._nextPageToken:=""
	This:C1470._internals._history:=New collection:C1472
	
	This:C1470.page:=1
	This:C1470.isLastPage:=False:C215
	
	This:C1470._getList()
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inPageToken : Text) : Boolean
	
	var $response : Object
	var $URL : Text
	
	$URL:=This:C1470._internals._URL
	If (Length:C16(String:C10($inPageToken))>0)
		var $sep : Text
		$sep:=((Position:C15("?"; $URL)=0) ? "&" : "?")
		// TODO: replace an eventual existing pageToken
		$URL+=$sep+"pageToken="+$inPageToken
	End if 
	
	$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL)
	
	This:C1470.isLastPage:=False:C215
	This:C1470.statusText:=Super:C1706._getStatusLine()
	This:C1470.success:=False:C215
	This:C1470._internals._nextPageToken:=""
	
	If ($response#Null:C1517)
		
		If (OB Is defined:C1231($response; This:C1470._internals._attribute))
			This:C1470._internals._list:=OB Get:C1224($response; This:C1470._internals._attribute; Is collection:K8:32)
		Else 
			This:C1470._internals._list:=New collection:C1472
		End if 
		This:C1470.success:=True:C214
		This:C1470._internals._nextPageToken:=String:C10($response.nextPageToken)
		This:C1470.isLastPage:=(Length:C16(This:C1470._internals._nextPageToken)=0)
		If (Length:C16(This:C1470._internals._nextPageToken)>0)
			This:C1470._internals._history.push(This:C1470._internals._nextPageToken)
		End if 
		return True:C214
		
	Else 
		var $errorStack : Collection
		$errorStack:=Super:C1706._getErrorStack()
		If ($errorStack.length>0)
			This:C1470.errors:=$errorStack
			This:C1470.statusText:=$errorStack[0].message
		End if 
		return False:C215
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	var $nextPageToken : Text
	$nextPageToken:=String:C10(This:C1470._internals._nextPageToken)
	If ((This:C1470.page=1) || (Length:C16($nextPageToken)>0))
		var $bIsOK : Boolean
		$bIsOK:=This:C1470._getList($nextPageToken)
		If ($bIsOK)
			This:C1470.page+=1
		End if 
		return $bIsOK
	Else 
		This:C1470.statusText:=Get localized string:C991("List_No_Next_Page")
		return False:C215
	End if 
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num:C11(This:C1470._internals._history.length)>0) && (This:C1470.page>1))
		var $nextPageToken : Text
		var $index : Integer
		$index:=This:C1470.page-1
		$nextPageToken:=String:C10(This:C1470._internals._history[$index-1])
		If (Length:C16($nextPageToken)>0)
			var $bIsOK : Boolean
			$bIsOK:=This:C1470._getList($nextPageToken)
			If ($bIsOK)
				This:C1470.page-=1
				This:C1470._internals._history.resize(This:C1470.page)
			End if 
			return $bIsOK
		End if 
	Else 
		This:C1470.statusText:=Get localized string:C991("List_No_Previous_Page")
		return False:C215
	End if 
	