shared singleton Class constructor()
    
Function getResponse($request : 4D.IncomingMessage) : 4D.OutgoingMessage
    
    var $outgoingResponse : 4D.OutgoingMessage:=4D.OutgoingMessage.new()
    var $errorBody : Text
    If ($request#Null)
        
        var $state : Text:=cs._Tools.me.getURLParameterValue($request.url; "state")
        var $redirectURI : Text:=($request.urlPath.length>0) ? "/"+$request.urlPath[0]+"/@" : $request.url
        var $options : Object:={state: $state; redirectURI: $redirectURI}
        var $response : Object:={}
        
        If (Value type($request.urlQuery)=Is object)
            $options.result:=OB Copy($request.urlQuery; ck shared)
        End if 
        
        If (_authorize($options; $response))
            
            // If the response contains a redirect URL, we send a 302 Temporary Redirect
            If ((Value type($response.redirectURL)=Is text) && (Length($response.redirectURL)>0))
                $outgoingResponse.setStatus($response.status)
                $outgoingResponse.setHeader("Location"; String($response.redirectURL))
            Else 
                $outgoingResponse.setStatus($response.status)
                $outgoingResponse.setBody($response.body)
                $outgoingResponse.setHeader("Content-Type"; $response.contentType)
            End if 
        Else 
            
            // Send a 403 status line
            // This is not strictly necessary, but it makes it clear that the request was forbidden
            // and not just a 404 Not Found
            $errorBody:=cs._Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "403 Forbidden"; "Access denied."; False)
            $outgoingResponse.setStatus(403)
            $outgoingResponse.setBody($errorBody)
            $outgoingResponse.setHeader("Content-Type"; "text/html")
            
        End if 
    Else 
        var $error : Object:=cs._Tools.me.makeError(9; {which: "request (4D.IncomingMessage)"; function: "OAuth2Authorization.getResponse"})
        
        $errorBody:=cs._Tools.me.buildPageFromTemplate(Localized string("OAuth2_Response_Title"); "500 Internal Server Error"; JSON Stringify($error; *); False)
        $outgoingResponse.setStatus(500)
        $outgoingResponse.setBody($errorBody)
        $outgoingResponse.setHeader("Content-Type"; "text/plain")
    End if 
    $outgoingResponse.setHeader("X-Request-Handler"; String(OB Class(This).name))
    
    return $outgoingResponse
