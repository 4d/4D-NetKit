shared singleton Class constructor()
    
Function getResponse($request : 4D.IncomingMessage) : 4D.OutgoingMessage
    
    var $response:=4D.OutgoingMessage.new()
    var $body : Text
    var $state : Text:=cs.Tools.me.getURLParameterValue($request.url; "state")
    var $options : Object:={state: $state}
    $options.redirectURI:=$request.urlPath
    $options.result:=$request.getJSON()

    If (_authorize($options; $body))
        
        $response.setStatus(200)
        $response.setHeader("Content-Type"; "text/html")
        $response.setBody($body)
    Else 
        
        $response.setStatus(404)
    End if 
    
    return $response
