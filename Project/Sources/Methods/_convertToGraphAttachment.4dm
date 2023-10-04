//%attributes = {"invisible":true}
#DECLARE($inObject : cs.GraphAttachment)->$result : Object

// converts cs.GraphAttachment into microsoft.graph.fileAttachment
If (OB Instance of($inObject; cs.GraphAttachment))
	
	$result:=New object
	$result["@odata.type"]:=(Length(String($inObject["@odata.type"]))>0) ? \
		$inObject["@odata.type"] : "#microsoft.graph.fileAttachment"
	If (Length(String($inObject.cid))>0)
		$result.contentId:=String($inObject.cid)
	End if 
	If (String($inObject.disposition)="inline")
		$result.isInline:=True
	End if 
	If (Length(String($inObject.name))>0)
		$result.name:=String($inObject.name)
	End if 
	If (Length(String($inObject.type))>0)
		$result.contentType:=String($inObject.type)
	End if 
	If (Not(OB Is defined($inObject; "contentBytes")))
		var $blob : Blob
		$blob:=$inObject.getContent()
	End if 
	$result.contentBytes:=$inObject.contentBytes
	$result.size:=$inObject.size
	
End if 

return $result
