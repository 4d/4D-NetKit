/**
 * @class GoogleEvent
 * @extends _BaseClass
 * @description Represents a Google Calendar event. All top-level properties from the
 *   Calendar API event resource are mapped directly onto `This`; the `attachments`
 *   array is converted to a collection of `GoogleEventAttachment` instances.
 */

Class extends _BaseClass

property id : Text
property attachments : Collection

Class constructor($inObject : Object)
/**
 * @constructor
 * @param {Object} $inObject - Raw event object from the Calendar API response;
 *   all top-level properties except `attachments` are copied as-is onto `This`;
 *   `attachments` items are wrapped into `GoogleEventAttachment` instances
 */
    
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
            This.attachments.push($attachment)
        End for each 
    End if 
