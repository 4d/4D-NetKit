Class extends _GoogleAPI

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inName : Text)
	
	Super($inProvider)
	
	This._internals._URL:=$inURL
	This._internals._attribute:=$inName
	This._internals._nextPageToken:=""
	This._internals._history:=New collection
	
	This.page:=1
	This.isLastPage:=False
	
	This._getList()
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inPageToken : Text) : Boolean
	
	var $response : Object
	var $URL : Text
	
	$URL:=This._internals._URL
	
	If (Length(String($inPageToken))>0)
		
		var $sep : Text
		$sep:=((Position("?"; $URL)=0) ? "?" : "&")
		$URL+=$sep+"pageToken="+$inPageToken
	End if 
	
	$response:=Super._sendRequestAndWaitResponse("GET"; $URL)
	
	This.isLastPage:=False
	This.statusText:=Super._getStatusLine()
	This.success:=False
	This._internals._nextPageToken:=""
	
	If ($response#Null)
		
		If (OB Is defined($response; This._internals._attribute))
			
			This._internals._list:=OB Get($response; This._internals._attribute; Is collection)
		Else 
			
			This._internals._list:=New collection
		End if 
		
		This.success:=True
		This._internals._history.push($inPageToken)
		This._internals._nextPageToken:=String($response.nextPageToken)
		This.isLastPage:=(Length(This._internals._nextPageToken)=0)
		
		return True
		
	Else 
		
		var $errorStack : Collection
		$errorStack:=Super._getErrorStack()
		
		If ($errorStack.length>0)
			
			This.errors:=$errorStack
			This.statusText:=$errorStack[0].message
		End if 
		
		return False
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	var $pageToken : Text
	$pageToken:=String(This._internals._nextPageToken)
	
	If (Length($pageToken)>0)
		
		If (This._getList($pageToken))
			
			This.page+=1
			return True
		End if 
		
	Else 
		
		This.statusText:=Get localized string("List_No_Next_Page")
		This.isLastPage:=True
	End if 
	
	return False
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num(This._internals._history.length)>0) && (This.page>1))
		
		var $pageToken : Text
		var $index : Integer
		$index:=This.page-1
		$pageToken:=String(This._internals._history[$index-1])
		
		If (This._getList($pageToken))
			
			This.page-=1
			This._internals._history.resize(This.page)
			This.isLastPage:=(This.page<=1)
			
			return True
		End if 
		
	Else 
		
		This.statusText:=Get localized string("List_No_Previous_Page")
		This.isLastPage:=True
	End if 
	
	return False
