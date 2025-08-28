Class extends _BaseClass

property id : Text
property attachments : Collection

Class constructor($inObject : Object)
    
    Super()
    
    var $key : Text
    var $keys : Collection:=OB Keys($inObject)
    var $attachments : Collection:=Null
    For each ($key; $keys)
        If ($key="attachments")
            $attachments:=$inObject.attachments
        Else 
            This[$key]:=$inObject[$key]
        End if 
    End for each 
    
    If (($attachments#Null) && ($attachments.length>0))
        This.attachments:=[]
        var $iter : Object
        For each ($iter; $attachments)
            var $attachment : cs.GoogleEventAttachment:=cs.GoogleEventAttachment.new($iter)
            This.attachments.push(cs.GoogleEventAttachment.new($attachment))
        End for each 
    End if 
