/**
 * @class GraphNotification
 * @description Manages Microsoft Graph change notifications for mail messages or calendar events.
 *   Supports two modes:
 *   - **Push** (webhook): creates a Graph subscription and receives real-time notifications;
 *     automatically renews the subscription before expiration
 *   - **Pull** (delta query): polls the delta endpoint at a configurable interval
 *
 *   Mail pull mode uses three per-changeType delta streams; calendar/event pull mode uses
 *   one delta stream with a `knownIds` cache to classify changes.
 */

Class extends _GraphAPI


Class constructor($inType : Text; $inProvider : cs.OAuth2Provider; $inParameters : Object; $inResource : Text; $inUserId : Text; $inOwner : Object)
/**
 * @constructor
 * @param {Text} $inType - Resource type: `"mail"` or `"event"`;
 *   used to build callback event type names (e.g. `"mailCreated"`, `"eventModified"`)
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParameters - Notification options:
 *   - `onCreate` {4D.Function} — Callback when an item is created
 *   - `onDelete` {4D.Function} — Callback when an item is deleted
 *   - `onModify` {4D.Function} — Callback when an item is modified
 *   - `endPoint` {Text} — Webhook URL (push mode); omit for pull mode
 *   - `pullInterval` {Integer} — Polling interval in seconds (pull mode; default 30)
 * @param {Text} $inResource - Graph resource path (e.g. `"me/mailFolders/inbox/messages"`)
 * @param {Text} $inUserId - Graph user ID or UPN (forwarded to the owner client)
 * @param {Object} $inOwner - The `Office365Mail` or `Office365Calendar` client
 *   that created this notification; forwarded to callbacks
 */
    
    Super($inProvider)
    
    This._internals._callbacks:=cs._NotificationHelper.me.parseCallbacks($inParameters)
    
    This._internals._type:=$inType  // "mail" or "event", used for callback eventType like "mailCreated" or "eventModified"
    This._internals._resource:=$inResource
    This._internals._userId:=$inUserId
    This._internals._owner:=$inOwner
    This._internals._subscriptionId:=""
    This._internals._state:=""
    This._internals._workerName:=""
    This._internals._formWindow:=0
    This._internals._isStarted:=False
    
    // endPoint for push mode (webhook)
    This._internals._endPoint:=""
    If (($inParameters#Null) && (Value type($inParameters)=Is object))
        If (Length(String($inParameters.endPoint))>0)
            This._internals._endPoint:=String($inParameters.endPoint)
        End if 
    End if 
    
    // Mode: "push" (webhook) if endPoint is provided, "pull" (delta query) otherwise
    This._internals._mode:=(Length(This._internals._endPoint)>0) ? "push" : "pull"
    
    // Delta query internals
    This._internals._deltaResource:=""  // Separate resource path for delta queries (e.g. calendarView instead of events)
    
    // Microsoft Graph message delta supports changeType filtering. Calendar/event delta
    // does not reliably support the same changeType filter, so pull mode is hybrid:
    // - mail: 3 deltaLinks, one per changeType
    // - event: 1 deltaLink + knownIds cache initialized by a real initial sync
    This._internals._supportsChangeTypeFiltering:=(This._internals._type="mail")
    
    This._internals._deltaLink:=""
    This._internals._knownIds:=[]
    
    This._internals._deltaLinks:={}
    This._internals._deltaLink:=""
    This._internals._knownIds:=[]
    This._internals._deltaLinks.created:=""
    This._internals._deltaLinks.updated:=""
    This._internals._deltaLinks.deleted:=""
    
    // Pull interval in seconds (default: 30 seconds)
    This._internals._pullInterval:=cs._NotificationHelper.me.parsePullInterval($inParameters)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get endPoint : Text
/**
 * @function get endPoint
 * @returns {Text} Webhook URL configured at construction (`""` in pull mode)
 */
    
    return This._internals._endPoint
    
    
    // ----------------------------------------------------
    
    
Function get expiration : Text
/**
 * @function get expiration
 * @returns {Text} ISO 8601 expiration date/time of the current Graph subscription;
 *   empty string in pull mode or before `start()` is called
 */
    
    return This._internals._expiration
    
    
    // ----------------------------------------------------
    
    
Function get isStarted : Boolean
/**
 * @function get isStarted
 * @returns {Boolean} `True` when monitoring is active
 */
    
    return This._internals._isStarted
    
    
    // ----------------------------------------------------
    
    
Function get timer : Integer
/**
 * @function get timer
 * @returns {Integer} Pull polling interval in seconds (default 30; pull mode only)
 */
    
    return This._internals._pullInterval
    
    
    // ----------------------------------------------------
    
    
Function start() : Object
/**
 * @function start
 * @returns {Object} Status object
 * @description Starts change notifications.
 *   - **Push mode** (`endPoint` set): creates a Graph subscription via
 *     `POST /subscriptions`; starts a background worker monitoring loop
 *   - **Pull mode** (no `endPoint`): immediately starts the polling worker loop
 *
 *   No-op when already started. See inline comment for full mode description.
 */
    
/*
	Starts change notifications.
	
	Two modes:
	- Push (webhook): if endPoint is provided in the notification parameters, creates a
	  Microsoft Graph subscription and receives real-time notifications via webhook.
	- Pull (delta query): if no endPoint, polls the delta endpoint periodically
	  to detect changes. The polling interval is configurable via pullInterval (seconds).
	
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
 * @returns {Object} Status object
 * @description Stops change notifications:
 *   - **Push mode**: deletes the Graph subscription via `DELETE /subscriptions/{id}`;
 *     kills the monitor worker; cleans up Storage
 *   - **Pull mode**: signals the polling worker to stop; kills it; cleans up Storage
 *
 *   No-op when not started. See inline comment for details.
 */
    
/*
	Stops change notifications.
	In push mode, deletes the Microsoft Graph subscription.
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
    
    This._internals._subscriptionId:=""
    This._internals._state:=""
    This._internals._deltaLinks.created:=""
    This._internals._deltaLinks.updated:=""
    This._internals._deltaLinks.deleted:=""
    If (Value type(This._internals._expiration)=Is text)
        This._internals._expiration:=""
    End if 
    
    return This._returnStatus()
    
    
    // Mark: - [Private] Push mode (webhook)
    // ----------------------------------------------------
    
    
Function _startPush($inState : Text) : Object
/**
 * @function _startPush
 * @private
 * @param {Text} $inState - UUID key for `Storage.graphNotifications`
 * @returns {Object} Status object
 * @description Creates a Microsoft Graph subscription (`POST /subscriptions`),
 *   registers it in Storage, and starts the monitoring worker loop.
 *   Cleans up Storage on failure.
 */
    
    var $notificationUrl : Text:=cs._NotificationHelper.me.buildNotificationUrl(This._internals._endPoint; "/4dnk-graph-notification"; $inState)
    If (Length($notificationUrl)=0)
        This._throwError(2; {attribute: "endPoint"})
        return This._returnStatus()
    End if 
    
    // Ensure a web server is available for receiving notifications
    var $wsResult : Object:=cs._NotificationHelper.me.ensureWebServer(This._internals._endPoint)
    If (Not($wsResult.success))
        This._throwError(7; {port: $wsResult.port})
        return This._returnStatus()
    End if 
    
    var $changeType : Text:=This._computeChangeType()
    var $expirationDateTime : Text:=This._computeExpiration(4200)
    
    // Register in Storage so the webhook handler can find pending notifications
    cs._NotificationHelper.me.registerInStorage("graphNotifications"; $inState; {subscriptionId: ""; pending: []})
    
    // Create the subscription via POST /subscriptions
    var $body : Object:={}
    $body.changeType:=$changeType
    $body.notificationUrl:=$notificationUrl
    $body.resource:=This._internals._resource
    $body.expirationDateTime:=$expirationDateTime
    
    var $headers : Object:={}
    $headers["Content-Type"]:="application/json"
    
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; Super._getURL()+"subscriptions"; $headers; JSON Stringify($body))
    
    If (($response#Null) && (Length(String($response.id))>0))
        
        This._internals._subscriptionId:=$response.id
        This._internals._expiration:=String($response.expirationDateTime)
        This._internals._isStarted:=True
        
        Use (Storage.graphNotifications[$inState])
            Storage.graphNotifications[$inState].subscriptionId:=$response.id
        End use 
        
        This._startMonitoring()
        return This._returnStatus()
    End if 
    
    // Clean up Storage if subscription creation failed
    cs._NotificationHelper.me.cleanupStorage("graphNotifications"; $inState)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _stopPush($inState : Text)
/**
 * @function _stopPush
 * @private
 * @param {Text} $inState - UUID key for `Storage.graphNotifications`
 * @description Signals the monitor worker to stop, kills it, deletes the Graph subscription,
 *   and removes the entry from Storage
 */
    
    
    // Signal the monitor to stop via Storage
    cs._NotificationHelper.me.signalStop("graphNotifications"; $inState)
    
    // Kill the monitor worker
    KILL WORKER("4DNK_Monitor_"+$inState)
    
    // Delete the subscription from Microsoft Graph
    If (Length(This._internals._subscriptionId)>0)
        Super._sendRequestAndWaitResponse("DELETE"; Super._getURL()+"subscriptions/"+This._internals._subscriptionId)
    End if 
    
    // Clean up Storage
    cs._NotificationHelper.me.cleanupStorage("graphNotifications"; $inState)
    
    
    // Mark: - [Private] Pull mode (delta query)
    // ----------------------------------------------------
    
    
Function _startPull($inState : Text) : Object
/**
 * @function _startPull
 * @private
 * @param {Text} $inState - UUID key for `Storage.graphNotifications`
 * @returns {Object} Status object
 * @description Registers the monitor in Storage and starts the delta-polling worker loop
 */
    
    // Register in Storage for the monitor active flag
    cs._NotificationHelper.me.registerInStorage("graphNotifications"; $inState; Null)
    
    This._internals._isStarted:=True
    This._startMonitoring()
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _stopPull($inState : Text)
/**
 * @function _stopPull
 * @private
 * @param {Text} $inState - UUID key for `Storage.graphNotifications`
 * @description Signals the polling worker to stop, kills it, and removes the entry from Storage
 */
    
    
    // Signal the monitor to stop
    cs._NotificationHelper.me.signalStop("graphNotifications"; $inState)
    
    // Kill the monitor worker
    KILL WORKER("4DNK_Monitor_"+$inState)
    
    // Clean up Storage
    cs._NotificationHelper.me.cleanupStorage("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _initialDeltaSync($inChangeType : Text) : Text
/**
 * @function _initialDeltaSync
 * @private
 * @param {Text} $inChangeType - Graph changeType to track: `"created"`, `"updated"`,
 *   or `"deleted"`
 * @returns {Text} Delta link URL to use for subsequent polls; empty string on failure
 * @description Performs an initial delta sync with `$deltatoken=latest` to obtain
 *   a `deltaLink` for tracking future changes of one type.
 *   Used only for resources that support `changeType` filtering (currently mail).
 *   See inline comment for details.
 */
    
/*
    Performs initial delta sync to obtain a deltaLink for tracking future mail changes
    for one Graph changeType: created, updated or deleted.
    
    This is used only for resources where Microsoft Graph supports changeType filtering
    on delta queries, currently mail messages in this class.
*/
    
    var $deltaResource : Text:=(Length(This._internals._deltaResource)>0) ? This._internals._deltaResource : This._internals._resource
    var $url : Text:=Super._getURL()+$deltaResource+"/delta?$select=id&changeType="+$inChangeType+"&$deltatoken=latest"
    var $deltaLink : Text:=""
    var $headers : Object:={Prefer: "odata.maxpagesize=999"}
    
    Try
        
        var $response : Object
        
        Repeat 
            $response:=Super._sendRequestAndWaitResponse("GET"; $url; $headers)
            
            If ($response#Null)
                If (Length(String($response["@odata.deltaLink"]))>0)
                    $deltaLink:=String($response["@odata.deltaLink"])
                Else 
                    $url:=String($response["@odata.nextLink"])
                End if 
            End if 
        Until (($deltaLink#"") | ($response=Null) | ($url=""))
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return $deltaLink
    
    
    // ----------------------------------------------------
    
    
Function _initialDeltaSyncWithKnownIds() : Text
/**
 * @function _initialDeltaSyncWithKnownIds
 * @private
 * @returns {Text} Delta link URL to use for subsequent polls; empty string on failure
 * @description Performs a full initial delta sync and seeds `_internals._knownIds` with
 *   all existing item IDs.
 *   Used for calendar/event delta where Graph does not support `changeType` filtering;
 *   subsequent polls use the `knownIds` cache to classify changes as
 *   created, updated, or deleted. See inline comment for details.
 */
    
/*
    Performs a real initial delta sync and fills _knownIds with all existing items.
    
    This is used for calendar/event delta, where Graph does not reliably support
    changeType filtering. After this initial sync:
    - @removed       => deleted
    - unknown id     => created
    - already known  => updated
*/
    
    This._internals._knownIds:=[]
    
    var $deltaResource : Text:=(Length(This._internals._deltaResource)>0) ? This._internals._deltaResource : This._internals._resource
    var $url : Text:=Super._getURL()+$deltaResource+"/delta"
    
    // calendarView/delta requires startDateTime and endDateTime.
    If (This._internals._type="event")
        var $now : cs._DateTime:=cs._DateTime.new()
        var $end : cs._DateTime:=cs._DateTime.new()
        $end.addTime(365*86400)  // 1 year window
        $url+="?startDateTime="+String($now.date; ISO date GMT; $now.time)+"&endDateTime="+String($end.date; ISO date GMT; $end.time)
    Else 
        $url+="?$select=id"
    End if 
    
    var $deltaLink : Text:=""
    var $headers : Object:={Prefer: "odata.maxpagesize=999"}
    
    Try
        
        var $response : Object
        
        Repeat 
            $response:=Super._sendRequestAndWaitResponse("GET"; $url; $headers)
            
            If ($response#Null)
                If (Value type($response["value"])=Is collection)
                    var $entry : Object
                    For each ($entry; $response["value"])
                        // During initial sync, only existing items should seed the cache.
                        If (($entry["@removed"]=Null) && (Length(String($entry.id))>0))
                            If (This._internals._knownIds.indexOf(String($entry.id))<0)
                                This._internals._knownIds.push(String($entry.id))
                            End if 
                        End if 
                    End for each 
                End if 
                
                If (Length(String($response["@odata.deltaLink"]))>0)
                    $deltaLink:=String($response["@odata.deltaLink"])
                Else 
                    $url:=String($response["@odata.nextLink"])
                End if 
            End if 
        Until (($deltaLink#"") | ($response=Null) | ($url=""))
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return $deltaLink
    
    
    // ----------------------------------------------------
    
    
Function _pollDelta() : Collection
/**
 * @function _pollDelta
 * @private
 * @returns {Collection} Collection of `{resourceId; changeType}` objects detected since
 *   the last poll
 * @description Dispatches to `_pollDeltaUsingChangeTypeStreams` (mail) or
 *   `_pollDeltaUsingKnownIds` (calendar/event) based on `_supportsChangeTypeFiltering`.
 *   See inline comment for strategy details.
 */
    
/*
    Polls the delta endpoint.
    
    Mail uses 3 filtered streams, one deltaLink per changeType.
    Calendar/event uses one stream and the knownIds cache initialized by
    _initialDeltaSyncWithKnownIds().
*/
    
    If (This._internals._supportsChangeTypeFiltering)
        return This._pollDeltaUsingChangeTypeStreams()
    Else 
        return This._pollDeltaUsingKnownIds()
    End if 
    
    
    // ----------------------------------------------------
    
    
Function _pollDeltaUsingChangeTypeStreams() : Collection
/**
 * @function _pollDeltaUsingChangeTypeStreams
 * @private
 * @returns {Collection} Combined collection of `{resourceId; changeType}` from all
 *   enabled change type streams
 * @description Polls each delta stream (one per enabled changeType) and merges results.
 *   Used for mail, where Graph supports `changeType` filtering on delta queries.
 */
    
    var $items : Collection:=[]
    var $changeTypes : Collection:=This._computePullChangeTypes()
    var $changeType : Text
    
    For each ($changeType; $changeTypes)
        $items.combine(This._pollDeltaForChangeType($changeType))
    End for each 
    
    return $items
    
    
    // ----------------------------------------------------
    
    
Function _pollDeltaForChangeType($inChangeType : Text) : Collection
/**
 * @function _pollDeltaForChangeType
 * @private
 * @param {Text} $inChangeType - The change type stream to poll: `"created"`, `"updated"`,
 *   or `"deleted"`
 * @returns {Collection} Collection of `{resourceId; changeType}` objects found on this stream
 * @description Follows the delta link for one change type, paginating until the new
 *   delta link is returned; updates `_internals._deltaLinks[$inChangeType]`
 */
    
    var $items : Collection:=[]
    var $url : Text:=String(This._internals._deltaLinks[$inChangeType])
    
    If (Length($url)=0)
        return $items
    End if 
    
    Try
        
        While (Length($url)>0)
            var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $url)
            
            If ($response#Null)
                If (Value type($response["value"])=Is collection)
                    var $entry : Object
                    For each ($entry; $response["value"])
                        If (Length(String($entry.id))>0)
                            var $item : Object:={}
                            $item.resourceId:=String($entry.id)
                            $item.changeType:=$inChangeType
                            $items.push($item)
                        End if 
                    End for each 
                End if 
                
                // Follow pagination or get new deltaLink for this changeType.
                If (Length(String($response["@odata.nextLink"]))>0)
                    $url:=String($response["@odata.nextLink"])
                Else 
                    If (Length(String($response["@odata.deltaLink"]))>0)
                        This._internals._deltaLinks[$inChangeType]:=String($response["@odata.deltaLink"])
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
    
    
    // ----------------------------------------------------
    
    
Function _pollDeltaUsingKnownIds() : Collection
/**
 * @function _pollDeltaUsingKnownIds
 * @private
 * @returns {Collection} Collection of `{resourceId; changeType}` objects detected since
 *   the last poll
 * @description Polls the single delta stream and classifies each entry:
 *   - `@removed` present → `"deleted"` (also removes from `_knownIds`)
 *   - ID not in `_knownIds` → `"created"` (also adds to `_knownIds`)
 *   - ID already in `_knownIds` → `"updated"`
 *   Only items whose changeType is enabled by a callback are included.
 */
    
    var $items : Collection:=[]
    var $url : Text:=String(This._internals._deltaLink)
    
    If (Length($url)=0)
        return $items
    End if 
    
    Try
        
        While (Length($url)>0)
            var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $url)
            
            If ($response#Null)
                If (Value type($response["value"])=Is collection)
                    var $entry : Object
                    For each ($entry; $response["value"])
                        var $resourceId : Text:=String($entry.id)
                        If (Length($resourceId)>0)
                            var $item : Object:={}
                            $item.resourceId:=$resourceId
                            
                            If ($entry["@removed"]#Null)
                                $item.changeType:="deleted"
                                This._removeKnownId($resourceId)
                            Else 
                                If (This._internals._knownIds.indexOf($resourceId)<0)
                                    $item.changeType:="created"
                                    This._internals._knownIds.push($resourceId)
                                Else 
                                    $item.changeType:="updated"
                                End if 
                            End if 
                            
                            If (This._shouldDispatchPullChangeType($item.changeType))
                                $items.push($item)
                            End if 
                        End if 
                    End for each 
                End if 
                
                // Follow pagination or get new deltaLink for this resource.
                If (Length(String($response["@odata.nextLink"]))>0)
                    $url:=String($response["@odata.nextLink"])
                Else 
                    If (Length(String($response["@odata.deltaLink"]))>0)
                        This._internals._deltaLink:=String($response["@odata.deltaLink"])
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
    
    
    // ----------------------------------------------------
    
    
Function _shouldDispatchPullChangeType($inChangeType : Text) : Boolean
/**
 * @function _shouldDispatchPullChangeType
 * @private
 * @param {Text} $inChangeType - `"created"`, `"updated"`, or `"deleted"`
 * @returns {Boolean} `True` when a callback is registered for this change type
 * @description Used in `_pollDeltaUsingKnownIds` to filter out change types
 *   that have no registered callback
 */
    
    Case of 
        : ($inChangeType="created")
            return This._internals._callbacks.onCreate#Null
        : ($inChangeType="updated")
            return This._internals._callbacks.onModify#Null
        : ($inChangeType="deleted")
            return This._internals._callbacks.onDelete#Null
    End case 
    
    return False
    
    
    // ----------------------------------------------------
    
    
Function _removeKnownId($inResourceId : Text)
/**
 * @function _removeKnownId
 * @private
 * @param {Text} $inResourceId - Item ID to remove from the `_knownIds` cache
 * @description Finds and removes the ID from `_internals._knownIds`;
 *   used when processing a `"deleted"` delta entry
 */
    
    var $index : Integer:=This._internals._knownIds.indexOf($inResourceId)
    If ($index>=0)
        This._internals._knownIds.remove($index)
    End if 
    
    
    // Mark: - [Private] Common
    // ----------------------------------------------------
    
    
Function _computePullChangeTypes() : Collection
/**
 * @function _computePullChangeTypes
 * @private
 * @returns {Collection} Collection of enabled change type strings; defaults to
 *   `["created"; "updated"; "deleted"]` when no callbacks are registered
 * @description Builds the list of change types to poll based on which
 *   `onCreate`, `onModify`, and `onDelete` callbacks are set
 */
    
    var $types : Collection:=[]
    
    If (This._internals._callbacks.onCreate#Null)
        $types.push("created")
    End if 
    If (This._internals._callbacks.onModify#Null)
        $types.push("updated")
    End if 
    If (This._internals._callbacks.onDelete#Null)
        $types.push("deleted")
    End if 
    If ($types.length=0)
        $types:=["created"; "updated"; "deleted"]
    End if 
    
    return $types
    
    
    // ----------------------------------------------------
    
    
Function _computeChangeType() : Text
/**
 * @function _computeChangeType
 * @private
 * @returns {Text} Comma-separated Graph `changeType` string
 *   (e.g. `"created,updated,deleted"`) for use in a subscription body;
 *   defaults to all three when no callbacks are registered
 */
    
    var $types : Collection:=[]
    
    If (This._internals._callbacks.onCreate#Null)
        $types.push("created")
    End if 
    If (This._internals._callbacks.onModify#Null)
        $types.push("updated")
    End if 
    If (This._internals._callbacks.onDelete#Null)
        $types.push("deleted")
    End if 
    If ($types.length=0)
        $types:=["created"; "updated"; "deleted"]
    End if 
    
    return $types.join(",")
    
    
    // ----------------------------------------------------
    
    
Function _computeExpiration($inMinutes : Integer) : Text
/**
 * @function _computeExpiration
 * @private
 * @param {Integer} $inMinutes - Number of minutes from now
 * @returns {Text} ISO 8601 date-time string (UTC) for the subscription `expirationDateTime`
 */
    
    var $dt : cs._DateTime:=cs._DateTime.new()
    $dt.addTime($inMinutes*60)
    
    return String($dt.date; ISO date GMT; $dt.time)
    
    
    // ----------------------------------------------------
    
    
Function _startMonitoring()
/**
 * @function _startMonitoring
 * @private
 * @description Launches the `_monitorLoop` method in a dedicated background worker named
 *   `"4DNK_Monitor_"+state`. The worker receives `This`, the caller worker name,
 *   the state UUID, and the form window reference.
 */
    
    var $self : cs.GraphNotification:=This
    var $workerName : Text:=This._internals._workerName
    var $state : Text:=This._internals._state
    var $formWindow : Integer:=This._internals._formWindow
    
    CALL WORKER("4DNK_Monitor_"+$state; Formula($1._monitorLoop($2; $3; $4)); $self; $workerName; $state; $formWindow)
    
    
    // ----------------------------------------------------
    
    
Function _monitorLoop($inWorkerName : Text; $inState : Text; $inFormWindow : Integer)
/**
 * @function _monitorLoop
 * @private
 * @param {Text} $inWorkerName - Name of the worker/process to dispatch callbacks to
 * @param {Text} $inState - UUID key for `Storage.graphNotifications`
 * @param {Integer} $inFormWindow - Form window reference for `CALL FORM` dispatch
 * @description Main monitoring loop running in the background worker.
 *   - **Push mode**: drains `Storage.graphNotifications[state].pending` and
 *     renews the subscription when close to expiry
 *   - **Pull mode**: polls the delta endpoint at `_pullInterval` seconds intervals
 *
 *   Dispatches callbacks via `_NotificationHelper.callbackInCallerContext`.
 *   See inline comment for mode details.
 */
    
/*
	Main monitoring loop, runs in a dedicated background worker.
	
	Push mode: checks Storage for pending notifications pushed by the webhook handler.
	Pull mode: polls the delta endpoint at a configurable interval.
	
	In both modes, dispatches callbacks to the original caller context via CALL FORM or CALL WORKER.
*/
    If (This._internals._mode="pull")
        If (This._internals._supportsChangeTypeFiltering)
            // Mail delta: perform one initial sync per requested changeType.
            var $changeTypes : Collection:=This._computePullChangeTypes()
            var $changeType : Text
            For each ($changeType; $changeTypes)
                This._internals._deltaLinks[$changeType]:=This._initialDeltaSync($changeType)
            End for each 
        Else 
            // Calendar/event delta: one stream + knownIds seeded by a real initial sync.
            This._internals._deltaLink:=This._initialDeltaSyncWithKnownIds()
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
        
        If (This._internals._mode="push")
            // Push mode: drain pending items from Storage
            $items:=This._drainPendingItems($inState)
            
            // Check if subscription renewal is needed
            This._renewIfNeeded($renewalThreshold)
        Else 
            // Pull mode: poll the delta endpoint
            $items:=This._pollDelta()
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
 * @param {Text} $inState - UUID key for `Storage.graphNotifications`
 * @returns {Boolean} `True` when the monitor should keep running
 * @description Delegates to `_NotificationHelper.isMonitorActive`
 */
    
    return cs._NotificationHelper.me.isMonitorActive("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _drainPendingItems($inState : Text) : Collection
/**
 * @function _drainPendingItems
 * @private
 * @param {Text} $inState - UUID key for `Storage.graphNotifications`
 * @returns {Collection} All pending `{changeType; resourceId}` items since the last drain
 * @description Delegates to `_NotificationHelper.drainPendingItems`;
 *   used in push mode to collect webhook-delivered notifications
 */
    
    return cs._NotificationHelper.me.drainPendingItems("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _dispatchCallbacks($inItems : Collection)
/**
 * @function _dispatchCallbacks
 * @private
 * @param {Collection} $inItems - Collection of `{changeType; resourceId}` objects to dispatch
 * @description Delegates to `_NotificationHelper.dispatchCallbacks`, forwarding
 *   `_type`, registered callbacks, and the owner client
 */
    
    cs._NotificationHelper.me.dispatchCallbacks($inItems; This._internals._type; This._internals._callbacks; This._internals._owner)
    
    
    // ----------------------------------------------------
    
    
Function _renewIfNeeded($inThresholdSeconds : Integer)
/**
 * @function _renewIfNeeded
 * @private
 * @param {Text} $inThresholdSeconds - Renew when fewer than this many seconds remain
 *   before the subscription expires
 * @description Compares current time with `_internals._expiration`; if the remaining
 *   time is below the threshold, patches the Graph subscription via
 *   `PATCH /subscriptions/{id}` with a new `expirationDateTime` of +70 minutes.
 */
    
    If (Length(This._internals._expiration)=0)
        return 
    End if 
    
    var $expirationDT : cs._DateTime:=cs._DateTime.new(This._internals._expiration)
    var $nowDT : cs._DateTime:=cs._DateTime.new()
    
    var $expirationSeconds : Integer:=($expirationDT.date-$nowDT.date)*86400+($expirationDT.time-$nowDT.time)
    
    If ($expirationSeconds<$inThresholdSeconds)
        
        var $newExpiration : Text:=This._computeExpiration(4200)
        
        var $body : Object:={}
        $body.expirationDateTime:=$newExpiration
        
        var $headers : Object:={}
        $headers["Content-Type"]:="application/json"
        
        var $response : Object:=Try(Super._sendRequestAndWaitResponse("PATCH"; Super._getURL()+"subscriptions/"+This._internals._subscriptionId; $headers; JSON Stringify($body)))
        
        If (($response#Null) && (Length(String($response.expirationDateTime))>0))
            This._internals._expiration:=String($response.expirationDateTime)
        End if 
        
    End if 
    
