Class extends _BaseList

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
	
	Super($inProvider)
	
	If ((Value type($inParameters.url)=Is text) && (Length($inParameters.url)>0))
		This._internals._URL:=$inParameters.url
	End if 
	This._internals._headers:=(Value type($inParameters.headers)=Is object) ? $inParameters.headers : Null
	This._internals._elements:=((Value type($inParameters.elements)=Is text) && (Length($inParameters.elements)>0)) ? $inParameters.elements : "items"
	This._internals._attributes:=(Value type($inParameters.attributes)=Is collection) ? $inParameters.attributes : Null
	This._internals._nextToken:=""
	This._internals._history:=[""]
	
	Try
		This._getList("")
	Catch
		// Errors are already in _errorStack via _throwError
		This._handleListError()
	End try
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inPageToken : Text) : Boolean
	
	var $URL : cs._URL:=cs._URL.new(This._internals._URL)
	
	If (Length(String($inPageToken))>0)
		$URL.addQueryParameter("pageToken"; $inPageToken)
	End if 
	
	This.isLastPage:=False
	This.success:=False
	This._internals._nextToken:=""
	This._internals._list:=[]
	
	var $response : Object
	Try
		$response:=Super._sendRequestAndWaitResponse("GET"; $URL.toString(); This._internals._headers)
	Catch
		// Errors are already in _errorStack via _throwError
		This.statusText:=Super._getStatusLine()
		This._handleListError()
		return False
	End try
	
	This.statusText:=Super._getStatusLine()
	
	If ($response#Null)
		
		If (OB Is defined($response; This._internals._elements))
			This._internals._list:=OB Get($response; This._internals._elements; Is collection)
		End if 
		
		If (This._internals._attributes#Null)
			var $attribute : Text
			For each ($attribute; This._internals._attributes)
				
				If (OB Is defined($response; $attribute))
					This[$attribute]:=OB Get($response; $attribute)
				End if 
			End for each 
		End if 
		
		This.success:=True
		This._internals._nextToken:=String($response.nextPageToken)
		This.isLastPage:=(Length(This._internals._nextToken)=0)
		
		return True
		
	Else 
		
		This._handleListError()
		return False
		
	End if 
