property fileUrl : Text
property title : Text
property mimeType : Text
property iconLink : Text
property contentBytes : 4D.Blob:=Null

Class constructor($inAttachement : Object)
    
    This.fileUrl:=String($inAttachement.fileUrl)
    This.title:=String($inAttachement.title)
    This.mimeType:=String($inAttachement.mimeType)
    This.iconLink:=String($inAttachement.iconLink)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function getContent() : 4D.Blob
    
    If (This.contentBytes=Null)
        var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new(This.fileUrl; {dataType: "blob"}).wait())
        If ($request#Null)
            This.contentBytes:=4D.Blob.new($request.response.body)
        End if 
    End if 
    
    return This.contentBytes
    
    
    // ----------------------------------------------------
    
    
Function getIcon() : Picture
    
    var $icon : Picture:=Null
    var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new(This.iconLink; {dataType: "blob"}).wait())
    If ($request#Null)
        var $blob : 4D.Blob:=Null
        $blob:=4D.Blob.new($request.response.body)
        BLOB TO PICTURE($blob; $icon)
    End if 
    
    return $icon
