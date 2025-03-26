Class extends _GraphBaseList

property calendarId : Text

Class constructor($inCalendar : cs.Office365Calendar; $inURL : Text; $inHeaders : Object)
	
	Super($inCalendar._getOAuth2Provider(); $inURL; $inHeaders)
	
	This._internals._calendar:=$inCalendar
	This._internals._events:=Null
	This._internals._update:=True
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get events() : Collection
	
	If (This._internals._update)
		
		var $iter : Object
		var $provider : cs.OAuth2Provider:=This._internals._oAuth2Provider

		This._internals._events:=[]
		For each ($iter; This._internals._list)
			var $event : cs.GraphEvent:=cs.GraphEvent.new($provider; {userId: This._internals._calendar.userId; calendarId: This._internals._calendar.id}; $iter)
			This._internals._events.push($event)
		End for each 

		This._internals._update:=False
	End if 
	
	return This._internals._events
	
	
	// ----------------------------------------------------
	
	
Function next() : Boolean
	
	This._internals._update:=Super.next()
	return This._internals._update
	
	
	// ----------------------------------------------------
	
	
Function previous() : Boolean
	
	This._internals._update:=Super.previous()
	return This._internals._update
