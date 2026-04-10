shared singleton Class constructor()
	
	
Function getResponse($request : 4D.IncomingMessage) : 4D.OutgoingMessage
	
/*
	Handles incoming webhook requests from Google push notifications.
	
	Two types of notifications:
	1. Calendar push: Google sends POST with specific headers:
	   - X-Goog-Channel-Token: state identifier
	   - X-Goog-Resource-State: "sync" (validation) or "exists" (change)
	   We respond with 200.
	   
	2. Gmail Pub/Sub push: Google Pub/Sub sends POST with JSON body:
	   {
	       "message": {
	           "data": base64({emailAddress, historyId}),
	           "messageId": "..."
	       },
	       "subscription": "..."
	   }
	   We respond with 200.
	
	See: https://developers.google.com/calendar/api/guides/push
	See: https://developers.google.com/gmail/api/guides/push
*/
	
	var $outgoingResponse : 4D.OutgoingMessage:=4D.OutgoingMessage.new()
	
	If ($request#Null)
		
		// Check if this is a Calendar channel notification (has X-Goog-Channel-Token header)
		var $channelToken : Text:=""
		If (Value type($request.headers)=Is object)
			$channelToken:=String($request.headers["x-goog-channel-token"])
		End if 
		
		If (Length($channelToken)>0)
			// --- Calendar push notification ---
			var $resourceState : Text:=""
			If (Value type($request.headers)=Is object)
				$resourceState:=String($request.headers["x-goog-resource-state"])
			End if 
			
			If ($resourceState="sync")
				// Initial sync validation - respond 200
				$outgoingResponse.setStatus(200)
				$outgoingResponse.setBody("")
			Else 
				// Change notification - push to pending
				This._processCalendarNotification($channelToken)
				$outgoingResponse.setStatus(200)
				$outgoingResponse.setBody("")
			End if 
			
		Else 
			// --- Gmail Pub/Sub push notification ---
			This._processGmailNotification($request.getJSON())
			$outgoingResponse.setStatus(200)
			$outgoingResponse.setBody("")
		End if 
		
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
	
	
Function _processCalendarNotification($inState : Text)
	
/*
	Processes a Calendar push notification.
	The state token (from X-Goog-Channel-Token) maps to a notification state in Storage.
	Pushes a signal to the pending queue for the monitoring loop to pick up.
*/
	
	If ((Storage.googleNotifications=Null) || (OB Is empty(Storage.googleNotifications)))
		return 
	End if 
	
	If (Length($inState)>0)
		If (OB Is defined(Storage.googleNotifications; $inState))
			Use (Storage.googleNotifications[$inState])
				If (Storage.googleNotifications[$inState].pending#Null)
					Use (Storage.googleNotifications[$inState].pending)
						Storage.googleNotifications[$inState].pending.push(New shared object("signal"; True))
					End use 
				End if 
			End use 
		End if 
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _processGmailNotification($inBody : Variant)
	
/*
	Processes a Gmail Pub/Sub push notification.
	
	Expected body format (from Pub/Sub push subscription):
	{
	    "message": {
	        "data": "base64({emailAddress: 'user@example.com', historyId: '12345'})",
	        "messageId": "..."
	    },
	    "subscription": "..."
	}
	
	Finds the matching notification state by userId/emailAddress and pushes a signal.
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
	
	If ($body=Null)
		return 
	End if 
	
	If ((Storage.googleNotifications=Null) || (OB Is empty(Storage.googleNotifications)))
		return 
	End if 
	
	// Extract emailAddress from the Pub/Sub message data
	var $emailAddress : Text:=""
	
	If ((Value type($body.message)=Is object) && (Length(String($body.message.data))>0))
		var $decodedData : Text:=String($body.message.data)
		BASE64 DECODE($decodedData)
		var $dataObj : Object:=Try(JSON Parse($decodedData))
		If (($dataObj#Null) && (Length(String($dataObj.emailAddress))>0))
			$emailAddress:=String($dataObj.emailAddress)
		End if 
	End if 
	
	If (Length($emailAddress)=0)
		return 
	End if 
	
	// Find the matching state by userId/emailAddress
	var $state : Text:=This._findStateByUserId($emailAddress)
	
	If (Length($state)>0)
		Use (Storage.googleNotifications[$state])
			If (Storage.googleNotifications[$state].pending#Null)
				Use (Storage.googleNotifications[$state].pending)
					Storage.googleNotifications[$state].pending.push(New shared object("signal"; True))
				End use 
			End if 
		End use 
	End if 
	
	
	// ----------------------------------------------------
	
	
Function _findStateByUserId($inUserId : Text) : Text
	
	// Look up the state key in Storage.googleNotifications by userId/emailAddress
	
	If ((Storage.googleNotifications=Null) || (Length($inUserId)=0))
		return ""
	End if 
	
	var $keys : Collection:=OB Keys(Storage.googleNotifications)
	var $key : Text
	
	For each ($key; $keys)
		If (String(Storage.googleNotifications[$key].userId)=$inUserId)
			return $key
		End if 
	End for each 
	
	return ""
