//%attributes = {"invisible":true}
#DECLARE($inObject : cs:C1710.GraphAttachment)->$result : Object

// converts cs.GraphAttachment into microsoft.graph.fileAttachment
If (OB Instance of:C1731($inObject; cs:C1710.GraphAttachment))
	
	$result:=New object:C1471
	$result["@odata.type"]:=(Length:C16(String:C10($inObject["@odata.type"]))>0) ? \
		$inObject["@odata.type"] : "#microsoft.graph.fileAttachment"
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
	If (Not:C34(OB Is defined:C1231($inObject; "contentBytes")))
		var $blob : Blob
		$blob:=$inObject.getContent()
	End if 
	$result.contentBytes:=$inObject.contentBytes
	$result.size:=$inObject.size
	
End if 

return $result
