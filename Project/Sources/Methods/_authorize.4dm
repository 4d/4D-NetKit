//%attributes = {"invisible":true}
#DECLARE($inOptions : Object; $outResponse : Object) : Boolean

var $redirectURI : Text
var $URL : Text:=$inOptions.redirectURI
var $customResponseFile; $customErrorFile : 4D.File
var $state : Text:=String($inOptions.state)
var $responseFile : 4D.File:=Folder(fk resources folder).file("responseTemplate.html")

If (OB Is defined(Storage.requests; $state))
    $redirectURI:=String(Storage.requests[$state].redirectURI)
    If (Length($redirectURI)>0)
        $redirectURI:=cs.Tools.me.getPathFromURL($redirectURI)+"@"
    End if 
    $customResponseFile:=(Value type(Storage.requests[$state].authenticationPage)#Is undefined) ? Storage.requests[$state].authenticationPage : Null
    $customErrorFile:=(Value type(Storage.requests[$state].authenticationErrorPage)#Is undefined) ? Storage.requests[$state].authenticationErrorPage : Null
End if 

If ($URL=$redirectURI)
    
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
        
        $responseFile:=($customErrorFile#Null) ? $customErrorFile : $responseFile
    Else 
        
        $pageTitle:=Localized string("OAuth2_Response_Title")
        $pageMessage:=Localized string("OAuth2_Response_Message")
        $pageDetails:=Localized string("OAuth2_Response_Details")
        
        $responseFile:=($customResponseFile#Null) ? $customResponseFile : $responseFile
    End if 
    
    var $responseFileContent : Text:=$responseFile.getText()
    var $outResponseBody : Text:=""
    
    PROCESS 4D TAGS($responseFileContent; $outResponseBody; $pageTitle; $pageMessage; $pageDetails)
    
    $outResponse.status:=200
    $outResponse.body:=$outResponseBody
    $outResponse.contentType:="text/html; charset=UTF-8"
    
    return True
    
End if 

return False
