//%attributes = {}
var $params : Object

$params:=New object:C1471()
$params.timeout:=30
If (False:C215)
	$params.name:="Microsoft"
	$params.redirectURI:="http://127.0.0.1:50993/authorize/"
	$params.token:=Null:C1517
	$params.permission:="signedIn"
	$params.clientId:="7008ebf5-f013-4d92-ad5b-8c2252c460fc"
	//$params.scope:="https://graph.microsoft.com/.default"
	$params.scope:="https://graph.microsoft.com/Mail.Read"
	//$params.scope:="https://outlook.office.com/Mail.Send"
	//$params.scope:="https://outlook.office.com/POP.AccessAsUser.All https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/SMTP.Send"
Else 
	$params.name:="Microsoft"
	$params.permission:="service"
	$params.redirectURI:="http://127.0.0.1:50993/authorize/"
	$params.scope:="https://graph.microsoft.com/.default"
	
	$params.clientId:="694b0b61-657a-4b16-b3eb-650acb27d4a2"
	$params.clientSecret:="tJ87Q~Fl.Y_L_JnCHUWtLEnkrSFoXaKWPbHKR"  // Expires on 27-Dec-2023
	$params.tenant:="06dc191b-7348-4b66-b0d9-806cb7d9455b"
End if 

var $oauth2 : cs:C1710.OAuth2Provider
var $token : Object
$oauth2:=New OAuth2 provider($params)
$token:=$oauth2.getToken()

var $office365 : cs:C1710.Office365
var $select : Text

var $options : Object
$options:=New object:C1471("select"; "id,userPrincipalName,from,subject")
$options.top:=10

$office365:=New Office365 provider($oauth2)

If (False:C215)
	
	TRACE:C157
	var $status; $message; $mailObject : Object
	
	$message:=New object:C1471
	$message.toRecipients:=New collection:C1472(New object:C1471("emailAddress"; New object:C1471("address"; "yannick.trinh@4d.com")))
	//$message.ccRecipients:=New collection(New object("emailAddress"; New object("address"; "ytrinh@free.fr")))
	$message.conversationId:="AQHYLXwBlQbepr9di0+23ytWcFik7A=="  // JMAP threadId
	$message.importance:="low"  // low, normal, or high
	$message.subject:="Test message subject"
	$message.body:=New object:C1471("contentType"; "Text"; \
		"content"; "Test message sent from Graph REST API v1.0\r\n\r\nQuelques caractères accentués...")
	$message.parentFolderId:="Inbox"
	$message.lastModifiedDateTime:="2022-03-01T00:00:00Z"
	$message.isReadReceiptRequested:=True:C214
	$message.isDeliveryReceiptRequested:=True:C214
	$message.flag:=New object:C1471("flagStatus"; "flagged")  //; "startDateTime"; "2022-03-01T00:00:00Z")
	// ???
	$message.createdDateTime:="2022-03-01T00:00:00Z"
	$message.inferenceClassification:="focused"
	//$message.conversationIndex:=1
	$message.sender:=New object:C1471("emailAddress"; New object:C1471("address"; "yannick.trinh@4d.com"))
	
	var $attachment : Object
	var $attachmentText : Text
	$attachmentText:="Simple text attachement content"
	BASE64 ENCODE:C895($attachmentText)
	$attachment:=New object:C1471
	$attachment["@odata.type"]:="#microsoft.graph.fileAttachment"
	$attachment.contentId:=Generate UUID:C1066
	$attachment.isInline:=False:C215
	$attachment.name:="attachment.txt"
	$attachment.contentType:="text/plain"
	$attachment.contentBytes:=$attachmentText
	$attachment.size:=Length:C16($attachmentText)
	$message.attachments:=New collection:C1472($attachment)
	
	$office365.mail.mailType:="microsoft"
	$office365.mail.userId:="test.produit@4D.onmicrosoft.com"
	$status:=$office365.mail.send($message)
	ASSERT:C1129($status.success)
	//TEXT TO DOCUMENT("status.json"; JSON Stringify($status; *))
End if 

If (False:C215)
	TRACE:C157
	var $test : Text
	$test:="yannick.trinh@4d.com"
	$userInfo:=$office365.user.get($test)
	
	
	$userInfo:=$office365.user.get("4d_fr4434@4D.com"; $select)
	ASSERT:C1129($userInfo.id="5191ea6a-a4ba-4dfe-8e14-1b309a0b0250")
	
	$userInfo:=$office365.user.get("258ed860-ef3c-4545-bad8-cc06b94cfd64")
	ASSERT:C1129($userInfo.userPrincipalName="4d_dev2614@4D.onmicrosoft.com")
End if 

If (False:C215)
	TRACE:C157
	var $userInfo; $status : Object
	$userInfo:=$office365.user.list($options)
	//$userInfo:=$office365.user.list(New object("search"; "\"userPrincipalName:4DMail@4d.com\""))
	
	//$userInfo:=$office365.user.list(New object("top"; "10"))
	//TEXT TO DOCUMENT("result.json"; JSON Stringify($userInfo; *))
	$status:=$userInfo.next()
	$status:=$userInfo.next()
	//$userInfo.next()
	$status:=$userInfo.previous()
	$status:=$userInfo.previous()
End if 

If (False:C215)
	TRACE:C157
	var $col; $col2 : Collection
	var $informationList1 : Object
	
	//$informationList1:=$office365.user.list(New object("select"; "userPrincipalName"))
	$informationList1:=$office365.user.list()
	
	$col:=New collection:C1472
	Repeat 
		$col.combine($informationList1.users)
		If ($informationList1.isLastPage)
			break
		End if 
	Until (Not:C34($informationList1.next()))
	
	$col2:=New collection:C1472
	Repeat 
		$col2.combine($informationList1.users)
	Until (Not:C34($informationList1.previous()))
End if 

If (False:C215)
	TRACE:C157
	ON ERR CALL:C155("_errorHandler")
	$userInfo:=$office365.user.getCurrentUser()
	ON ERR CALL:C155("")
End if 

If (False:C215)
	TRACE:C157
	
	var $result : Collection
	$office365.mail.userId:="test.produit@4D.onmicrosoft.com"
	$result:=$office365.mail.getFolderList()
	$result:=$office365.mail.getFolderList(New object:C1471("folderId"; $result[7].id))
	
End if 

If (True:C214)
	TRACE:C157
	
	var $mailList; $mail; $attachment; $blob; $status : Object
	$office365.mail.userId:="test.produit@4D.onmicrosoft.com"
	$mailList:=$office365.mail.getMails()
	//$status:=$mailList.next()
	//$status:=$mailList.next()
	
	$mail:=$mailList.mails[8]
	$attachment:=$mail.attachments[0]
	$blob:=$attachment.getContent()
	
End if 
