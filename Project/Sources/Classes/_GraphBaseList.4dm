Class extends _GraphAPI

property page : Integer
property isLastPage : Boolean
property statusText : Text
property success : Boolean
property errors : Collection

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider)
	
	This._internals._headers:=$inHeaders
	This._internals._history:=[]
	This._internals._history.push($inURL)
	This._internals._list:=Null
	This.page:=1
	This.isLastPage:=False
	
	This._getList($inURL)
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inURL : Text) : Boolean
	
	var $response : Object
	$response:=Super._sendRequestAndWaitResponse("GET"; $inURL; This._internals._headers)
	
	This.isLastPage:=False
	This.statusText:=Super._getStatusLine()
	This.success:=False
	This._internals._nextLink:=""
	This._internals._list:=[]
	
	If ($response#Null)
		var $result : Collection
		var $object : Object
		var $nextLink : Text
		var $count : Integer
		
		$result:=$response["value"]
		For each ($object; $result)
			This._internals._list.push(Super._cleanGraphObject($object))
		End for each 
		This.success:=True
		$nextLink:=_urlDecode(String($response["@odata.nextLink"]))
		$count:=Num($response["@odata.count"])
		If ((Length($nextLink)>0) && (This._internals._list.length=$count))
			$nextLink:=""
		End if 
		This._internals._nextLink:=$nextLink
		This.isLastPage:=(Length(This._internals._nextLink)=0)
		return True
	Else 
		var $errorStack : Collection
		$errorStack:=Super._getErrorStack()
		If ($errorStack.length>0)
			This.errors:=$errorStack
			This.statusText:=$errorStack.first().message
		End if 
		return False
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	var $URL : Text
	$URL:=String(This._internals._nextLink)
	If (Length($URL)>0)
		var $bIsOK : Boolean
		$bIsOK:=This._getList($URL)
		If ($bIsOK)
			This._internals._history.push($URL)
			This.page+=1
		End if 
		return $bIsOK
	Else 
		This.statusText:=Get localized string("List_No_Next_Page")
		return False
	End if 
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num(This._internals._history.length)>0) && (This.page>1))
		var $URL : Text
		var $index : Integer
		$index:=This.page-1
		$URL:=String(This._internals._history[$index-1])
		If (Length($URL)>0)
			var $bIsOK : Boolean
			$bIsOK:=This._getList($URL)
			If ($bIsOK)
				This.page-=1
				This._internals._history.resize(This.page)
			End if 
			return $bIsOK
		End if 
	Else 
		This.statusText:=Get localized string("List_No_Previous_Page")
		return False
	End if 
