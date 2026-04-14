singleton Class constructor()
    
    
    // Mark: - [Constructor helpers]
    // ----------------------------------------------------
    
    
Function parseCallbacks($inParameters : Object) : Object
    
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
    
    If (Length($inState)>0)
        If ((Storage[$inStorageKey]#Null) && OB Is defined(Storage[$inStorageKey]; $inState))
            Use (Storage[$inStorageKey][$inState])
                Storage[$inStorageKey][$inState].isStarted:=False
            End use 
        End if 
    End if 
    
    
    // ----------------------------------------------------
    
    
Function cleanupStorage($inStorageKey : Text; $inState : Text)
    
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
    End if 
    
    
    // ----------------------------------------------------
    
    
Function isMonitorActive($inStorageKey : Text; $inState : Text) : Boolean
    
    If ((Storage[$inStorageKey]#Null) && OB Is defined(Storage[$inStorageKey]; $inState))
        return Bool(Storage[$inStorageKey][$inState].isStarted)
    End if 
    
    return False
    
    
    // Mark: - [Monitor helpers]
    // ----------------------------------------------------
    
    
Function drainPendingItems($inStorageKey : Text; $inState : Text) : Collection
    
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
    
    
    // Mark: - [Caller context dispatch]
    // ----------------------------------------------------
    
    
Function callbackInCallerContext($inFormWindow : Integer; $inWorkerName : Text; $inFormula : 4D.Function; $inSelf : Object; $inItems : Collection)
    
/*
	Dispatches callback execution in the original caller's context:
	- If a form window was captured at start(), uses CALL FORM to execute
	  in the form process (preserving Form, This, etc.)
	- Otherwise, falls back to CALL WORKER using the original process name.
*/
    If ($inFormWindow>0)
        CALL FORM($inFormWindow; $inFormula; $inSelf; $inItems)
    Else 
        CALL WORKER($inWorkerName; $inFormula; $inSelf; $inItems)
    End if 

    