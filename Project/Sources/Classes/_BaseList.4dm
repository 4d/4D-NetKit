Class extends _BaseAPI

property page : Integer
property isLastPage : Boolean
property statusText : Text
property success : Boolean
property errors : Collection

Class constructor($inProvider : cs.OAuth2Provider)
	
	Super($inProvider)
	
	This.page:=1
	This.isLastPage:=False
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getList($inToken : Text) : Boolean
	
	return False
	
	
	// ----------------------------------------------------
	
	
Function _handleListError()
	
	var $errorStack : Collection:=Super._getErrorStack()
	
	If ($errorStack.length>0)
		This.errors:=$errorStack
		This.statusText:=$errorStack.first().message
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	var $nextToken : Text:=String(This._internals._nextToken)
	
	If (Length($nextToken)>0)
		
		var $bIsOK : Boolean:=This._getList($nextToken)
		
		If ($bIsOK)
			This._internals._history.push($nextToken)
			This.page+=1
		End if 
		
		return $bIsOK
		
	Else 
		
		This.statusText:=Localized string("List_No_Next_Page")
		This.isLastPage:=True
		return False
		
	End if 
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	If ((Num(This._internals._history.length)>0) && (This.page>1))
		
		var $index : Integer:=This.page-1
		var $token : Text:=String(This._internals._history[$index-1])
		var $bIsOK : Boolean:=This._getList($token)
		
		If ($bIsOK)
			This.page-=1
			This._internals._history.resize(This.page)
		End if 
		
		return $bIsOK
		
	Else 
		
		This.statusText:=Localized string("List_No_Previous_Page")
		This.isLastPage:=True
		return False
		
	End if 
