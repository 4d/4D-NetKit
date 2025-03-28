Class extends _GraphAPI

property page : Integer
property isLastPage : Boolean
property statusText : Text
property success : Boolean
property errors : Collection

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider)
	
	This._internals._headers:=$inHeaders
	This._internals._history:=[$inURL]
	This._internals._list:=Null
	This.page:=1
	This.isLastPage:=False
	
	This._getList($inURL)
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inURL : Text) : Boolean
	
	Super._throwErrors(False)
	var $throwErrors : Boolean:=This._internals._oAuth2Provider._throwErrors(False)
	var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $inURL; This._internals._headers)
	This._internals._oAuth2Provider._throwErrors($throwErrors)
	Super._throwErrors(True)
	
	This.isLastPage:=False
	This.statusText:=Super._getStatusLine()
	This.success:=False
	This._internals._nextLink:=""
	This._internals._list:=[]
	
	If ($response#Null)
		
		var $result : Collection:=$response["value"]
		var $object : Object
		For each ($object; $result)
			This._internals._list.push(Super._cleanGraphObject($object))
		End for each 
		This.success:=True
		var $nextLink : Text:=cs.Tools.me.urlDecode(String($response["@odata.nextLink"]))
		var $count : Integer:=Num($response["@odata.count"])
		If ((Length($nextLink)>0) && (This._internals._list.length=$count))
			$nextLink:=""
		End if 
		This._internals._nextLink:=$nextLink
		This.isLastPage:=(Length(This._internals._nextLink)=0)
		return True
	Else 
		var $errorStack : Collection:=Super._getErrorStack()
		If ($errorStack.length>0)
			This.errors:=$errorStack
			This.statusText:=$errorStack.first().message
		End if 
		return False
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	var $URL : Text:=String(This._internals._nextLink)
	If (Length($URL)>0)
		var $bIsOK : Boolean:=This._getList($URL)
		If ($bIsOK)
			This._internals._history.push($URL)
			This.page+=1
		End if 
		return $bIsOK
	Else 
		This.statusText:=Localized string("List_No_Next_Page")
		return False
	End if 
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num(This._internals._history.length)>0) && (This.page>1))
		var $index : Integer:=This.page-1
		var $URL : Text:=String(This._internals._history[$index-1])
		If (Length($URL)>0)
			var $bIsOK : Boolean:=This._getList($URL)
			If ($bIsOK)
				This.page-=1
				This._internals._history.resize(This.page)
			End if 
			return $bIsOK
		End if 
	Else 
		This.statusText:=Localized string("List_No_Previous_Page")
		return False
	End if 
