Class extends _GraphAPI


Class constructor($inType : Text; $inProvider : cs.OAuth2Provider; $inParameters : Object; $inResource : Text; $inUserId : Text)
    
    Super($inProvider)
    
    This._internals._callbacks:=cs._NotificationHelper.me.parseCallbacks($inParameters)
    
    This._internals._type:=$inType  // "mail" or "event", used for callback eventType like "mailCreated" or "eventModified"
    This._internals._resource:=$inResource
    This._internals._userId:=$inUserId
    This._internals._subscriptionId:=""
    This._internals._state:=""
    This._internals._workerName:=""
    This._internals._isStarted:=False
    This._internals._expiration:=""
    
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
    This._internals._deltaLink:=""
    This._internals._knownIds:=[]
    
    // Pull interval in seconds (default: 30 seconds)
    This._internals._pullInterval:=cs._NotificationHelper.me.parsePullInterval($inParameters)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get expiration : Text
    
    return This._internals._expiration
    
    
    // ----------------------------------------------------
    
    
Function get isStarted : Boolean
    
    return This._internals._isStarted
    
    
    // ----------------------------------------------------
    
    
Function start() : Object
    
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
    Super._throwErrors(False)
    
    var $result : Object
    var $state : Text:=Generate UUID
    This._internals._state:=$state
    This._internals._workerName:=Current process name
    
    If (This._internals._mode="push")
        $result:=This._startPush($state)
    Else 
        $result:=This._startPull($state)
    End if 
    
    Super._throwErrors(True)
    return $result
    
    
    // ----------------------------------------------------
    
    
Function stop() : Object
    
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
    Super._throwErrors(False)
    
    This._internals._isStarted:=False
    
    var $state : Text:=This._internals._state
    
    If (This._internals._mode="push")
        This._stopPush($state)
    Else 
        This._stopPull($state)
    End if 
    
    This._internals._subscriptionId:=""
    This._internals._expiration:=""
    This._internals._state:=""
    This._internals._deltaLink:=""
    
    Super._throwErrors(True)
    return This._returnStatus()
    
    
    // Mark: - [Private] Push mode (webhook)
    // ----------------------------------------------------
    
    
Function _startPush($inState : Text) : Object
    
    var $notificationUrl : Text:=cs._NotificationHelper.me.buildNotificationUrl(This._internals._endPoint; "/$4dk-graph-notification"; $inState)
    If (Length($notificationUrl)=0)
        This._throwError(2; {attribute: "endPoint"})
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
        
        Use (Storage.notifications[$inState])
            Storage.notifications[$inState].subscriptionId:=$response.id
        End use 
        
        This._startMonitoring()
        return This._returnStatus()
    End if 
    
    // Clean up Storage if subscription creation failed
    cs._NotificationHelper.me.cleanupStorage("graphNotifications"; $inState)
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _stopPush($inState : Text)
    
    
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
    
    // Register in Storage for the monitor active flag
    cs._NotificationHelper.me.registerInStorage("graphNotifications"; $inState; Null)
    
    This._internals._isStarted:=True
    This._startMonitoring()
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _stopPull($inState : Text)
    
    
    // Signal the monitor to stop
    cs._NotificationHelper.me.signalStop("graphNotifications"; $inState)
    
    // Kill the monitor worker
    KILL WORKER("4DNK_Monitor_"+$inState)
    
    // Clean up Storage
    cs._NotificationHelper.me.cleanupStorage("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _initialDeltaSync() : Text
    
/*
	Performs initial delta sync to obtain a deltaLink for tracking future changes.
	
	The Graph API requires a full initial round-trip through all existing items
	before returning a @odata.deltaLink. We use $select=id and 
	Prefer: odata.maxpagesize=999 to minimize both payload size and the number 
	of HTTP requests (e.g. 5000 messages = ~5 pages instead of 500+).
	
	Existing items are ignored — only the final deltaLink matters.
	After this call, only future changes will be reported via _pollDelta().
	
	See: https://learn.microsoft.com/en-us/graph/delta-query-messages
*/
    
    var $url : Text:=Super._getURL()+This._internals._resource+"/delta?$select=id&$deltatoken=latest"
    var $deltaLink : Text:=""
    var $headers : Object:={Prefer: "odata.maxpagesize=999"}
    
    Super._throwErrors(False)
    
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
    
    Super._throwErrors(True)
    
    return $deltaLink
    
    
    // ----------------------------------------------------
    
    
Function _pollDelta() : Collection
    
/*
	Polls the delta endpoint for changes since the last deltaLink.
	Returns a collection of {changeType; resourceId} items.
	Uses a known IDs cache to distinguish created vs updated.
	
	Deleted items are marked with @removed in the delta response.
*/
    
    var $items : Collection:=[]
    var $url : Text:=This._internals._deltaLink
    
    If (Length($url)=0)
        return $items
    End if 
    
    Super._throwErrors(False)
    
    While (Length($url)>0)
        var $response : Object:=Super._sendRequestAndWaitResponse("GET"; $url)
        
        If ($response#Null)
            If (Value type($response["value"])=Is collection)
                var $entry : Object
                For each ($entry; $response["value"])
                    var $item : Object:={}
                    $item.resourceId:=String($entry.id)
                    
                    If (Value type($entry["@removed"])=Is object)
                        // Deleted resource
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
            
            // Follow pagination or get new deltaLink
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
    
    Super._throwErrors(True)
    
    return $items
    
    
    // Mark: - [Private] Common
    // ----------------------------------------------------
    
    
Function _computeChangeType() : Text
    
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
    
    var $dt : cs._DateTime:=cs._DateTime.new()
    $dt.addTime($inMinutes*60)
    
    return String($dt.date; ISO date GMT; $dt.time)
    
    
    // ----------------------------------------------------
    
    
Function _startMonitoring()
    
    var $self : cs.GraphNotification:=This
    var $workerName : Text:=This._internals._workerName
    var $state : Text:=This._internals._state
    
    CALL WORKER("4DNK_Monitor_"+$state; Formula($1._monitorLoop($2; $3)); $self; $workerName; $state)
    
    
    // ----------------------------------------------------
    
    
Function _monitorLoop($inWorkerName : Text; $inState : Text)
    
/*
	Main monitoring loop, runs in a dedicated background worker.
	
	Push mode: checks Storage for pending notifications pushed by the webhook handler.
	Pull mode: polls the delta endpoint at a configurable interval.
	
	In both modes, dispatches callbacks to the original worker via CALL WORKER.
*/
    If (This._internals._mode="pull")
        // Delta query: perform the initial sync to get the first deltaLink
        This._internals._deltaLink:=This._initialDeltaSync()
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
            CALL WORKER($inWorkerName; Formula($1._dispatchCallbacks($2)); This; $items)
        End if 
        
    End while 
    
    KILL WORKER
    
    
    // ----------------------------------------------------
    
    
Function _isMonitorActive($inState : Text) : Boolean
    
    return cs._NotificationHelper.me.isMonitorActive("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _drainPendingItems($inState : Text) : Collection
    
    return cs._NotificationHelper.me.drainPendingItems("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _dispatchCallbacks($inItems : Collection)
    
    cs._NotificationHelper.me.dispatchCallbacks($inItems; This._internals._type; This._internals._callbacks)
    
    
    // ----------------------------------------------------
    
    
Function _renewIfNeeded($inThresholdSeconds : Integer)
    
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
        
        Super._throwErrors(False)
        var $response : Object:=Super._sendRequestAndWaitResponse("PATCH"; Super._getURL()+"subscriptions/"+This._internals._subscriptionId; $headers; JSON Stringify($body))
        Super._throwErrors(True)
        
        If (($response#Null) && (Length(String($response.expirationDateTime))>0))
            This._internals._expiration:=String($response.expirationDateTime)
        End if 
        
    End if 
    
