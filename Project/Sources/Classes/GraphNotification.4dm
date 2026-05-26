Class extends _GraphAPI


Class constructor($inType : Text; $inProvider : cs.OAuth2Provider; $inParameters : Object; $inResource : Text; $inUserId : Text; $inOwner : Object)
    
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
    
    return This._internals._endPoint
    
    
    // ----------------------------------------------------
    
    
Function get expiration : Text
    
    return This._internals._expiration
    
    
    // ----------------------------------------------------
    
    
Function get isStarted : Boolean
    
    return This._internals._isStarted
    
    
    // ----------------------------------------------------
    
    
Function get timer : Integer
    
    return This._internals._pullInterval
    
    
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
    
    
Function _initialDeltaSync($inChangeType : Text) : Text
    
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
    
    var $items : Collection:=[]
    var $changeTypes : Collection:=This._computePullChangeTypes()
    var $changeType : Text
    
    For each ($changeType; $changeTypes)
        $items.combine(This._pollDeltaForChangeType($changeType))
    End for each 
    
    return $items
    
    
    // ----------------------------------------------------
    
    
Function _pollDeltaForChangeType($inChangeType : Text) : Collection
    
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
    
    var $index : Integer:=This._internals._knownIds.indexOf($inResourceId)
    If ($index>=0)
        This._internals._knownIds.remove($index)
    End if 
    
    
    // Mark: - [Private] Common
    // ----------------------------------------------------
    
    
Function _computePullChangeTypes() : Collection
    
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
    var $formWindow : Integer:=This._internals._formWindow
    
    CALL WORKER("4DNK_Monitor_"+$state; Formula($1._monitorLoop($2; $3; $4)); $self; $workerName; $state; $formWindow)
    
    
    // ----------------------------------------------------
    
    
Function _monitorLoop($inWorkerName : Text; $inState : Text; $inFormWindow : Integer)
    
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
    
    return cs._NotificationHelper.me.isMonitorActive("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _drainPendingItems($inState : Text) : Collection
    
    return cs._NotificationHelper.me.drainPendingItems("graphNotifications"; $inState)
    
    
    // ----------------------------------------------------
    
    
Function _dispatchCallbacks($inItems : Collection)
    
    cs._NotificationHelper.me.dispatchCallbacks($inItems; This._internals._type; This._internals._callbacks; This._internals._owner)
    
    
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
        
        var $response : Object:=Try(Super._sendRequestAndWaitResponse("PATCH"; Super._getURL()+"subscriptions/"+This._internals._subscriptionId; $headers; JSON Stringify($body)))
        
        If (($response#Null) && (Length(String($response.expirationDateTime))>0))
            This._internals._expiration:=String($response.expirationDateTime)
        End if 
        
    End if 
    
