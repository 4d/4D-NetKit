shared singleton Class constructor()
    
    
Function getResponse($request : 4D.IncomingMessage) : 4D.OutgoingMessage
    
/*
	Handles incoming webhook requests from Microsoft Graph change notifications.
	
	Two types of requests:
	1. Validation: Microsoft sends a POST with ?validationToken=<token> to verify the endpoint.
	   We must respond with the token as plain text, status 200.
	2. Notification: Microsoft sends a POST with a JSON body containing change data.
	   We must respond with status 202 Accepted.
	
	See: https://learn.microsoft.com/en-us/graph/change-notifications-delivery-webhooks
*/
    
    var $outgoingResponse : 4D.OutgoingMessage:=4D.OutgoingMessage.new()
    
    If ($request#Null)
        
        // --- Validation request ---
        // Microsoft Graph sends a validation request when creating a subscription.
        // The validationToken is passed as a query parameter.
        var $validationToken : Text:=""
        If (Value type($request.urlQuery)=Is object)
            $validationToken:=String($request.urlQuery.validationToken)
            // urlQuery does not decode '+' as spaces — we must do it manually
            $validationToken:=Replace string($validationToken; "+"; " ")
        End if 
        
        If (Length($validationToken)>0)
            $outgoingResponse.setStatus(200)
            $outgoingResponse.setBody($validationToken)
            $outgoingResponse.setHeader("Content-Type"; "text/plain")
            return $outgoingResponse
        End if 
        
        // --- Notification request ---
        // The body contains a JSON object with a "value" array of notifications.
        This._processNotificationBody($request.getJSON())
        
        $outgoingResponse.setStatus(202)
        $outgoingResponse.setBody("")
        $outgoingResponse.setHeader("Content-Type"; "text/plain")
        
    Else 
        
        $outgoingResponse.setStatus(400)
        $outgoingResponse.setBody("Bad Request")
        $outgoingResponse.setHeader("Content-Type"; "text/plain")
        
    End if 
    
    $outgoingResponse.setHeader("X-Request-Handler"; String(OB Class(This).name))
    
    return $outgoingResponse
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _processNotificationBody($inBody : Variant)
    
/*
	Processes the notification body and pushes pending items into Storage
	for the monitoring loop to pick up.
	
	Expected body format:
	{
	    "value": [
	        {
	            "subscriptionId": "...",
	            "changeType": "created|updated|deleted",
	            "resource": "users/{id}/messages/{id}",
	            "resourceData": {
	                "@odata.type": "#Microsoft.Graph.Message",
	                "@odata.id": "...",
	                "id": "{resource-id}"
	            }
	        }
	    ]
	}
*/
    
    var $body : Object
    
    Case of 
        : (Value type($inBody)=Is object)
            $body:=$inBody
        : (Value type($inBody)=Is text)
            $body:=Try(JSON Parse($inBody))
        Else 
            return 
    End case 
    
    If (($body=Null) || (Value type($body.value)#Is collection))
        return 
    End if 
    
    If ((Storage.graphNotifications=Null) || (OB Is empty(Storage.graphNotifications)))
        return 
    End if 
    
    var $notification : Object
    
    For each ($notification; $body.value)
        
        var $subscriptionId : Text:=String($notification.subscriptionId)
        var $changeType : Text:=String($notification.changeType)
        var $resourceId : Text:=""
        
        // Extract the resource ID from resourceData or from the resource path
        If ((Value type($notification.resourceData)=Is object) && (Length(String($notification.resourceData.id))>0))
            $resourceId:=String($notification.resourceData.id)
        Else 
            // Extract last path segment from resource, e.g. "users/{id}/messages/{msgId}"
            var $parts : Collection:=Split string(String($notification.resource); "/")
            If ($parts.length>0)
                $resourceId:=$parts.last()
            End if 
        End if 
        
        // Find the matching state key by subscription ID
        var $state : Text:=This._findStateBySubscriptionId($subscriptionId)
        
        If (Length($state)>0)
            // Push the notification to the pending queue
            Use (Storage.graphNotifications[$state])
                Use (Storage.graphNotifications[$state].pending)
                    Storage.graphNotifications[$state].pending.push(New shared object(\
                     "changeType"; $changeType; \
                     "resourceId"; $resourceId))
                End use 
            End use 
        End if 
        
    End for each 
    
    
    // ----------------------------------------------------
    
    
Function _findStateBySubscriptionId($inSubscriptionId : Text) : Text
    
    // Look up the state key in Storage.notifications by subscription ID
    
    If ((Storage.graphNotifications=Null) || (Length($inSubscriptionId)=0))
        return ""
    End if 
    
    var $keys : Collection:=OB Keys(Storage.graphNotifications)
    var $key : Text
    
    For each ($key; $keys)
        If (String(Storage.graphNotifications[$key].subscriptionId)=$inSubscriptionId)
            return $key
        End if 
    End for each 
    
    return ""
