/**
 * @class OAuth2Authorization
 * @description Shared singleton HTTP handler for the OAuth2 authorization redirect callback.
 *   Registered as a 4D HTTP handler; receives the redirect from the authorization server
 *   (code or error), resolves the pending `_getAuthorizationCode()` call in Storage,
 *   and returns an HTML response or 302 redirect to the browser.
 */

shared singleton Class constructor()
    
Function getResponse($request : 4D.IncomingMessage) : 4D.OutgoingMessage
/**
 * @function getResponse
 * @param {4D.IncomingMessage} $request - Incoming HTTP request from the browser
 *   (redirect from the authorization server with query params or form POST body)
 * @returns {4D.OutgoingMessage} HTML page or 302 redirect on success;
 *   403 when `_authorize` returns `False`; 500 when `$request` is `Null`
 * @description Extracts `state` from the URL, calls `_authorize()` to store the
 *   authorization code in `Storage.requests`, and sends the configured
 *   `authenticationPage` or a default HTML response to the browser.
 */
    
    var $outgoingResponse : 4D.OutgoingMessage:=4D.OutgoingMessage.new()
    var $errorBody : Text
    If ($request#Null)
        
        var $state : Text:=cs._Tools.me.getURLParameterValue($request.url; "state")
        var $requestPath : Text:=cs._Tools.me.getPathFromURL($request.url)+"@"
        var $options : Object:={state: $state; redirectURI: $requestPath}
        var $response : Object:={}
        var $oauthResult : Object:=Null
        
        If (Value type($request.urlQuery)=Is object)
            var $queryKeys : Collection:=OB Keys($request.urlQuery)
            If ($queryKeys.length>0)
                $oauthResult:=New shared object
                var $queryKey : Text
                Use ($oauthResult)
                    For each ($queryKey; $queryKeys)
                        $oauthResult[$queryKey]:=$request.urlQuery[$queryKey]
                    End for each 
                End use 
            End if 
        End if 
        If ($oauthResult=Null)
            // form_post returns OAuth2 params in the request body, not in URL query
            var $contentType : Text:=Lowercase(String($request.getHeader("Content-Type")))
            If (Position("application/x-www-form-urlencoded"; $contentType)=1)
                var $requestBody : Text:=$request.getText()
                If (Length($requestBody)>0)
                    $oauthResult:=cs._Tools.me.parseFormURLEncoded($requestBody)
                End if 
            End if 
        End if 
        
        If (Value type($oauthResult)=Is object)
            $options.result:=$oauthResult
        End if 
        
        If ((Value type($oauthResult)=Is object) && OB Is defined($oauthResult; "state") && (Length(String($oauthResult.state))>0))
            $state:=String($oauthResult.state)
            $options.state:=$state
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
