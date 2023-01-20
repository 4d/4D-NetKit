//%attributes = {"invisible":true}
#DECLARE($inMessage : Object; $outLargeAttachements : Collection) : Object

var $message : Object
var $keys : Collection
var $key : Text

$message:=New object:C1471
If (OB Is defined:C1231($inMessage; "attachments") && ($inMessage.attachments#Null:C1517))
	$message.attachments:=New collection:C1472
End if 
$keys:=OB Keys:C1719($inMessage)
For each ($key; $keys)
	
	Case of 
		: (($key="_internals") || (Position:C15("@"; $key)=1) || ($key="webLink"))
			// do not copy
			
		: ($key="attachments")
			var $iter; $attachment : Object
			For each ($iter; $inMessage.attachments)
				$attachment:=_convertToGraphAttachment($iter)
				If ($attachment.size<=3145728)  // Constant 'nk Upload Session min size' throw an error at compilation!
					$message.attachments.push($attachment)
				Else 
					If ($attachment.size<=157286400)  // Constant 'nk Upload Session max size' throw an error at compilation!
						If ($outLargeAttachements#Null:C1517)
							$outLargeAttachements.push($attachment)
						End if 
					End if 
					
				End if 
			End for each 
			
		Else 
			$message[$key]:=$inMessage[$key]
			
	End case 
	
End for each 

return $message
