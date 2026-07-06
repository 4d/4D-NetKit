/**
 * @class _NotificationHelper
 * @description Singleton utility class providing shared helpers for push/pull notification
 *   monitors (Microsoft Graph and Google). Centralises callback parsing, pull-interval
 *   parsing, shared-storage lifecycle management, pending-item draining, callback dispatch,
 *   notification URL building, web-server startup, and caller-context dispatch.
 */

singleton Class constructor()
    
    
    // Mark: - [Constructor helpers]
    // ----------------------------------------------------
    
    
Function parseCallbacks($inParameters : Object) : Object
/**
 * @function parseCallbacks
 * @param {Object} $inParameters - User-supplied options object that may contain `onCreate`,
 *   `onDelete`, and `onModify` formula properties
 * @returns {Object} Normalised callbacks object `{onCreate; onDelete; onModify; thisObj}`;
 *   missing callbacks are set to `Null`, `thisObj` is set to `$inParameters` itself
 * @description Extracts the three optional callback formulas from a start() parameters object
 *   into a canonical shape that `dispatchCallbacks` can consume
 */
    
    var $callbacks : Object:={onCreate: Null; onDelete: Null; onModify: Null; thisObj: Null}
    
    If (($inParameters#Null) && (Value type($inParameters)=Is object))
        If (Value type($inParameters.onCreate)#Is undefined)
            $callbacks.onCreate:=$inParameters.onCreate
        End if 
        If (Value type($inParameters.onDelete)#Is undefined)
            $callbacks.onDelete:=$inParameters.onDelete
        End if 
        If (Value type($inParameters.onModify)#Is undefined)
            $callbacks.onModify:=$inParameters.onModify
        End if 
        $callbacks.thisObj:=$inParameters
    End if 
    
    return $callbacks
    
    
    // ----------------------------------------------------
    
    
Function parsePullInterval($inParameters : Object) : Integer
/**
 * @function parsePullInterval
 * @param {Object} $inParameters - User-supplied options object; reads `$inParameters.timer`
 * @returns {Integer} Pull interval in seconds; defaults to 30 if not specified or invalid
 * @description Extracts and validates the polling interval from a start() parameters object
 */
    
    var $interval : Integer:=30
    
    If (($inParameters#Null) && (Value type($inParameters)=Is object))
        If ((Value type($inParameters.timer)=Is real) || (Value type($inParameters.timer)=Is longint))
            If (Num($inParameters.timer)>0)
                $interval:=Num($inParameters.timer)
            End if 
        End if 
    End if 
    
    return $interval
    
    
    // Mark: - [Storage management]
    // ----------------------------------------------------
    
    
Function registerInStorage($inStorageKey : Text; $inState : Text; $inExtraFields : Object)
/**
 * @function registerInStorage
 * @param {Text} $inStorageKey - Top-level key in `Storage` (e.g. `"graphNotifications"`)
 * @param {Text} $inState - Second-level key identifying the specific monitor session (UUID)
 * @param {Object} $inExtraFields - Optional object whose properties are merged into the
 *   session entry; only Text, Boolean, and Collection values are copied
 * @description Creates or updates `Storage[$inStorageKey][$inState]` with `isStarted: True`
 *   and any extra fields; initialises parent and child shared objects as needed
 */
    
    Use (Storage)
        If (Storage[$inStorageKey]=Null)
            Storage[$inStorageKey]:=New shared object()
        End if 
        Use (Storage[$inStorageKey])
            Storage[$inStorageKey][$inState]:=New shared object("isStarted"; True)
            If (($inExtraFields#Null) && (Value type($inExtraFields)=Is object))
                var $key : Text
                For each ($key; $inExtraFields)
                    Case of 
                        : (Value type($inExtraFields[$key])=Is text)
                            Storage[$inStorageKey][$inState][$key]:=String($inExtraFields[$key])
                        : (Value type($inExtraFields[$key])=Is boolean)
                            Storage[$inStorageKey][$inState][$key]:=Bool($inExtraFields[$key])
                        : (Value type($inExtraFields[$key])=Is collection)
                            Storage[$inStorageKey][$inState][$key]:=New shared collection()
                    End case 
                End for each 
            End if 
        End use 
    End use 
    
    
    // ----------------------------------------------------
    
    
Function signalStop($inStorageKey : Text; $inState : Text)
/**
 * @function signalStop
 * @param {Text} $inStorageKey - Top-level key in `Storage`
 * @param {Text} $inState - Session key to signal
 * @description Sets `isStarted` to `False` on the session entry so the monitor loop
 *   exits gracefully on its next tick; no-op if the entry does not exist
 */
    
    If (Length($inState)>0)
        If ((Storage[$inStorageKey]#Null) && OB Is defined(Storage[$inStorageKey]; $inState))
            Use (Storage[$inStorageKey][$inState])
                Storage[$inStorageKey][$inState].isStarted:=False
            End use 
        End if 
    End if 
    
    
    // ----------------------------------------------------
    
    
Function cleanupStorage($inStorageKey : Text; $inState : Text)
/**
 * @function cleanupStorage
 * @param {Text} $inStorageKey - Top-level key in `Storage`
 * @param {Text} $inState - Session key to remove
 * @description Removes `Storage[$inStorageKey][$inState]`; when no Graph or Google
 *   notification sessions remain, resets `cs._Tools.me.notificationMode` to `False`
 */
    
    If (Length($inState)>0)
        Use (Storage)
            If (Storage[$inStorageKey]#Null)
                Use (Storage[$inStorageKey])
                    If (OB Is defined(Storage[$inStorageKey]; $inState))
                        OB REMOVE(Storage[$inStorageKey]; $inState)
                    End if 
                End use 
            End if 
        End use 
        
        // Reset notificationMode when no active webhook sessions remain
        var $graphEmpty : Boolean:=((Storage.graphNotifications=Null) || OB Is empty(Storage.graphNotifications))
        var $googleEmpty : Boolean:=((Storage.googleNotifications=Null) || OB Is empty(Storage.googleNotifications))
        If ($graphEmpty && $googleEmpty)
            cs._Tools.me.notificationMode:=False
        End if 
    End if 
    
    
    // ----------------------------------------------------
    
    
Function isMonitorActive($inStorageKey : Text; $inState : Text) : Boolean
/**
 * @function isMonitorActive
 * @param {Text} $inStorageKey - Top-level key in `Storage`
 * @param {Text} $inState - Session key to check
 * @returns {Boolean} True when the session exists and `isStarted` is True
 * @description Used by monitor loops to decide whether to continue polling
 */
    
    If ((Storage[$inStorageKey]#Null) && OB Is defined(Storage[$inStorageKey]; $inState))
        return Bool(Storage[$inStorageKey][$inState].isStarted)
    End if 
    
    return False
    
    
    // Mark: - [Monitor helpers]
    // ----------------------------------------------------
    
    
Function drainPendingItems($inStorageKey : Text; $inState : Text) : Collection
/**
 * @function drainPendingItems
 * @param {Text} $inStorageKey - Top-level key in `Storage`
 * @param {Text} $inState - Session key whose `pending` collection is drained
 * @returns {Collection} Deep copies of all pending notification items; the `pending`
 *   collection in storage is cleared atomically inside a `Use…End use` block
 * @description Called each tick by the monitor loop to retrieve and clear all items
 *   that were pushed by the webhook handler since the last tick
 */
    
    var $items : Collection:=[]
    
    If ((Storage[$inStorageKey]#Null) && OB Is defined(Storage[$inStorageKey]; $inState))
        Use (Storage[$inStorageKey][$inState])
            var $pending : Collection:=Storage[$inStorageKey][$inState].pending
            If ($pending#Null)
                var $i : Integer
                For ($i; 0; $pending.length-1)
                    $items.push(OB Copy($pending[$i]))
                End for 
                $pending.clear()
            End if 
        End use 
    End if 
    
    return $items
    
    
    // Mark: - [Callback dispatch]
    // ----------------------------------------------------
    
    
Function dispatchCallbacks($inItems : Collection; $inType : Text; $inCallbacks : Object; $inOwner : Object)
/**
 * @function dispatchCallbacks
 * @param {Collection} $inItems - Notification items (each with `changeType` and `resourceId`)
 * @param {Text} $inType - Resource type prefix appended to the event name (e.g. `"message"`
 *   → `"messageCreated"`, `"messageModified"`, `"messageDeleted"`)
 * @param {Object} $inCallbacks - Callbacks object as returned by `parseCallbacks`
 * @param {Object} $inOwner - The API object (e.g. `Office365` instance) passed as first
 *   argument to each callback formula
 * @description Groups items by `changeType` then invokes the matching callback formula
 *   (`onCreate`, `onModify`, `onDelete`) with the owner and a `{type; ids}` event object;
 *   callbacks with no matching items or set to `Null` are skipped
 */
    
    var $created : Collection:=[]
    var $updated : Collection:=[]
    var $deleted : Collection:=[]
    
    var $item : Object
    For each ($item; $inItems)
        Case of 
            : ($item.changeType="created")
                $created.push($item.resourceId)
            : ($item.changeType="updated")
                $updated.push($item.resourceId)
            : ($item.changeType="deleted")
                $deleted.push($item.resourceId)
        End case 
    End for each 
    
    If (($created.length>0) && ($inCallbacks.onCreate#Null))
        $inCallbacks.onCreate.call($inCallbacks.thisObj; $inOwner; {type: $inType+"Created"; ids: $created})
    End if 
    
    If (($updated.length>0) && ($inCallbacks.onModify#Null))
        $inCallbacks.onModify.call($inCallbacks.thisObj; $inOwner; {type: $inType+"Modified"; ids: $updated})
    End if 
    
    If (($deleted.length>0) && ($inCallbacks.onDelete#Null))
        $inCallbacks.onDelete.call($inCallbacks.thisObj; $inOwner; {type: $inType+"Deleted"; ids: $deleted})
    End if 
    
    
    // Mark: - [URL helpers]
    // ----------------------------------------------------
    
    
Function buildNotificationUrl($inEndPoint : Text; $inPath : Text; $inState : Text) : Text
/**
 * @function buildNotificationUrl
 * @param {Text} $inEndPoint - Base endpoint URL (e.g. `"https://myserver.com"`)
 * @param {Text} $inPath - URL path to set (e.g. `"/webhook/graph"`)
 * @param {Text} $inState - Optional state token appended as `?state=<value>`
 * @returns {Text} The fully assembled notification URL, or empty string if `$inEndPoint` is empty
 * @description Builds the callback URL that is registered with Microsoft Graph or Google
 *   as the notification endpoint; strips existing query params and fragment from the base URL
 */
    
    If (Length($inEndPoint)=0)
        return ""
    End if 
    
    var $url : cs._URL:=cs._URL.new($inEndPoint)
    $url.path:=$inPath
    $url.queryParams:=[]
    $url.ref:=""
    
    If (Length($inState)>0)
        $url.addQueryParameter("state"; $inState)
    End if 
    
    return $url.toString()
    
    
    // ----------------------------------------------------
    
    
Function ensureWebServer($inEndPoint : Text) : Object
/**
 * @function ensureWebServer
 * @param {Text} $inEndPoint - Notification endpoint URL used to determine port and TLS mode
 * @returns {Object} `{success: Boolean; port: Integer}` — success is False if the component
 *   web server failed to start
 * @description Ensures a web server is listening on the endpoint's port before registering
 *   a webhook subscription. If the host database web server is already running on that port
 *   (HTTP or HTTPS), it is reused. Otherwise the component web server is started and
 *   `cs._Tools.me.notificationMode` is set to True.
 */
    
    var $port : Integer:=cs._Tools.me.getPortFromURL($inEndPoint)
    var $useTLS : Boolean:=(Position("https"; $inEndPoint)=1)
    
    var $bUseHostDatabaseServer : Boolean:=False
    var $hostDatabaseServer : Object:=WEB Server(Web server host database)
    If (($hostDatabaseServer#Null) && $hostDatabaseServer.isRunning)
        If ($useTLS)
            $bUseHostDatabaseServer:=($hostDatabaseServer.HTTPSEnabled && ($hostDatabaseServer.HTTPSPort=$port))
        Else 
            $bUseHostDatabaseServer:=($hostDatabaseServer.HTTPEnabled && ($hostDatabaseServer.HTTPPort=$port))
        End if 
    End if 
    
    If ($bUseHostDatabaseServer)
        // When reusing the host HTTPS server, verify TLS 1.2 support is enabled.
        // Microsoft Graph webhook callbacks require TLS 1.2 and fail if only TLS 1.3 is accepted.
        If ($useTLS && ($hostDatabaseServer.minTLSVersion>TLSv1_2))
            return {success: False; port: $port; tlsVersionInsufficient: True}
        End if 
        return {success: True; port: $port}
    End if 
    
    var $result : Object:=cs._Tools.me.startWebServer({port: $port; useTLS: $useTLS; enableDebugLog: True})
    $result.port:=$port
    If ($result.success)
        cs._Tools.me.notificationMode:=True
    End if 
    return $result
    
    
    // Mark: - [Caller context dispatch]
    // ----------------------------------------------------
    
    
Function callbackInCallerContext($inFormWindow : Integer; $inWorkerName : Text; $inFormula : 4D.Function; $inSelf : Object; $inItems : Collection)
/**
 * @function callbackInCallerContext
 * @param {Integer} $inFormWindow - Form window reference captured at monitor start (0 if none)
 * @param {Text} $inWorkerName - Worker/process name captured at monitor start
 * @param {4D.Function} $inFormula - Formula to execute in the caller's context
 * @param {Object} $inSelf - Object passed as `This` to the formula
 * @param {Collection} $inItems - Notification items passed as argument to the formula
 * @description Dispatches a callback formula in the original caller's execution context:
 *   uses `CALL FORM` when a form window was captured (preserves `Form`, `This`, etc.),
 *   otherwise falls back to `CALL WORKER` with the captured process name
 */
    
    If ($inFormWindow>0)
        CALL FORM($inFormWindow; $inFormula; $inSelf; $inItems)
    Else 
        CALL WORKER($inWorkerName; $inFormula; $inSelf; $inItems)
    End if 
    