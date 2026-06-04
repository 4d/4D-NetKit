/**
 * @class GraphEvent
 * @description Represents a single Microsoft Graph calendar event.
 *   Extends `_GraphAPI` and is hydrated from a Graph API response via `_loadFromObject`.
 *   Provides lazy-loaded `attachments` via a Graph API call on first access
 *   (only when `hasAttachments` is `True`).
 */

Class extends _GraphAPI

property id : Text:=""
property hasAttachments : Boolean:=False

/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParameters - Context options:
 *   - `userId` {Text} — Graph user ID or UPN (used when fetching attachments)
 *   - `calendarId` {Text} — Calendar ID (used when building the attachment URL)
 * @param {Object} $inObject - Raw Graph API event object to hydrate from
 */
Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object; $inObject : Object)
	
	Super($inProvider)
	
	This._internals._userId:=String($inParameters.userId)
	This._internals._calendarId:=String($inParameters.calendarId)
	This._internals._attachments:=Null
	Super._loadFromObject($inObject)
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
/**
 * @function get attachments
 * @returns {Collection} Collection of `GraphAttachment` instances for this event;
 *   fetched on first access (lazy) and cached. Only fetched when `hasAttachments` is `True`.
 *   See inline comment for the supported Graph endpoint variants.
 */
Function get attachments() : Collection
	
	If (This.hasAttachments && (This._internals._attachments=Null))
		
		This._internals._attachments:=[]
/*
    Attachments for an event in the user's default calendar.
        GET /me/events/{id}/attachments
        GET /users/{id | userPrincipalName}/events/{id}/attachments
		
        GET /me/calendar/events/{id}/attachments
        GET /users/{id | userPrincipalName}/calendar/events/{id}/attachments
		
    Attachments for an event in a calendar belonging to the user's default calendarGroup.
		
        GET /me/calendars/{id}/events/{id}/attachments
        GET /users/{id | userPrincipalName}/calendars/{id}/events/{id}/attachments
*/
		var $urlParams : Text:=""
		
		If (Length(String(This._internals._userId))>0)
			$urlParams:="users/"+This._internals._userId
		Else 
			$urlParams:="me"
		End if 
		If (Length(String(This._internals._calendarId))>0)
			$urlParams+="/calendars/"+This._internals._calendarId
		Else 
			If (Length(String(This._internals._calendarId))>0)
				$urlParams+="/calendars/"+This._internals._calendarId
			Else 
				$urlParams+="/calendar"
			End if 
		End if 
		$urlParams+="/events/"+String(This.id)+"/attachments"
		
		var $URL : Text:=Super._getURL()+$urlParams
		var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $URL)
		
		If ($response#Null)
			var $attachments : Collection:=$response["value"]
			var $iter : Object
			For each ($iter; $attachments)
				var $attachment : Object:=cs.GraphAttachment.new(This._getOAuth2Provider(); {eventId: String(This.id)}; $iter)
				This._internals._attachments.push($attachment)
			End for each 
		End if 
	End if 
	
	return This._internals._attachments
