//%attributes = {"invisible":true}
#DECLARE($inObject : 4D:C1709.MailAttachment)->$result : Object

// converts 4D.MailAttachment into microsoft.graph.fileAttachment
If (OB Instance of:C1731($inObject; 4D:C1709.MailAttachment))
	
	$result:=New object:C1471
	$result["@odata.type"]:="#microsoft.graph.fileAttachment"
	If (Length:C16(String:C10($inObject.cid))>0)
		$result.contentId:=String:C10($inObject.cid)
	End if 
	If (String:C10($inObject.disposition)="inline")
		$result.isInline:=True:C214
	End if 
	If (Length:C16(String:C10($inObject.name))>0)
		$result.name:=String:C10($inObject.name)
	End if 
	If (Length:C16(String:C10($inObject.type))>0)
		$result.contentType:=String:C10($inObject.type)
	End if 
	If ($inObject.getContent().size()>0)
		var $encodedContent : Text
		BASE64 ENCODE:C895($inObject.getContent(); $encodedContent)
		$result.contentBytes:=$encodedContent
		$result.size:=Length:C16($encodedContent)
	End if 
	
End if 

return $result
