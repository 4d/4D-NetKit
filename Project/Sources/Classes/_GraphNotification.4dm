Class extends _GraphAPI


Class constructor($inProvider : cs.OAuth2Provider; $inCallbacks : Object; $inResource : Text; $inUserId : Text)
    
    Super($inProvider)
    
    This._internals._callbacks:={onCreate: Null; onDelete: Null; onModify: Null}
    
    If (($inCallbacks#Null) && (Value type($inCallbacks)=Is object))
        If (Value type($inCallbacks.onCreate)#Is undefined)
            This._internals._callbacks.onCreate:=$inCallbacks.onCreate
        End if 
        If (Value type($inCallbacks.onDelete)#Is undefined)
            This._internals._callbacks.onDelete:=$inCallbacks.onDelete
        End if 
        If (Value type($inCallbacks.onModify)#Is undefined)
            This._internals._callbacks.onModify:=$inCallbacks.onModify
        End if 
    End if 
    
    This._internals._resource:=$inResource
    This._internals._userId:=$inUserId
    This._internals._subscriptionId:=""
    This._internals._state:=""
    This._internals._workerName:=""
    This._internals._isStarted:=False
    This._internals._expiration:=""
    
    
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
	Creates a Microsoft Graph subscription for change notifications.
	The subscription targets the resource (e.g. me/messages) and uses
	a webhook URL derived from the OAuth2 provider's redirect URI.
	
	Callbacks (onCreate, onDelete, onModify) are dispatched in the
	worker where start() was called.
	
	See: https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions
*/
    
    If (This._internals._isStarted)
        return This._returnStatus()
    End if 
    
    // Build the notification URL from the OAuth provider's redirect URI
    var $state : Text:=Generate UUID
    var $notificationUrl : Text:=This._buildNotificationUrl($state)
    if(length($notificationUrl)=0)
        This._throwError(2; {attribute: "endPoint"})
        return This._returnStatus()
    end if

    Super._clearErrorStack()
    Super._throwErrors(False)
    
    // Generate a unique state identifier for this subscription
    This._internals._state:=$state
    This._internals._workerName:=Current process name
    
    // Start the web server to receive notifications (if not already running)
    This._startWebServer($notificationUrl)
    
    // Compute change types from provided callbacks
    var $changeType : Text:=This._computeChangeType()
    
    // Compute expiration (max 4230 min for messages/events; use 4200 for safety margin)
    var $expirationDateTime : Text:=This._computeExpiration(4200)
    
    // Register in Storage so the webhook handler can find pending notifications
    Use (Storage)
        If (Storage.notifications=Null)
            Storage.notifications:=New shared object()
        End if 
        Use (Storage.notifications)
            Storage.notifications[$state]:=New shared object(\
             "subscriptionId"; ""; \
             "isStarted"; True; \
             "pending"; New shared collection())
        End use 
    End use 
    
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
        
        // Store subscription ID in Storage for the webhook handler
        Use (Storage.notifications[$state])
            Storage.notifications[$state].subscriptionId:=$response.id
        End use 
        
        // Start the background monitoring loop
        This._startMonitoring()
        
        Super._throwErrors(True)
        return This._returnStatus()
    End if 
    
    // Clean up Storage if subscription creation failed
    Use (Storage)
        Use (Storage.notifications)
            OB REMOVE(Storage.notifications; $state)
        End use 
    End use 
    
    Super._throwErrors(True)
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function stop() : Object
    
/*
	Deletes the Microsoft Graph subscription and stops the monitoring loop.
	Cleans up the expiration date time.
	
	See: https://learn.microsoft.com/en-us/graph/api/subscription-delete
*/
    
    If (Not(This._internals._isStarted))
        return This._returnStatus()
    End if 
    
    Super._clearErrorStack()
    Super._throwErrors(False)
    
    This._internals._isStarted:=False
    
    // Signal the monitor to stop via Storage
    var $state : Text:=This._internals._state
    If (Length($state)>0)
        If ((Storage.notifications#Null) && OB Is defined(Storage.notifications; $state))
            Use (Storage.notifications[$state])
                Storage.notifications[$state].isStarted:=False
            End use 
        End if 
    End if 
    
    // Delete the subscription from Microsoft Graph
    If (Length(This._internals._subscriptionId)>0)
        Super._sendRequestAndWaitResponse("DELETE"; Super._getURL()+"subscriptions/"+This._internals._subscriptionId)
    End if 
    
    // Clean up Storage
    If (Length($state)>0)
        Use (Storage)
            If (Storage.notifications#Null)
                Use (Storage.notifications)
                    If (OB Is defined(Storage.notifications; $state))
                        OB REMOVE(Storage.notifications; $state)
                    End if 
                End use 
            End if 
        End use 
    End if 
    
    This._internals._subscriptionId:=""
    This._internals._expiration:=""
    This._internals._state:=""
    
    Super._throwErrors(True)
    return This._returnStatus()
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _buildNotificationUrl($inState : Text) : Text
    
    var $provider : cs.OAuth2Provider:=This._getOAuth2Provider()
    var $notificationUrl : Text:=""
    
    If (Length(String($provider.endPoint))>0)
        var $url : cs._URL:=cs._URL.new($provider.endPoint)
        
        $notificationUrl:=$url.scheme+"://"+$url.host
        
        If ($url.port>0)
            $notificationUrl+=":"+String($url.port)
        End if 
        $notificationUrl+="/$4dk-notification?state="+$inState
    Else 
        This._throwError(2; {attribute: "endPoint"})
    End if 
    
    
    return $notificationUrl
    
    
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
    
    // Compute UTC expiration = now + $inMinutes minutes, in ISO 8601 format
    var $dt : cs._DateTime:=cs._DateTime.new()
    $dt.addTime($inMinutes*60)
    
    return String($dt.date; ISO date GMT; $dt.time)
    
    
    // ----------------------------------------------------
    
    
Function _startMonitoring()
    
    // Launch a background worker that periodically checks for pending notifications
    // in Storage and dispatches callbacks to the original worker via CALL WORKER.
    // Objects are passed by reference through CALL WORKER, so the monitor worker
    // can access the same notification object.
    
    var $self : cs._GraphNotification:=This
    var $workerName : Text:=This._internals._workerName
    var $state : Text:=This._internals._state
    
    CALL WORKER("4DNK_Monitor_"+$state; Formula($1._monitorLoop($2; $3)); $self; $workerName; $state)
    
    
    // ----------------------------------------------------
    
    
Function _monitorLoop($inWorkerName : Text; $inState : Text)
    
    // This method runs in a dedicated background worker.
    // It periodically checks Storage for pending notifications pushed by the webhook handler,
    // and dispatches them to the original worker where start() was called.
    
    var $renewalThreshold : Integer:=3600  // Renew subscription 1 hour before expiration
    
    While (This._isMonitorActive($inState))
        
        // Sleep for 2 seconds between checks (120 ticks)
        DELAY PROCESS(Current process; 120)
        
        If (Not(This._isMonitorActive($inState)))
            break
        End if 
        
        // Drain pending notifications from Storage
        var $items : Collection:=This._drainPendingItems($inState)
        
        // Dispatch callbacks to the original worker
        If ($items.length>0)
            CALL WORKER($inWorkerName; Formula($1._dispatchCallbacks($2)); This; $items)
        End if 
        
        // Check if subscription renewal is needed
        This._renewIfNeeded($renewalThreshold)
        
    End while 
    
    // Kill this worker when done
    KILL WORKER
    
    
    // ----------------------------------------------------
    
    
Function _isMonitorActive($inState : Text) : Boolean
    
    If ((Storage.notifications#Null) && OB Is defined(Storage.notifications; $inState))
        return Bool(Storage.notifications[$inState].isStarted)
    End if 
    
    return False
    
    
    // ----------------------------------------------------
    
    
Function _drainPendingItems($inState : Text) : Collection
    
    // Atomically read and clear the pending notifications from Storage
    var $items : Collection:=[]
    
    If ((Storage.notifications#Null) && OB Is defined(Storage.notifications; $inState))
        Use (Storage.notifications[$inState])
            var $pending : Object:=Storage.notifications[$inState].pending
            var $i : Integer
            For ($i; 0; $pending.length-1)
                $items.push({changeType: String($pending[$i].changeType); resourceId: String($pending[$i].resourceId)})
            End for 
            $pending.clear()
        End use 
    End if 
    
    return $items
    
    
    // ----------------------------------------------------
    
    
Function _dispatchCallbacks($inItems : Collection)
    
    // This method is called in the original worker via CALL WORKER.
    // It invokes the user's callback formulas with the resource ID.
    
    var $item : Object
    
    For each ($item; $inItems)
        
        Case of 
            : ($item.changeType="created")
                If (This._internals._callbacks.onCreate#Null)
                    This._internals._callbacks.onCreate.call(Null; $item.resourceId)
                End if 
                
            : ($item.changeType="updated")
                If (This._internals._callbacks.onModify#Null)
                    This._internals._callbacks.onModify.call(Null; $item.resourceId)
                End if 
                
            : ($item.changeType="deleted")
                If (This._internals._callbacks.onDelete#Null)
                    This._internals._callbacks.onDelete.call(Null; $item.resourceId)
                End if 
        End case 
        
    End for each 
    
    
    // ----------------------------------------------------
    
    
Function _renewIfNeeded($inThresholdSeconds : Integer)
    
    // Renew the subscription if it's close to expiration
    
    If (Length(This._internals._expiration)=0)
        return 
    End if 
    
    var $expirationDT : cs._DateTime:=cs._DateTime.new(This._internals._expiration)
    var $nowDT : cs._DateTime:=cs._DateTime.new()
    
    // Check if remaining time is less than threshold
    var $expirationSeconds : Integer:=($expirationDT.date-$nowDT.date)*86400+($expirationDT.time-$nowDT.time)
    
    If ($expirationSeconds<$inThresholdSeconds)
        
        // Renew the subscription
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
    
    
    // ----------------------------------------------------
    
    
Function _startWebServer($notificationUrl : Text) : Boolean
    
    // Start the component web server on the redirectURI port (same as OAuth2 authentication)
    var $url : cs._URL:=cs._URL.new($notificationUrl)
    var $options : Object:={}
    $options.port:=$url.port
    $options.useTLS:=($url.scheme="https")
    
    If ($options.useTLS)
        $options.certificateFolder:=This._createCertAndKeyIfNeeded("/PACKAGE/")
    End if 
    
    var $bUseHostDatabaseServer : Boolean:=False
    var $hostDatabaseServer : Object:=WEB Server(Web server host database)
    If (($hostDatabaseServer#Null) && $hostDatabaseServer.isRunning)
        If ($options.useTLS)
            $bUseHostDatabaseServer:=($hostDatabaseServer.HTTPSEnabled && ($hostDatabaseServer.HTTPSPort=$options.port))
        Else 
            $bUseHostDatabaseServer:=($hostDatabaseServer.HTTPEnabled && ($hostDatabaseServer.HTTPPort=$options.port))
        End if 
    End if 
    
    If (Not($bUseHostDatabaseServer))
        return cs._Tools.me.startWebServer($options)
    End if 
    
    return False
    
    
    // ----------------------------------------------------
    
    
Function _createCertAndKeyIfNeeded($inCertFolderPath : Text) : Text
    
    var $certFolder : 4D.Folder:=Folder($inCertFolderPath)
    If ($certFolder.file("cert.pem").exists && $certFolder.file("key.pem").exists)
        return $certFolder.platformPath
    End if 
    
    var $certBuffer; $keyBuffer : Blob
    var $params : Object:={CN: "www.4d.com"; O: "4D"; OU: "4D Engineering"; C: "FR"; ST: "Yvelines"; L: "Le Pecq"}
    
    If (_4D GENERATE CERTIFICATE AND PRIVATE KEY($certBuffer; $keyBuffer; $params))
        $certFolder.file("cert.pem").setContent($certBuffer)
        $certFolder.file("key.pem").setContent($keyBuffer)
    End if 
    
    return ($certFolder#Null) ? $certFolder.platformPath : ""
