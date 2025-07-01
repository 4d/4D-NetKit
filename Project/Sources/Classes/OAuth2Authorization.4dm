shared singleton Class constructor()
    
Function getResponse($request : 4D.IncomingMessage) : 4D.OutgoingMessage
    
    var $response : 4D.OutgoingMessage:=4D.OutgoingMessage.new()
    If ($request#Null)
        
        var $responseBody : Blob
        var $state : Text:=cs.Tools.me.getURLParameterValue($request.url; "state")
        var $redirectURI : Text:=($request.urlPath.length>0) ? "/"+$request.urlPath[0]+"/@" : $request.url
        var $options : Object:={state: $state; redirectURI: $redirectURI}
        
        If (Value type($request.urlQuery)=Is object)
            $options.result:=OB Copy($request.urlQuery; ck shared)
        End if 
        
        If (_authorize($options; ->$responseBody))
            
            $response.setStatus(200)
            $response.setBody($responseBody)
            $response.setHeader("Content-Type"; "text/html")
        Else 
            
            // Send a 403 status line
            // This is not strictly necessary, but it makes it clear that the request was forbidden
            // and not just a 404 Not Found
            $response.setStatus(403)
            var $errorBody : Text:="<html><body><h1>403 Forbidden</h1><p>Access denied</p></body></html>"
            $response.setBody($errorBody)
            $response.setHeader("Content-Type"; "text/html")
            
        End if 
    Else 
        var $error : Object:=cs.Tools.me.makeError(9; {which: "request (4D.IncomingMessage)"; function: "OAuth2Authorization.getResponse"})
        
        $response.setStatus(500)
        $response.setBody("Internal Server Error:\r\n\r\n"+JSON Stringify($error; *))
        $response.setHeader("Content-Type"; "text/plain")
    End if 
    $response.setHeader("X-Request-Handler"; String(OB Class(This).name))
    
    return $response
