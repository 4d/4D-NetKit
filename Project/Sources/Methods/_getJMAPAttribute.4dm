//%attributes = {"invisible":true}
#DECLARE($inKey : Text) : Text

Case of 
	: ($inKey="id")
		return "id"
	: ($inKey="threadId")
		return "threadId"
	: ($inKey="sizeEstimate")
		return "size"
	: ($inKey="snippet")
		return "preview"
	: ($inKey="Date")
		return "receivedAt"
	: ($inKey="Subject")
		return "subject"
	: ($inKey="labelIds")
		return "mailboxIds"
	: ($inKey="Message-Id")
		return "messageId"
	: ($inKey="Message-Id")
		return "messageId"
	: ($inKey="From")
		return "from"
	: ($inKey="Sender")
		return "sender"
	: ($inKey="To")
		return "to"
	: ($inKey="Cc")
		return "cc"
	: ($inKey="Reply-To")
		return "replyTo"
	: ($inKey="In-Reply-To")
		return "inReplyTo"
	: ($inKey="Keywords")
		return "keywords"
		
/*
blobId
hasAttachment
*/
End case 

return ""
