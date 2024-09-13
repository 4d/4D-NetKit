Class extends _GraphAPI

property page : Integer
property isLastPage : Boolean
property statusText : Text
property success : Boolean
property errors : Collection

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._headers:=$inHeaders
	This:C1470._internals._history:=[$inURL]
	This:C1470._internals._list:=Null:C1517
	This:C1470.page:=1
	This:C1470.isLastPage:=False:C215
	
	This:C1470._getList($inURL)
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inURL : Text) : Boolean
	
	var $response : Object:=Super:C1706._sendRequestAndWaitResponse("GET"; $inURL; This:C1470._internals._headers)
	
	This:C1470.isLastPage:=False:C215
	This:C1470.statusText:=Super:C1706._getStatusLine()
	This:C1470.success:=False:C215
	This:C1470._internals._nextLink:=""
	This:C1470._internals._list:=[]
	
	If ($response#Null:C1517)
		
		var $result : Collection:=$response["value"]
		var $object : Object
		For each ($object; $result)
			This:C1470._internals._list.push(Super:C1706._cleanGraphObject($object))
		End for each 
		This:C1470.success:=True:C214
		var $nextLink : Text:=cs:C1710.Tools.me.urlDecode(String:C10($response["@odata.nextLink"]))
		var $count : Integer:=Num:C11($response["@odata.count"])
		If ((Length:C16($nextLink)>0) && (This:C1470._internals._list.length=$count))
			$nextLink:=""
		End if 
		This:C1470._internals._nextLink:=$nextLink
		This:C1470.isLastPage:=(Length:C16(This:C1470._internals._nextLink)=0)
		return True:C214
	Else 
		var $errorStack : Collection:=Super:C1706._getErrorStack()
		If ($errorStack.length>0)
			This:C1470.errors:=$errorStack
			This:C1470.statusText:=$errorStack.first().message
		End if 
		return False:C215
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	var $URL : Text:=String:C10(This:C1470._internals._nextLink)
	If (Length:C16($URL)>0)
		var $bIsOK : Boolean:=This:C1470._getList($URL)
		If ($bIsOK)
			This:C1470._internals._history.push($URL)
			This:C1470.page+=1
		End if 
		return $bIsOK
	Else 
		This:C1470.statusText:=Localized string:C991("List_No_Next_Page")
		return False:C215
	End if 
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num:C11(This:C1470._internals._history.length)>0) && (This:C1470.page>1))
		var $index : Integer:=This:C1470.page-1
		var $URL : Text:=String:C10(This:C1470._internals._history[$index-1])
		If (Length:C16($URL)>0)
			var $bIsOK : Boolean:=This:C1470._getList($URL)
			If ($bIsOK)
				This:C1470.page-=1
				This:C1470._internals._history.resize(This:C1470.page)
			End if 
			return $bIsOK
		End if 
	Else 
		This:C1470.statusText:=Localized string:C991("List_No_Previous_Page")
		return False:C215
	End if 
	