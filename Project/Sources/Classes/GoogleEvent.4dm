Class extends _BaseClass

property kind : Text
property etag : Text
property id : Text
property summary : Text
property description : Text
property eventType : Text

Class constructor($inObject : Object)
    
    Super()
    This._internals._attachments:=[]
    var $key : Text
    var $keys : Collection:=OB Keys($inObject)
    For each ($key; $keys)
        If ($key="attachments")
            This._internals._attachments:=$inObject.attachments
        Else 
            This[$key]:=$inObject[$key]
        End if 
    End for each 
    
    This._internals._update:=(This._internals._attachments.length>0) ? True : False
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function get attachments() : Collection
    
    If (This._internals._update)
        
        var $attachments : Collection:=[]
        var $iter : Object
        For each ($iter; This._internals._attachments)
            $attachments.push(cs.GoogleEventAttachment.new($iter))
        End for each 
        
        This._internals._update:=False
        This._internals._attachments:=$attachments
    End if 
    
    return This._internals._attachments
