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
            
            $response.setStatus(404)
        End if 
    Else 
        throw({code: 9; component: "4DNK"; deferred: True; which: "request (4D.IncomingMessage)"; function: "OAuth2Authorization.getResponse"})
        
        $response.setStatus(500)
    End if 
    $response.setHeader("X-Request-Handler"; String(OB Class(This).name))
    
    return $response
