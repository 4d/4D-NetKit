//%attributes = {"invisible":true}
#DECLARE($inKey : Text) : Boolean

If (($inKey="From") || \
($inKey="Sender") || \
($inKey="Reply-To") || \
($inKey="To") || \
($inKey="Cc") || \
($inKey="BCc") || \
($inKey="Resent-From") || \
($inKey="Resent-Sender") || \
($inKey="Resent-Reply-To") || \
($inKey="Resent-To") || \
($inKey="Resent-Cc") || \
($inKey="Resent-BCc"))
	
	return True
	
End if 

return False
