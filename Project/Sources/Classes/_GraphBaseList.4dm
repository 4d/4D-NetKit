Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super:C1705($inProvider)
	
	This:C1470._internals.headers:=$inHeaders
	This:C1470._internals.history:=New collection:C1472
	This:C1470._internals.history.push($inURL)
	This:C1470.page:=1
	This:C1470.isLastPage:=False:C215
	
	This:C1470._getList($inURL)
	
	
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	var $URL : Text
	$URL:=String:C10(This:C1470._internals.nextLink)
	If (Length:C16($URL)>0)
		var $bIsOK : Boolean
		$bIsOK:=This:C1470._getList($URL)
		If ($bIsOK)
			This:C1470._internals.history.push($URL)
			This:C1470.page+=1
		End if 
		return $bIsOK
	Else 
		This:C1470.statusText:=Get localized string:C991("List_No_Next_Page")
		return False:C215
	End if 
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num:C11(This:C1470._internals.history.length)>0) && (This:C1470.page>1))
		var $URL : Text
		var $index : Integer
		$index:=This:C1470.page-1
		$URL:=String:C10(This:C1470._internals.history[$index-1])
		If (Length:C16($URL)>0)
			var $bIsOK : Boolean
			$bIsOK:=This:C1470._getList($URL)
			If ($bIsOK)
				This:C1470.page-=1
				This:C1470._internals.history.resize(This:C1470.page)
			End if 
			return $bIsOK
		End if 
	Else 
		This:C1470.statusText:=Get localized string:C991("List_No_Previous_Page")
		return False:C215
	End if 
	
	
	// ----------------------------------------------------
	
	
	// [Private]
Function _getList($inURL : Text) : Boolean
	
	var $response : Object
	$response:=Super:C1706._sendRequestAndWaitResponse("GET"; $inURL; This:C1470._internals.headers)
	
	This:C1470.isLastPage:=False:C215
	This:C1470.statusText:=Super:C1706._getStatusLine()
	This:C1470.success:=False:C215
	This:C1470._internals.nextLink:=""
	
	If ($response#Null:C1517)
		var $result : Collection
		var $object : Object
		$result:=$response["value"]
		This:C1470._internals.list:=New collection:C1472
		For each ($object; $result)
			This:C1470._internals.list.push(Super:C1706._cleanResponseObject($object))
		End for each 
		This:C1470.success:=True:C214
		This:C1470._internals.nextLink:=String:C10($response["@odata.nextLink"])
		This:C1470.isLastPage:=(Length:C16(This:C1470._internals.nextLink)=0)
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
	