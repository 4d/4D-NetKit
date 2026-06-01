Class extends _BaseList

Class constructor($inProvider : cs.OAuth2Provider; $inURL : Text; $inHeaders : Object)
	
	Super($inProvider)
	
	This._internals._headers:=$inHeaders
	This._internals._history:=[$inURL]
	This._internals._nextToken:=""
	
	Try
		This._getList($inURL)
	Catch
		// Errors are already in _errorStack via _throwError
		This._handleListError()
	End try
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inURL : Text) : Boolean
	
	This.isLastPage:=False
	This.success:=False
	This._internals._nextToken:=""
	This._internals._list:=[]
	
	var $response : Object
	Try
		$response:=Super._sendRequestAndWaitResponse("GET"; $inURL; This._internals._headers)
	Catch
		// Errors are already in _errorStack via _throwError
		This.statusText:=Super._getStatusLine()
		This._handleListError()
		return False
	End try
	
	This.statusText:=Super._getStatusLine()
	
	If ($response#Null)
		
		var $result : Collection:=($response["value"]#Null) ? $response["value"] : []
		var $object : Object
		For each ($object; $result)
			This._internals._list.push(cs._Tools.me.cleanGraphObject($object))
		End for each 
		This.success:=True
		var $nextLink : Text:=String($response["@odata.nextLink"])
		var $count : Integer:=Num($response["@odata.count"])
		If ((Length($nextLink)>0) && (This._internals._list.length=$count))
			$nextLink:=""
		End if 
		This._internals._nextToken:=$nextLink
		This.isLastPage:=(Length(This._internals._nextToken)=0)
		return True
	Else 
		This._handleListError()
		return False
	End if 
