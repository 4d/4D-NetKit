/**
 * @class GoogleNotification
 * @extends _GoogleAPI
 * @description Represents a Google notification monitor for Gmail or Calendar changes.
 *   Supports push (Pub/Sub for mail, webhook for calendar) and pull (polling) modes;
 *   call `start()` to begin monitoring and `stop()` to end it.
 */

Class extends _GoogleAPI


Class constructor($inType : Text; $inProvider : cs.OAuth2Provider; $inParameters : Object; $inResource : Text; $inOwner : Object)
/**
 * @constructor
 * @param {Text} $inType - Notification type: `"mail"` (Gmail) or `"event"` (Google Calendar)
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for token retrieval;
 *   determines the base URL (`gmail.googleapis.com` or `www.googleapis.com/calendar`)
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `onCreate`, `onDelete`, `onModify` {4D.Function} — Change-event callbacks
 *   - `endPoint` {Text} — Webhook URL for Calendar push mode
 *   - `topicName` {Text} — Google Cloud Pub/Sub topic name for Gmail push mode
 *   - `labelIds` {Collection} — Gmail label filter for push mode
 *   - `timer` {Integer} — Polling interval in seconds for pull mode (default: 30)
 * @param {Text} $inResource - Resource to monitor: Gmail user ID (mail mode) or
 *   calendar ID (event mode)
 * @param {Object} $inOwner - Parent `GoogleMail` or `GoogleCalendar` instance;
 *   forwarded to callbacks as context
 */
    
    var $baseURL : Text
    If ($inType="mail")
        $baseURL:="https://gmail.googleapis.com/gmail/v1/"
    Else 
        $baseURL:="https://www.googleapis.com/calendar/v3/"
    End if 
    
    Super($inProvider; $baseURL)
    
    This._internals._callbacks:=cs._NotificationHelper.me.parseCallbacks($inParameters)
    
    This._internals._type:=$inType  // "mail" or "event", used for callback eventType
    This._internals._resource:=$inResource  // userId for mail, calendarId for calendar
    This._internals._owner:=$inOwner
    This._internals._state:=""
    This._internals._workerName:=""
    This._internals._formWindow:=0
    This._internals._isStarted:=False
    This._internals._expiration:=""
    
    // Push mode config
    This._internals._endPoint:=""
    This._internals._topicName:=""
    This._internals._labelIds:=[]
    
    If (($inParameters#Null) && (Value type($inParameters)=Is object))
        If (Length(String($inParameters.endPoint))>0)
            This._internals._endPoint:=String($inParameters.endPoint)
        End if 
        If (Length(String($inParameters.topicName))>0)
            This._internals._topicName:=String($inParameters.topicName)
        End if 
        If (Value type($inParameters.labelIds)=Is collection)
            This._internals._labelIds:=$inParameters.labelIds
        End if 
    End if 
    
    // Mode: "push" or "pull"
    // Mail push requires topicName (Google Pub/Sub)
    // Calendar push requires endPoint (direct webhook)
    If ($inType="mail")
        This._internals._mode:=(Length(This._internals._topicName)>0) ? "push" : "pull"
    Else 
        This._internals._mode:=(Length(This._internals._endPoint)>0) ? "push" : "pull"
    End if 
    
    // Tracking state
    This._internals._historyId:=""  // For Gmail (history.list tracking)
    This._internals._syncToken:=""  // For Calendar (incremental sync tracking)
    This._internals._channelId:=""  // For Calendar push (watch channel ID)
    This._internals._googleResourceId:=""  // For Calendar push (to stop channel)
    This._internals._knownIds:=[]  // For Calendar (distinguish created vs updated)
    
    // Pull interval in seconds (default: 30 seconds)
    This._internals._pullInterval:=cs._NotificationHelper.me.parsePullInterval($inParameters)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get endPoint : Text
/**
 * @function get endPoint
 * @returns {Text} The webhook endpoint URL configured for push mode;
 *   empty string when in pull mode or not yet configured
 */
    
    return This._internals._endPoint
    
    
    // ----------------------------------------------------
    
    
Function get expiration : Text
/**
 * @function get expiration
 * @returns {Text} Expiration timestamp in milliseconds since epoch (as Text);
 *   empty string when not started or when the subscription has no expiration
 */
    
    return This._internals._expiration
    
    
    // ----------------------------------------------------
    
    
Function get isStarted : Boolean
/**
 * @function get isStarted
 * @returns {Boolean} True when the notification monitor is currently active
 */
    
    return This._internals._isStarted
    
    
    // ----------------------------------------------------
    
    
Function get timer : Integer
/**
 * @function get timer
 * @returns {Integer} Polling interval in seconds used in pull mode
 */
    
    return This._internals._pullInterval
    
    
    // ----------------------------------------------------
    
    
Function start() : Object
/**
 * @function start
 * @returns {Object} Status object `{success; statusText}`; no-op when already started
 * @description Starts change notifications for Gmail or Google Calendar in either
 *   push or pull mode; see inline documentation for mode-specific details
 */
    
/*
	Starts change notifications for Google Mail or Calendar.
	
	Two modes:
	- Push:
	    Mail: Creates a Gmail watch via Google Pub/Sub. Requires topicName parameter.
	      The user must have a Pub/Sub push subscription pointing to {serverUrl}/4dnk-google-notification.
	    Calendar: Creates a Google Calendar watch channel via webhook. Requires endPoint parameter.
	- Pull:
	    Mail: Polls Gmail history API at a configurable interval to detect changes.
	    Calendar: Polls Calendar events with sync token at a configurable interval.
	
	Callbacks (onCreate, onDelete, onModify) are dispatched in the
	worker where start() was called.
*/
    
    If (This._internals._isStarted)
        return This._returnStatus()
    End if 
    
    Super._clearErrorStack()
    
    var $result : Object
    var $state : Text:=Generate UUID
    This._internals._state:=$state
    This._internals._workerName:=Current process name
    This._internals._formWindow:=Current form window
    
    Try
        If (This._internals._mode="push")
            $result:=This._startPush($state)
        Else 
            $result:=This._startPull($state)
        End if 
    Catch
        $result:=This._returnStatus()
    End try
    return $result
    
    
    // ----------------------------------------------------
    
    
Function stop() : Object
/**
 * @function stop
 * @returns {Object} Status object `{success; statusText}`; no-op when already stopped
 * @description Stops the notification monitor, cleans up all internal state;
 *   in push mode also stops the Gmail watch or Calendar channel on the Google API
 */
    
/*
	Stops change notifications.
	In push mode, stops the Gmail watch or Calendar channel.
	In pull mode, stops the polling loop.
	Cleans up all internal state.
*/
    
    If (Not(This._internals._isStarted))
        return This._returnStatus()
    End if 
    
    Super._clearErrorStack()
    
    This._internals._isStarted:=False
    
    var $state : Text:=This._internals._state
    
    Try
        If (This._internals._mode="push")
            This._stopPush($state)
        Else 
            This._stopPull($state)
        End if 
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    This._internals._state:=""
    This._internals._expiration:=""
    This._internals._historyId:=""
    This._internals._syncToken:=""
    This._internals._channelId:=""
    This._internals._googleResourceId:=""
    
    return This._returnStatus()
    
    
    // Mark: - [Private] Push mode
    // ----------------------------------------------------
    
    
Function _startPush($inState : Text) : Object
/**
 * @function _startPush
 * @private
 * @param {Text} $inState - UUID key used to track this monitor in `Storage.googleNotifications`
 * @returns {Object} Status from `_startMailPush` or `_startCalendarPush`
 * @description Registers the state in Storage then delegates to the type-specific push starter
 */
    
    // Register in Storage for monitoring
    cs._NotificationHelper.me.registerInStorage("googleNotifications"; $inState; {pending: []})
    
    If (This._internals._type="mail")
        return This._startMailPush($inState)
    Else 
        return This._startCalendarPush($inState)
    End if 
    
    
    // ----------------------------------------------------
    
    
Function _startMailPush($inState : Text) : Object
/**
 * @function _startMailPush
 * @private
 * @param {Text} $inState - UUID key for this monitor; stored in Storage alongside
 *   the userId so incoming Pub/Sub notifications can be matched
 * @returns {Object} Status object; cleans up Storage and returns failure status on error
 * @description Creates a Gmail watch via `POST users/{userId}/watch` using the
 *   configured Pub/Sub topic; see inline documentation for prerequisites
 */
    
/*
	Gmail push via Pub/Sub.
	POST /users/{userId}/watch
	
	The user must have:
	1. A Google Cloud Pub/Sub topic with Gmail publish permissions
	2. A push subscription on that topic pointing to {serverUrl}/4dnk-google-notification
	
	See: https://developers.google.com/gmail/api/guides/push
*/
    
    var $userId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "me"
    var $url : Text:=Super._getURL()+"users/"+$userId+"/watch"
    
    var $body : Object:={}
    $body.topicName:=This._internals._topicName
    If (This._internals._labelIds.length>0)
        $body.labelIds:=This._internals._labelIds
        $body.labelFilterBehavior:="include"
    End if 
    
    var $headers : Object:={}
    $headers["Content-Type"]:="application/json"
    
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $url; $headers; JSON Stringify($body))
    
    If (($response#Null) && (Length(String($response.historyId))>0))
        
        This._internals._historyId:=String($response.historyId)
        This._internals._isStarted:=True
        
        // Expiration is in milliseconds since epoch
        If (Length(String($response.expiration))>0)
            This._internals._expiration:=String($response.expiration)
        End if 
        
        // Store emailAddress/userId for matching push notifications
        Use (Storage.googleNotifications[$inState])
            Storage.googleNotifications[$inState].userId:=$userId
        End use 
        
        This._startMonitoring()
        return This._returnStatus()
    End if 
    
    // Clean up Storage if watch creation failed
    cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _startCalendarPush($inState : Text) : Object
/**
 * @function _startCalendarPush
 * @private
 * @param {Text} $inState - UUID key used as the channel token so incoming webhook
 *   requests can be matched to this monitor via `X-Goog-Channel-Token`
 * @returns {Object} Status object; pushes errors 2 (missing endpoint) or
 *   7 (web server unavailable) and cleans up Storage on failure
 * @description Performs initial calendar sync to get a syncToken, then creates a
 *   Google Calendar watch channel via `POST calendars/{id}/events/watch`
 */
    
/*
	Calendar push via webhook.
	POST /calendars/{calendarId}/events/watch
	
	Creates a watch channel that receives notifications when calendar events change.
	
	See: https://developers.google.com/calendar/api/guides/push
*/
    
    var $calendarId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "primary"
    
    // Initial sync to get syncToken
    This._internals._syncToken:=This._initialCalendarSync()
    
    // Build notification URL
    var $notificationUrl : Text:=cs._NotificationHelper.me.buildNotificationUrl(This._internals._endPoint; "/4dnk-google-notification"; "")
    If (Length($notificationUrl)=0)
        This._throwError(2; {attribute: "endPoint"})
        
        // Clean up Storage
        cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
        
        return This._returnStatus()
    End if 
    
    // Ensure a web server is available for receiving notifications
    var $wsResult : Object:=cs._NotificationHelper.me.ensureWebServer(This._internals._endPoint)
    If (Not($wsResult.success))
        This._throwError(7; {port: $wsResult.port})
        
        // Clean up Storage
        cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
        
        return This._returnStatus()
    End if 
    
    // Create watch channel
    var $channelId : Text:=Generate UUID
    var $url : Text:=Super._getURL()+"calendars/"+cs._Tools.me.urlEncode($calendarId)+"/events/watch"
    
    var $body : Object:={}
    $body.id:=$channelId
    $body.type:="web_hook"
    $body.address:=$notificationUrl
    $body.token:=$inState
    
    var $headers : Object:={}
    $headers["Content-Type"]:="application/json"
    
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; $url; $headers; JSON Stringify($body))
    
    If (($response#Null) && (Length(String($response.id))>0))
        
        This._internals._channelId:=String($response.id)
        This._internals._googleResourceId:=String($response.resourceId)
        This._internals._isStarted:=True
        
        // Expiration is in milliseconds since epoch
        If (Length(String($response.expiration))>0)
            This._internals._expiration:=String($response.expiration)
        End if 
        
        This._startMonitoring()
        return This._returnStatus()
    End if 
    
    // Clean up Storage if channel creation failed
    cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _stopPush($inState : Text)
/**
 * @function _stopPush
 * @private
 * @param {Text} $inState - UUID key for this monitor in Storage
 * @description Signals the monitoring worker to stop, kills it, stops the Gmail
 *   watch or Calendar channel on the Google API, then cleans up Storage
 */
    
    
    // Signal the monitor to stop via Storage
    cs._NotificationHelper.me.signalStop("googleNotifications"; $inState)
    
    // Kill the monitor worker
    KILL WORKER("4DNK_GMonitor_"+$inState)
    
    If (This._internals._type="mail")
        // Stop Gmail watch: POST /users/{userId}/stop
        var $userId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "me"
        Super._sendRequestAndWaitResponse("POST"; Super._getURL()+"users/"+$userId+"/stop")
    Else 
        // Stop Calendar channel: POST /channels/stop
        If ((Length(This._internals._channelId)>0) && (Length(This._internals._googleResourceId)>0))
            var $stopHeaders : Object:={}
            $stopHeaders["Content-Type"]:="application/json"
            var $stopBody : Object:={id: This._internals._channelId; resourceId: This._internals._googleResourceId}
            Super._sendRequestAndWaitResponse("POST"; Super._getURL()+"channels/stop"; $stopHeaders; $stopBody)
        End if 
    End if 
    
    // Clean up Storage
    cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
    
    
    // Mark: - [Private] Pull mode
    // ----------------------------------------------------
    
    
Function _startPull($inState : Text) : Object
/**
 * @function _startPull
 * @private
 * @param {Text} $inState - UUID key for this monitor in Storage
 * @returns {Object} Status object
 * @description Registers the state in Storage, marks the monitor as started,
 *   and launches the monitoring loop in a background worker
 */
    
    // Register in Storage for the monitor active flag
    cs._NotificationHelper.me.registerInStorage("googleNotifications"; $inState; Null)
    
    // Perform initial sync to get a baseline token before launching the worker;
    // return the server error immediately if the API call fails (e.g. insufficient scope)
    If (This._internals._type="mail")
        If (Length(This._internals._historyId)=0)
            This._internals._historyId:=This._initialMailSync()
        End if 
        If (Length(This._internals._historyId)=0)
            cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
            return This._returnStatus()
        End if 
    Else 
        If (Length(This._internals._syncToken)=0)
            This._internals._syncToken:=This._initialCalendarSync()
        End if 
        If (Length(This._internals._syncToken)=0)
            cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
            return This._returnStatus()
        End if 
    End if 
    
    This._internals._isStarted:=True
    This._startMonitoring()
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _stopPull($inState : Text)
/**
 * @function _stopPull
 * @private
 * @param {Text} $inState - UUID key for this monitor in Storage
 * @description Signals the monitoring worker to stop, kills it,
 *   then cleans up Storage
 */
    
    
    // Signal the monitor to stop
    cs._NotificationHelper.me.signalStop("googleNotifications"; $inState)
    
    // Kill the monitor worker
    KILL WORKER("4DNK_GMonitor_"+$inState)
    
    // Clean up Storage
    cs._NotificationHelper.me.cleanupStorage("googleNotifications"; $inState)
    
    
    // Mark: - [Private] Gmail-specific
    // ----------------------------------------------------
    
    
Function _initialMailSync() : Text
/**
 * @function _initialMailSync
 * @private
 * @returns {Text} The current Gmail `historyId`, or empty string on failure
 * @description Fetches `GET users/{userId}/profile` to get the starting `historyId`;
 *   used as the baseline for `_pollMailHistory` change detection
 */
    
/*
	Gets the current historyId from the user's Gmail profile.
	This serves as the starting point for tracking changes via history.list.
	
	See: https://developers.google.com/gmail/api/reference/rest/v1/users/getProfile
*/
    
    var $userId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "me"
    var $url : Text:=Super._getURL()+"users/"+$userId+"/profile"
    
    var $response : Object:=Try(Super._sendRequestAndWaitResponse("GET"; $url))
    
    If (($response#Null) && (Length(String($response.historyId))>0))
        return String($response.historyId)
    End if 
    
    return ""
    
    
    // ----------------------------------------------------
    
    
Function _pollMailHistory() : Collection
/**
 * @function _pollMailHistory
 * @private
 * @returns {Collection} Deduplicated collection of `{changeType; resourceId}` objects
 *   where `changeType` is `"created"`, `"deleted"`, or `"updated"`;
 *   updates `_historyId` after each successful poll
 * @description Paginates through `GET users/{userId}/history?startHistoryId=...`
 *   and maps Gmail history entry types to unified change types
 */
    
/*
	Polls Gmail history API for changes since the last historyId.
	Returns a collection of {changeType; resourceId} items.
	
	History types:
	  - messagesAdded -> created
	  - messagesDeleted -> deleted
	  - labelsAdded/labelsRemoved -> updated
	
	See: https://developers.google.com/gmail/api/reference/rest/v1/users.history/list
*/
    
    var $items : Collection:=[]
    var $userId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "me"
    var $historyId : Text:=This._internals._historyId
    
    If (Length($historyId)=0)
        return $items
    End if 
    
    Try
        
        var $baseUrl : Text:=Super._getURL()+"users/"+$userId+"/history"
        var $url : Text:=$baseUrl+"?startHistoryId="+$historyId
        
        While (Length($url)>0)
            var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $url)
            
            If ($response#Null)
                If (Value type($response.history)=Is collection)
                    var $entry : Object
                    For each ($entry; $response.history)
                        
                        // messagesAdded -> created
                        If (Value type($entry.messagesAdded)=Is collection)
                            var $added : Object
                            For each ($added; $entry.messagesAdded)
                                If ((Value type($added.message)=Is object) && (Length(String($added.message.id))>0))
                                    $items.push({changeType: "created"; resourceId: String($added.message.id)})
                                End if 
                            End for each 
                        End if 
                        
                        // messagesDeleted -> deleted
                        If (Value type($entry.messagesDeleted)=Is collection)
                            var $deleted : Object
                            For each ($deleted; $entry.messagesDeleted)
                                If ((Value type($deleted.message)=Is object) && (Length(String($deleted.message.id))>0))
                                    $items.push({changeType: "deleted"; resourceId: String($deleted.message.id)})
                                End if 
                            End for each 
                        End if 
                        
                        // labelsAdded -> updated
                        If (Value type($entry.labelsAdded)=Is collection)
                            var $labelAdded : Object
                            For each ($labelAdded; $entry.labelsAdded)
                                If ((Value type($labelAdded.message)=Is object) && (Length(String($labelAdded.message.id))>0))
                                    $items.push({changeType: "updated"; resourceId: String($labelAdded.message.id)})
                                End if 
                            End for each 
                        End if 
                        
                        // labelsRemoved -> updated
                        If (Value type($entry.labelsRemoved)=Is collection)
                            var $labelRemoved : Object
                            For each ($labelRemoved; $entry.labelsRemoved)
                                If ((Value type($labelRemoved.message)=Is object) && (Length(String($labelRemoved.message.id))>0))
                                    $items.push({changeType: "updated"; resourceId: String($labelRemoved.message.id)})
                                End if 
                            End for each 
                        End if 
                        
                    End for each 
                End if 
                
                // Update historyId
                If (Length(String($response.historyId))>0)
                    This._internals._historyId:=String($response.historyId)
                End if 
                
                // Pagination
                If (Length(String($response.nextPageToken))>0)
                    $url:=$baseUrl+"?startHistoryId="+$historyId+"&pageToken="+$response.nextPageToken
                Else 
                    $url:=""
                End if 
            Else 
                $url:=""
            End if 
        End while 
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    // Deduplicate: keep only the last change for each resource ID
    var $seen : Object:={}
    var $deduplicated : Collection:=[]
    var $i : Integer
    For ($i; $items.length-1; 0; -1)
        If (Not(OB Is defined($seen; $items[$i].resourceId)))
            $seen[$items[$i].resourceId]:=True
            $deduplicated.unshift($items[$i])
        End if 
    End for 
    
    return $deduplicated
    
    
    // Mark: - [Private] Calendar-specific
    // ----------------------------------------------------
    
    
Function _initialCalendarSync() : Text
/**
 * @function _initialCalendarSync
 * @private
 * @returns {Text} The `nextSyncToken` for future incremental sync,
 *   or empty string on failure
 * @description Pages through all calendar events with minimal fields to populate
 *   the `_knownIds` cache; the resulting syncToken is used by `_pollCalendarChanges`
 */
    
/*
	Performs initial calendar sync to obtain a syncToken for tracking future changes.
	
	Pages through all events using minimal fields to minimize payload.
	Existing events are collected for the knownIds cache.
	After this call, only future changes will be reported via _pollCalendarChanges().
	
	See: https://developers.google.com/calendar/api/guides/sync
*/
    
    var $calendarId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "primary"
    var $url : Text:=Super._getURL()+"calendars/"+cs._Tools.me.urlEncode($calendarId)+"/events?maxResults=2500&fields=nextSyncToken%2CnextPageToken%2Citems%2Fid"
    var $syncToken : Text:=""
    
    Try
        
        var $response : Object
        
        Repeat 
            $response:=Super._sendRequestAndWaitResponse("GET"; $url)
            
            If ($response#Null)
                If (Length(String($response.nextSyncToken))>0)
                    $syncToken:=String($response.nextSyncToken)
                Else 
                    If (Length(String($response.nextPageToken))>0)
                        $url:=Super._getURL()+"calendars/"+cs._Tools.me.urlEncode($calendarId)+"/events?maxResults=2500&fields=nextSyncToken%2CnextPageToken%2Citems%2Fid&pageToken="+$response.nextPageToken
                    Else 
                        $url:=""
                    End if 
                End if 
            End if 
        Until (($syncToken#"") || ($response=Null) || ($url=""))
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return $syncToken
    
    
    // ----------------------------------------------------
    
    
Function _pollCalendarChanges() : Collection
/**
 * @function _pollCalendarChanges
 * @private
 * @returns {Collection} Collection of `{changeType; resourceId}` objects where
 *   `changeType` is `"created"`, `"deleted"`, or `"updated"`;
 *   updates `_syncToken` after each successful poll
 * @description Paginates through `GET calendars/{id}/events?syncToken=...`;
 *   uses the `_knownIds` cache to distinguish created from updated events;
 *   cancelled events (`status="cancelled"`) are reported as deleted
 */
    
/*
	Polls the Calendar events API with syncToken for changes.
	Returns a collection of {changeType; resourceId} items.
	
	Uses _knownIds cache to distinguish created vs updated.
	Cancelled events (status="cancelled") are marked as deleted.
	
	See: https://developers.google.com/calendar/api/guides/sync
*/
    
    var $items : Collection:=[]
    var $calendarId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "primary"
    var $syncToken : Text:=This._internals._syncToken
    
    If (Length($syncToken)=0)
        return $items
    End if 
    
    Try
        
        var $url : Text:=Super._getURL()+"calendars/"+cs._Tools.me.urlEncode($calendarId)+"/events?syncToken="+cs._Tools.me.urlEncode($syncToken)
        
        While (Length($url)>0)
            var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $url)
            
            If ($response#Null)
                If (Value type($response.items)=Is collection)
                    var $event : Object
                    For each ($event; $response.items)
                        var $item : Object:={}
                        $item.resourceId:=String($event.id)
                        
                        If (String($event.status)="cancelled")
                            // Deleted event
                            $item.changeType:="deleted"
                            var $removeIdx : Integer:=This._internals._knownIds.indexOf($item.resourceId)
                            If ($removeIdx>=0)
                                This._internals._knownIds.remove($removeIdx)
                            End if 
                        Else 
                            // Distinguish created vs updated using known IDs cache
                            If (This._internals._knownIds.indexOf($item.resourceId)<0)
                                $item.changeType:="created"
                                This._internals._knownIds.push($item.resourceId)
                            Else 
                                $item.changeType:="updated"
                            End if 
                        End if 
                        
                        $items.push($item)
                    End for each 
                End if 
                
                // Pagination or new syncToken
                If (Length(String($response.nextPageToken))>0)
                    $url:=Super._getURL()+"calendars/"+cs._Tools.me.urlEncode($calendarId)+"/events?syncToken="+cs._Tools.me.urlEncode($syncToken)+"&pageToken="+$response.nextPageToken
                Else 
                    If (Length(String($response.nextSyncToken))>0)
                        This._internals._syncToken:=String($response.nextSyncToken)
                    End if 
                    $url:=""
                End if 
            Else 
                $url:=""
            End if 
        End while 
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return $items
    
    
    // Mark: - [Private] Common
    // ----------------------------------------------------
    
    
Function _buildNotificationUrl($inState : Text) : Text
/**
 * @function _buildNotificationUrl
 * @private
 * @param {Text} $inState - UUID state key (forwarded to `_NotificationHelper` for
 *   potential future extension; not used in the current URL)
 * @returns {Text} Resolved webhook URL for this notification monitor
 */
    
    return cs._NotificationHelper.me.buildNotificationUrl(This._internals._endPoint; "/4dnk-google-notification"; "")
    
    
    // ----------------------------------------------------
    
    
Function _startMonitoring()
/**
 * @function _startMonitoring
 * @private
 * @description Launches `_monitorLoop` in a dedicated background worker named
 *   `"4DNK_GMonitor_"+state`; captures the current process name and form window
 *   reference so callbacks can be dispatched back to the caller context
 */
    
    var $self : cs.GoogleNotification:=This
    var $workerName : Text:=This._internals._workerName
    var $state : Text:=This._internals._state
    var $formWindow : Integer:=This._internals._formWindow
    
    CALL WORKER("4DNK_GMonitor_"+$state; Formula($1._monitorLoop($2; $3; $4)); $self; $workerName; $state; $formWindow)
    
    
    // ----------------------------------------------------
    
    
Function _monitorLoop($inWorkerName : Text; $inState : Text; $inFormWindow : Integer)
/**
 * @function _monitorLoop
 * @private
 * @param {Text} $inWorkerName - Name of the worker process that called `start()`;
 *   used to dispatch callbacks back to the original context
 * @param {Text} $inState - UUID key used to monitor active status via
 *   `Storage.googleNotifications`
 * @param {Integer} $inFormWindow - Form window reference for `CALL FORM` dispatch;
 *   `0` when the caller is not a form
 * @description Main monitoring loop running in a dedicated background worker;
 *   see inline documentation for push/pull behaviour and renewal details
 */
    
/*
	Main monitoring loop, runs in a dedicated background worker.
	
	Push mode: checks Storage for pending notifications pushed by the webhook handler,
	then queries the appropriate Google API for actual changes.
	Pull mode: polls the Google API at a configurable interval.
	
	In both modes, dispatches callbacks to the original caller context via CALL FORM or CALL WORKER.
*/
    
    // Perform initial sync if needed (safety net for push mode; pull mode is pre-synced in _startPull)
    If (This._internals._type="mail")
        If (Length(This._internals._historyId)=0)
            This._internals._historyId:=This._initialMailSync()
        End if 
    Else 
        If (Length(This._internals._syncToken)=0)
            This._internals._syncToken:=This._initialCalendarSync()
        End if 
    End if 
    
    var $renewalThreshold : Integer:=3600
    var $pullIntervalTicks : Integer:=This._internals._pullInterval*60  // Convert seconds to ticks
    var $pushIntervalTicks : Integer:=120  // 2 second check interval for push mode
    var $sleepTicks : Integer:=(This._internals._mode="pull") ? $pullIntervalTicks : $pushIntervalTicks
    
    While (This._isMonitorActive($inState))
        
        DELAY PROCESS(Current process; $sleepTicks)
        
        If (Not(This._isMonitorActive($inState)))
            break
        End if 
        
        var $items : Collection:=[]
        var $shouldPoll : Boolean:=False
        
        If (This._internals._mode="push")
            // Push mode: drain pending items from Storage
            var $pending : Collection:=This._drainPendingItems($inState)
            $shouldPoll:=($pending.length>0)
            
            // Check if renewal is needed
            This._renewIfNeeded($renewalThreshold)
        Else 
            // Pull mode: always poll
            $shouldPoll:=True
        End if 
        
        If ($shouldPoll)
            If (This._internals._type="mail")
                $items:=This._pollMailHistory()
            Else 
                $items:=This._pollCalendarChanges()
            End if 
        End if 
        
        If ($items.length>0)
            cs._NotificationHelper.me.callbackInCallerContext($inFormWindow; $inWorkerName; Formula($1._dispatchCallbacks($2)); This; $items)
        End if 
        
    End while 
    
    KILL WORKER
    
    
    // ----------------------------------------------------
    
    
Function _isMonitorActive($inState : Text) : Boolean
/**
 * @function _isMonitorActive
 * @private
 * @param {Text} $inState - UUID state key to check in `Storage.googleNotifications`
 * @returns {Boolean} True when the monitor should continue its loop;
 *   False when `signalStop` has been called
 */
    
    return cs._NotificationHelper.me.isMonitorActive("googleNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _drainPendingItems($inState : Text) : Collection
/**
 * @function _drainPendingItems
 * @private
 * @param {Text} $inState - UUID state key for this monitor
 * @returns {Collection} Drained collection of pending notification signals;
 *   empty collection when there are no pending items
 */
    
    return cs._NotificationHelper.me.drainPendingItems("googleNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _dispatchCallbacks($inItems : Collection)
/**
 * @function _dispatchCallbacks
 * @private
 * @param {Collection} $inItems - Collection of `{changeType; resourceId}` objects to dispatch
 * @description Groups items by change type and invokes `onCreate`, `onDelete`, or
 *   `onModify` callbacks via `_NotificationHelper.dispatchCallbacks`;
 *   passes the parent owner object as the callback context
 */
    
    cs._NotificationHelper.me.dispatchCallbacks($inItems; This._internals._type; This._internals._callbacks; This._internals._owner)
    
    
    // ----------------------------------------------------
    
    
Function _renewIfNeeded($inThresholdSeconds : Integer)
/**
 * @function _renewIfNeeded
 * @private
 * @param {Integer} $inThresholdSeconds - Seconds before expiration to trigger renewal;
 *   renewal occurs when remaining time is less than this value
 * @description Proactively renews the Gmail watch or Calendar channel before expiration;
 *   for Gmail re-calls `POST .../watch`; for Calendar creates a new channel then
 *   stops the old one to maintain continuity
 */
    
    If (Length(This._internals._expiration)=0)
        return 
    End if 
    
    // Google expiration is in milliseconds since epoch
    var $expirationMs : Real:=Num(This._internals._expiration)
    var $expirationSeconds : Real:=$expirationMs/1000
    
    // Compute current UTC epoch seconds
    var $nowDT : cs._DateTime:=cs._DateTime.new()
    var $nowEpochSeconds : Real:=($nowDT.date-!1970-01-01!)*86400+$nowDT.time
    
    var $remainingSeconds : Real:=$expirationSeconds-$nowEpochSeconds
    
    If ($remainingSeconds<$inThresholdSeconds)
        
        var $response : Object:={}
        var $body : Object:={}
        var $headers : Object:={}
        
        Try
            
            If (This._internals._type="mail")
                // Renew Gmail watch by calling watch() again
                var $userId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "me"
                var $url : Text:=Super._getURL()+"users/"+$userId+"/watch"
                
                $body.topicName:=This._internals._topicName
                If (This._internals._labelIds.length>0)
                    $body.labelIds:=This._internals._labelIds
                    $body.labelFilterBehavior:="include"
                End if 
                
                $headers["Content-Type"]:="application/json"
                
                $response:=Super._sendRequestAndWaitResponse("POST"; $url; $headers; JSON Stringify($body))
                
                If (($response#Null) && (Length(String($response.expiration))>0))
                    This._internals._expiration:=String($response.expiration)
                End if 
                
            Else 
                // Renew Calendar channel: create new channel, then stop old one
                var $calendarId : Text:=(Length(This._internals._resource)>0) ? This._internals._resource : "primary"
                var $oldChannelId : Text:=This._internals._channelId
                var $oldResourceId : Text:=This._internals._googleResourceId
                
                var $newChannelId : Text:=Generate UUID
                var $url2 : Text:=Super._getURL()+"calendars/"+cs._Tools.me.urlEncode($calendarId)+"/events/watch"
                
                $body.id:=$newChannelId
                $body.type:="web_hook"
                $body.address:=This._buildNotificationUrl(This._internals._state)
                $body.token:=This._internals._state
                
                $headers["Content-Type"]:="application/json"
                
                $response:=Super._sendRequestAndWaitResponse("POST"; $url2; $headers; JSON Stringify($body))
                
                If (($response#Null) && (Length(String($response.id))>0))
                    This._internals._channelId:=String($response.id)
                    This._internals._googleResourceId:=String($response.resourceId)
                    If (Length(String($response.expiration))>0)
                        This._internals._expiration:=String($response.expiration)
                    End if 
                    
                    // Stop old channel
                    If ((Length($oldChannelId)>0) && (Length($oldResourceId)>0))
                        var $stopHeaders : Object:={}
                        $stopHeaders["Content-Type"]:="application/json"
                        var $stopBody : Object:={id: $oldChannelId; resourceId: $oldResourceId}
                        Super._sendRequestAndWaitResponse("POST"; Super._getURL()+"channels/stop"; $stopHeaders; JSON Stringify($stopBody))
                    End if 
                End if 
            End if 
        Catch
            // Errors are already in _errorStack via _throwError
        End try
        
    End if 
