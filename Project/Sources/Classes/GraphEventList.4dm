/**
 * @class GraphEventList
 * @description Pageable list of calendar events returned by a Graph API query.
 *   The `events` getter returns the current page as a `Collection` of `GraphEvent` instances.
 *   Each item is wrapped lazily on first access and cached.
 */

Class extends _GraphBaseList

property calendarId : Text

Class constructor($inCalendar : cs.Office365Calendar; $inURL : Text; $inHeaders : Object)
/**
 * @constructor
 * @param {cs.Office365Calendar} $inCalendar - The `Office365Calendar` client owning this list
 *   (used to resolve `userId` and `calendarId` when hydrating `GraphEvent` instances)
 * @param {Text} $inURL - Initial Graph API URL
 * @param {Object} $inHeaders - Additional HTTP headers
 */
	
	Super($inCalendar._getOAuth2Provider(); $inURL; $inHeaders)
	
	This._internals._calendar:=$inCalendar
	This._internals._events:=Null
	This._internals._update:=True
	

	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function get events() : Collection
/**
 * @function get events
 * @returns {Collection} Current page as a `Collection` of `GraphEvent` instances;
 *   computed once and cached until the next page is loaded
 */
	
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
	
	

