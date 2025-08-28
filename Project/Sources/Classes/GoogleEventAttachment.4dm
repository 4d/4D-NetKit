property fileUrl : Text
property title : Text
property mimeType : Text
property iconLink : Text
property contentBytes : 4D.Blob:=Null

Class constructor($inAttachment : Object)
    
    This.fileUrl:=String($inAttachment.fileUrl)
    This.title:=String($inAttachment.title)
    This.mimeType:=String($inAttachment.mimeType)
    This.iconLink:=String($inAttachment.iconLink)
    
    
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
