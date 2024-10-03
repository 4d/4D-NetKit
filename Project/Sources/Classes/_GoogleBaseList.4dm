Class extends _GoogleAPI

property page : Integer
property isLastPage : Boolean
property statusText : Text
property success : Boolean
property errors : Collection

Class constructor($inProvider : cs:C1710.OAuth2Provider; $inURL : Text; $inName : Text; $inHeaders : Object)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._URL:=$inURL
	This:C1470._internals._headers:=$inHeaders
	This:C1470._internals._attribute:=$inName
	This:C1470._internals._nextPageToken:=""
	This:C1470._internals._history:=[]
	
	This:C1470.page:=1
	This:C1470.isLastPage:=False:C215
	
	This:C1470._getList()
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inPageToken : Text) : Boolean
	
	var $URL : Text:=This:C1470._internals._URL
	
	If (Length:C16(String:C10($inPageToken))>0)
		
		var $sep : Text:=((Position:C15("?"; $URL)=0) ? "?" : "&")
		$URL+=$sep+"pageToken="+$inPageToken
	End if 
	
	var $response : Object:=Super:C1706._sendRequestAndWaitResponse("GET"; $URL; This:C1470._internals._headers)
	
	This:C1470.isLastPage:=False:C215
	This:C1470.statusText:=Super:C1706._getStatusLine()
	This:C1470.success:=False:C215
	This:C1470._internals._nextPageToken:=""
	
	If ($response#Null:C1517)
		
		If (OB Is defined:C1231($response; This:C1470._internals._attribute))
			
			This:C1470._internals._list:=OB Get:C1224($response; This:C1470._internals._attribute; Is collection:K8:32)
		Else 
			
			This:C1470._internals._list:=[]
		End if 
		
		This:C1470.success:=True:C214
		This:C1470._internals._history.push($inPageToken)
		This:C1470._internals._nextPageToken:=String:C10($response.nextPageToken)
		This:C1470.isLastPage:=(Length:C16(This:C1470._internals._nextPageToken)=0)
		
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
	
	var $pageToken : Text:=String:C10(This:C1470._internals._nextPageToken)
	
	If (Length:C16($pageToken)>0)
		
		If (This:C1470._getList($pageToken))
			
			This:C1470.page+=1
			return True:C214
		End if 
		
	Else 
		
		This:C1470.statusText:=Localized string:C991("List_No_Next_Page")
		This:C1470.isLastPage:=True:C214
	End if 
	
	return False:C215
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num:C11(This:C1470._internals._history.length)>0) && (This:C1470.page>1))
		
		var $index : Integer:=This:C1470.page-1
		var $pageToken : Text:=String:C10(This:C1470._internals._history[$index-1])
		
		If (This:C1470._getList($pageToken))
			
			This:C1470.page-=1
			This:C1470._internals._history.resize(This:C1470.page)
			This:C1470.isLastPage:=(This:C1470.page<=1)
			
			return True:C214
		End if 
		
	Else 
		
		This:C1470.statusText:=Localized string:C991("List_No_Previous_Page")
		This:C1470.isLastPage:=True:C214
	End if 
	
	return False:C215
	