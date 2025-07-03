//%attributes = {"invisible":true}
#DECLARE($inOptions : Object; $outResponse : Object) : Boolean

var $redirectURI : Text
var $URL : Text:=$inOptions.redirectURI
var $authenticationPage; $authenticationErrorPage : Variant
var $state : Text:=String($inOptions.state)

If (OB Is defined(Storage.requests; $state))
    $redirectURI:=String(Storage.requests[$state].redirectURI)
    If (Length($redirectURI)>0)
        $redirectURI:=cs.Tools.me.getPathFromURL($redirectURI)+"@"
    End if 
    $authenticationPage:=(Value type(Storage.requests[$state].authenticationPage)#Is undefined) ? Storage.requests[$state].authenticationPage : Null
    $authenticationErrorPage:=(Value type(Storage.requests[$state].authenticationErrorPage)#Is undefined) ? Storage.requests[$state].authenticationErrorPage : Null
End if 

If ($URL=$redirectURI)
    
    var $responseFile : 4D.File:=Null
    var $responseRedirectURI : Text:=""
    var $customPageObject : Object:=Null
    var $pageTitle; $pageMessage; $pageDetails : Text
    
    If (OB Is defined(Storage.requests; $state))
        Use (Storage.requests[$state])
            Storage.requests[$state].token:=$inOptions.result
        End use 
    End if 
    
    If (($inOptions.result=Null) | (OB Is defined($inOptions.result; "error")))
        
        $pageTitle:=Localized string("OAuth2_Response_Title")
        $pageMessage:=Localized string("OAuth2_Error_Message")
        
        If (OB Is defined($inOptions.result; "error"))
            $pageMessage+=("<br /><br />"+String($inOptions.result.error))
        End if 
        If (OB Is defined($inOptions.result; "error_subtype"))
            $pageMessage+=("<br /><br />"+String($inOptions.result.error_subtype))
        End if 
        If (OB Is defined($inOptions.result; "error_description"))
            $pageMessage+=("<br /><br />"+String($inOptions.result.error_description))
        End if 
        If (OB Is defined($inOptions.result; "error_uri"))
            $pageMessage+=("<br /><br />"+String($inOptions.result.error_uri))
        End if 
        $pageDetails:=Localized string("OAuth2_Response_Details")
        
        If (Value type($authenticationErrorPage)=Is text)
            $responseRedirectURI:=String($authenticationErrorPage)
        Else 
            $customPageObject:=($authenticationErrorPage#Null) ? $authenticationErrorPage : Folder(fk resources folder).file("responseTemplate.html")
            If (OB Instance of($customPageObject; 4D.File))
                $responseFile:=$customPageObject
            End if 
        End if 
    Else 
        
        $pageTitle:=Localized string("OAuth2_Response_Title")
        $pageMessage:=Localized string("OAuth2_Response_Message")
        $pageDetails:=Localized string("OAuth2_Response_Details")
        
        If (Value type($authenticationPage)=Is text)
            $responseRedirectURI:=String($authenticationPage)
        Else 
            $customPageObject:=($authenticationPage#Null) ? $authenticationPage : Folder(fk resources folder).file("responseTemplate.html")
            If (OB Instance of($customPageObject; 4D.File))
                $responseFile:=$customPageObject
            End if 
        End if 
    End if 
    
    // If $responseFile is a 4D.File, we process it as a template
    Case of 
        : ((Value type($responseRedirectURI)=Is text) && Length($responseRedirectURI)>0)
            // If we have a redirect URI, we just send a redirect to that URI
            $outResponse.status:=302  // Temporary redirect
            $outResponse.redirectURL:=String($responseRedirectURI)
            
        : (OB Instance of($responseFile; 4D.File))
            If ($responseFile=Null)
                $responseFile:=Folder(fk resources folder).file("responseTemplate.html")
            End if 
            
            var $responseFileContent : Text:=$responseFile.getText()
            var $outResponseBody : Text:=""
            var $closeButtonText : Text:=Localized string("OAuth2_Response_Close")
            
            PROCESS 4D TAGS($responseFileContent; $outResponseBody; $pageTitle; $pageMessage; $pageDetails; $closeButtonText)
            
            $outResponse.status:=200
            $outResponse.body:=$outResponseBody
            $outResponse.contentType:="text/html; charset=UTF-8"
        Else 
            
            // If we don't have a redirect URI or a response file, we just send a 500 Internal Server Error response
            $outResponse.status:=500
            $outResponse.body:=cs.Tools.me.buildPageFromTemplate($pageTitle; "500 Internal Server Error"; $pageMessage)
            $outResponse.contentType:="text/html; charset=UTF-8"
    End case 
    
    return True
    
End if 

return False
