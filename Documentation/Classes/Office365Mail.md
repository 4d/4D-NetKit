# Office365Mail Class

## Overview

`Office365Mail` is the Microsoft Graph API client for mail operations within 4D NetKit. It supports reading, sending, moving, copying, replying, updating, and deleting messages, as well as managing mail folders and setting up change notifications.

Messages are accepted in three formats, controlled by the `mailType` property:
- `"Microsoft"` (default): Microsoft Graph JSON object
- `"JMAP"`: 4D email object format following the JMAP specification
- `"MIME"`: Raw RFC 2822 format (Text or Blob)

An `Office365Mail` object is accessed via the `mail` property of an [Office365](./Office365.md) object: `$office365.mail`.

## Table of Contents

### Mails

* [.append()](#append)
* [.copy()](#copy)
* [.delete()](#delete)
* [.getMail()](#getmail)
* [.getMails()](#getmails)
* [.move()](#move)
* [.reply()](#reply)
* [.send()](#send)
* [.update()](#update)

### Folders

* [.createFolder()](#createfolder)
* [.deleteFolder()](#deletefolder)
* [.getFolder()](#getfolder)
* [.getFolderList()](#getfolderlist)
* [.renameFolder()](#renamefolder)

### Notifications

* [.notifier()](#notifier)

## Properties

An `Office365Mail` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| mailType | Text | (read-only) Mail type used to send and receive emails. Default is `"Microsoft"`. Can be set using the `mailType` option in [`New Office365 provider`](./Office365.md#new-office365-provider). |
| userId | Text | User identifier used in Service mode. Can be the `id` or the `userPrincipalName`. |

## Mails

### .append()

**.append**( *email* : Object ; *folderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| email | Object | -> | Microsoft message object to create as a draft. |
| folderId | Text | -> | ID of the destination folder. Can be a folder ID or a [well-known folder name](#well-known-folder-names). |
| Result | Object | <- | [Status object](#status-object) with an additional `id` property. |

#### Description

`.append()` creates a draft *email* in the *folderId* folder without sending it. The email must be a [Microsoft mail object](#microsoft-mail-object-properties).

#### Returned object

The method returns a [status object](#status-object) with an additional `id` property containing the ID of the saved message.

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadWrite` |
| Application | `Mail.ReadWrite` |

#### Example

```4d
$status:=$office365.mail.append($draft; $folder.id)
```

### .copy()

**.copy**( *mailId* : Text ; *folderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailId | Text | -> | ID of the mail to copy. |
| folderId | Text | -> | ID of the destination folder. Can be a folder ID or a [well-known folder name](#well-known-folder-names). |
| Result | Object | <- | [Status object](#status-object) with an additional `id` property. |

#### Description

`.copy()` copies the *mailId* email to the *folderId* folder within the user's mailbox.

#### Returned object

The method returns a [status object](#status-object) with an additional `id` property containing the ID of the new copy.

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadWrite` |
| Application | `Mail.ReadWrite` |

#### Example

```4d
$status:=$office365.mail.copy($mailId; $folderId)
```

### .delete()

**.delete**( *mailId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailId | Text | -> | ID of the mail to delete. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.delete()` permanently deletes the *mailId* email.

> You may not be able to delete items in the recoverable items deletions folder. See [Microsoft's documentation](https://learn.microsoft.com/en-us/graph/api/message-delete?view=graph-rest-1.0&tabs=http) for details.

#### Returned object

The method returns a standard [status object](#status-object).

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadWrite` |
| Application | `Mail.ReadWrite` |

#### Example

```4d
For each ($mail; $mails)
  $office365.mail.delete($mail.id)
End for each
```

### .getMail()

**.getMail**( *mailId* : Text { ; *param* : Object } ) : Object<br/>
**.getMail**( *mailId* : Text { ; *param* : Object } ) : Blob

#### Parameters

| Parameter | | Type | | Description |
|---|---|---|:---:|---|
| mailId | | Text | -> | ID of the mail to retrieve. |
| param | | Object | -> | Format options (optional). |
| | mailType | Text | | Mail format to return. Available values: `"MIME"`, `"JMAP"`, `"Microsoft"` (default). If omitted, uses the `mail.type` property of the provider. |
| | contentType | Text | | Format of the `body` and `uniqueBody` properties. Available values: `"text"`, `"html"` (default). |
| Result | | Blob \| Object | <- | Downloaded mail. `Null` on error. |

#### Description

`.getMail()` gets a single mail from its *mailId*.

The data type of the result depends on the mail type:

| mailType | Result type |
|---|---|
| `"MIME"` | Blob |
| `"JMAP"` | Object |
| `"Microsoft"` | Object |

See also [Microsoft's documentation](https://learn.microsoft.com/en-us/graph/api/message-get?view=graph-rest-1.0&tabs=http).

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadBasic`, `Mail.Read` |
| Delegated (personal Microsoft account) | `Mail.ReadBasic`, `Mail.Read` |
| Application | `Mail.ReadBasic.All`, `Mail.Read` |

#### Example

```4d
$mail:=$office365.mail.getMail($mailId)
```

### .getMails()

**.getMails**( *param* : Object ) : [cs.NetKit.GraphMessageList](./GraphMessageList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Options defining which messages to retrieve (optional). |
| Result | [cs.NetKit.GraphMessageList](./GraphMessageList.md) | <- | Paginated list of messages. Use `next()` / `previous()` to navigate pages. |

#### Description

`.getMails()` retrieves messages in the signed-in user's mailbox. This method returns mail bodies in HTML format only.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| folderId | Text | To get messages in a specific folder. Can be a folder ID or a [well-known folder name](#well-known-folder-names). If omitted, gets all messages in the mailbox. |
| search | Text | Restricts results to match a search criterion. See [Microsoft's documentation](https://learn.microsoft.com/en-us/graph/search-query-parameter?tabs=http#using-search-on-message-collections). |
| filter | Text | OData filter expression. See [Microsoft's documentation](https://docs.microsoft.com/en-us/graph/query-parameters#filter-parameter). |
| select | Text | Set of [Microsoft mail object properties](#microsoft-mail-object-properties) to retrieve, comma-separated. |
| top | Integer | Maximum number of messages per page. Default is 10, maximum is 999. |
| orderBy | Text | Sort order. Syntax: `"fieldname asc"` or `"fieldname desc"`. |

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadBasic`, `Mail.Read`, `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadBasic`, `Mail.Read`, `Mail.ReadWrite` |
| Application | `Mail.ReadBasic.All`, `Mail.Read`, `Mail.ReadWrite` |

#### Example

```4d
// Retrieve sender and subject of all mails in the Inbox
$param:=New object
$param.folderId:="inbox"
$param.select:="sender,subject"

$mails:=$office365.mail.getMails($param)
```

### .move()

**.move**( *mailId* : Text ; *folderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailId | Text | -> | ID of the mail to move. |
| folderId | Text | -> | ID of the destination folder. Can be a folder ID or a [well-known folder name](#well-known-folder-names). |
| Result | Object | <- | [Status object](#status-object) with an additional `id` property. |

#### Description

`.move()` moves the *mailId* email to the *folderId* folder. It creates a new copy of the email in the destination folder and removes the original from its source folder.

#### Returned object

The method returns a [status object](#status-object) with an additional `id` property containing the ID of the moved message.

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadWrite` |
| Application | `Mail.ReadWrite` |

#### Example

```4d
$status:=$office365.mail.move($mailId; $folderId)
```

### .reply()

**.reply**( *reply* : Object ; *mailId* : Text { ; *replyAll* : Boolean } ) : Object

#### Parameters

| Parameter | | Type | | Description |
|---|---|---|:---:|---|
| reply | | Object | -> | Reply object. |
| | message | Text \| Blob \| Object | | Microsoft message (object), JMAP (object), or MIME (Blob/Text) containing the response. |
| | comment | Text | | Message used as body to reply (only available with Microsoft message object or no message). You must specify either `comment` or the `body` property of `message`; specifying both returns an HTTP 400 error. |
| mailId | | Text | -> | ID of the mail to reply to. |
| replyAll | | Boolean | -> | `true` to reply to all recipients. Default is `false`. |
| Result | | Object | <- | [Status object](#status-object). |

#### Description

`.reply()` replies to the sender of *mailId* and, optionally, to all recipients.

> Some mails, such as drafts, cannot be replied to.

If `replyAll` is `false` and the original message specifies recipients in the `replyTo` property, the reply is sent to those recipients instead of the `from` recipient.

#### Returned object

The method returns a standard [status object](#status-object).

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.Send` |
| Delegated (personal Microsoft account) | `Mail.Send` |
| Application | `Mail.Send` |

#### Example

```4d
$reply:=New object
$reply.comment:="Thank you for your message"
$status:=$office365.mail.reply($reply; $mails.mailId)
```

### .send()

**.send**( *email* : Text ) : Object<br/>
**.send**( *email* : Object ) : Object<br/>
**.send**( *email* : Blob ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| email | Text \| Blob \| Object | -> | Email to be sent. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.send()` sends an email using the MIME or JSON formats.

In *email*, pass the email to send:
- **Text or Blob**: sent using MIME format.
- **Object**: sent using JSON format — either the [Microsoft mail object properties](#microsoft-mail-object-properties) or the [4D email object format](https://developer.4d.com/docs/API/EmailObjectClass.html#email-object) (JMAP).

> Passing both `textBody` and `htmlBody` is not supported. In that case, only the HTML body is sent.

The data type passed in *email* must be compatible with the `mailType` property.

> Ensure your application has permission to send emails. See [Microsoft permissions](https://docs.microsoft.com/en-us/graph/api/user-sendmail?view=graph-rest-1.0&tabs=http#permissions).

#### Returned object

The method returns a standard [status object](#status-object).

#### Example

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $param; $email; $status : Object

$param:=New object()
$param.name:="Microsoft"
$param.permission:="signedIn"
$param.clientId:="your-client-id"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:="https://graph.microsoft.com/Mail.Send"

$oAuth2:=New OAuth2 provider($param)

$email:=New object()
$email.from:=New object("emailAddress"; New object("address"; "sender@example.com"))
$email.toRecipients:=New collection(New object("emailAddress"; New object("address"; "recipient@example.com")))
$email.body:=New object("content"; "Hello, World!"; "contentType"; "html")
$email.subject:="Hello, World!"

// Attach a file
var $attachment : Object
var $attachmentText : Text
$attachmentText:="Simple text file"
BASE64 ENCODE($attachmentText)
$attachment:=New object
$attachment["@odata.type"]:="#microsoft.graph.fileAttachment"
$attachment.name:="attachment.txt"
$attachment.contentBytes:=$attachmentText
$email.attachments:=New collection($attachment)

var $Office365:=New Office365 provider($oAuth2; New object("mailType"; "Microsoft"))
$status:=$Office365.mail.send($email)
```

### .update()

**.update**( *mailId* : Text ; *updatedFields* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailId | Text | -> | ID of the email to update. |
| updatedFields | Object | -> | Email fields to update. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.update()` updates various properties of received or drafted emails.

In *updatedFields*, you can pass the following properties:

| Property | Type | Description | Draft only |
|---|---|---|---|
| bccRecipients | Collection | The Bcc recipients. | |
| body | Object | The body of the message (`content` + `contentType`). | Yes |
| categories | Collection | Categories associated with the message. | |
| ccRecipients | Collection | The Cc recipients. | |
| flag | Object | Followup flag (`flagStatus`, `startDateTime`, `dueDateTime`). | |
| from | Recipient | The sender. Must correspond to the actual mailbox used. | Yes |
| importance | Text | `"Low"`, `"Normal"`, or `"High"`. | |
| inferenceClassification | Text | `"focused"` or `"other"`. | |
| isDeliveryReceiptRequested | Boolean | Whether a delivery receipt is requested. | Yes |
| isRead | Boolean | Whether the message has been read. | |
| isReadReceiptRequested | Boolean | Whether a read receipt is requested. | Yes |
| replyTo | Collection | Email addresses to use when replying. | Yes |
| sender | Recipient | The account used to generate the message. | Yes |
| subject | Text | The subject of the message. | Yes |
| toRecipients | Collection | The To recipients. | |

> Existing properties not included in *updatedFields* maintain their previous values.

#### Returned object

The method returns a standard [status object](#status-object).

## Folders

### .createFolder()

**.createFolder**( *name* : Text { ; *isHidden* : Boolean { ; *parentFolderId* : Text } } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| name | Text | -> | Display name of the new folder. |
| isHidden | Boolean | -> | `true` to create a hidden folder. Default is `false`. Cannot be changed afterwards. |
| parentFolderId | Text | -> | ID of the parent folder. Can be a folder ID or a [well-known folder name](#well-known-folder-names). If omitted, creates the folder at the root. |
| Result | Object | <- | [Status object](#status-object) with an additional `id` property. |

#### Description

`.createFolder()` creates a new mail folder named *name*.

By default, the folder is created at the root of the mailbox. Pass a *parentFolderId* to create it inside an existing folder. Hidden folders cannot be made visible after creation. See [Hidden mail folders](https://docs.microsoft.com/en-us/graph/api/resources/mailfolder?view=graph-rest-1.0#hidden-mail-folders).

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadWrite` |
| Application | `Mail.ReadWrite` |

#### Returned object

The method returns a [status object](#status-object) with an additional `id` property containing the ID of the new folder.

#### Example

```4d
// Create a new folder at the root and move an email into it
$status:=$office365.mail.createFolder("Backup")
If ($status.success)
  $folderId:=$status.id
  $status:=$office365.mail.move($mailId; $folderId)
End if
```

### .deleteFolder()

**.deleteFolder**( *folderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| folderId | Text | -> | ID of the folder to delete. Can be a folder ID or a [well-known folder name](#well-known-folder-names). |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.deleteFolder()` permanently deletes the *folderId* mail folder.

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadWrite` |
| Application | `Mail.ReadWrite` |

#### Returned object

The method returns a standard [status object](#status-object).

#### Example

```4d
$status:=$office365.mail.deleteFolder($folderId)
```

### .getFolder()

**.getFolder**( *folderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| folderId | Text | -> | ID of the folder to get. Can be a folder ID or a [well-known folder name](#well-known-folder-names). |
| Result | Object | <- | `mailFolder` object, or `Null` on error. |

#### Description

`.getFolder()` returns a `mailFolder` object from its *folderId*.

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadBasic`, `Mail.Read`, `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadBasic`, `Mail.Read`, `Mail.ReadWrite` |
| Application | `Mail.ReadBasic.All`, `Mail.Read`, `Mail.ReadWrite` |

#### mailFolder object

The method returns a `mailFolder` object with the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text | The mailFolder's unique identifier. |
| displayName | Text | The mailFolder's display name. |
| parentFolderId | Text | Unique identifier for the mailFolder's parent mailFolder. |
| childFolderCount | Integer | Number of immediate child mailFolders. |
| totalItemCount | Integer | Number of items in the mailFolder. |
| unreadItemCount | Integer | Number of items marked as unread. |
| isHidden | Boolean | `true` if the mailFolder is hidden. |

### .getFolderList()

**.getFolderList**( *param* : Object ) : [cs.NetKit.GraphFolderList](./GraphFolderList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Options defining which folders to retrieve (optional). |
| Result | [cs.NetKit.GraphFolderList](./GraphFolderList.md) | <- | Paginated list of mail folders. Use `next()` / `previous()` to navigate pages. |

#### Description

`.getFolderList()` returns a mail folder collection of the signed-in user.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| folderId | Text | Parent folder ID or [well-known folder name](#well-known-folder-names). If omitted, returns folders under the root. |
| search | Text | Restricts results to match a search criterion. See [Microsoft's documentation](https://docs.microsoft.com/en-us/graph/search-query-parameter#using-search-on-directory-object-collections). |
| filter | Text | OData filter expression. |
| select | Text | Set of properties to retrieve, comma-separated. |
| top | Integer | Page size. Default is 10, maximum is 999. |
| orderBy | Text | Sort order. Syntax: `"fieldname asc"` or `"fieldname desc"`. |
| includeHiddenFolders | Boolean | `true` to include hidden folders. Default is `false`. |

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadBasic`, `Mail.Read`, `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadBasic`, `Mail.Read`, `Mail.ReadWrite` |
| Application | `Mail.ReadBasic.All`, `Mail.Read`, `Mail.ReadWrite` |

#### Example

```4d
// Get the mail folder collection under the root folder
var $result : Object
$result:=$office365.mail.getFolderList()

// Get subfolders of the 9th folder
var $subfolders:=$office365.mail.getFolderList({folderId: $result.folders[8].id})
```

### .renameFolder()

**.renameFolder**( *folderId* : Text ; *name* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| folderId | Text | -> | ID of the folder to rename. |
| name | Text | -> | New display name for the folder. |
| Result | Object | <- | [Status object](#status-object) with an additional `id` property. |

#### Description

`.renameFolder()` renames the *folderId* mail folder with the provided *name*.

> Note: The renamed folder ID is different from the original *folderId*. The new ID is returned in the status object.

#### Permissions

| Permission type | Permissions |
|---|---|
| Delegated (work or school account) | `Mail.ReadWrite` |
| Delegated (personal Microsoft account) | `Mail.ReadWrite` |
| Application | `Mail.ReadWrite` |

#### Returned object

The method returns a [status object](#status-object) with an additional `id` property containing the new ID of the renamed folder.

#### Example

```4d
$status:=$office365.mail.renameFolder($folderId; "Backup_old")
```

## Notifications

### .notifier()

**.notifier**( *param* : Object { ; *folderId* : Text } ) : [cs.NetKit.GraphNotification](./GraphNotification.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Callback and mode definitions (see below). |
| folderId | Text | -> | *(optional)* Subscribe only to changes in that mail folder. If omitted, subscribe to all folders. |
| Result | [cs.NetKit.GraphNotification](./GraphNotification.md) | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted`. Call `start()` to begin monitoring. |

#### Description

`.notifier()` creates and returns a [GraphNotification](./GraphNotification.md) object allowing you to configure, start, and stop subscriptions to mail change notifications.

Two modes are available:

- **Push** (webhook): Real-time notifications via HTTP callbacks. Requires a publicly accessible HTTPS endpoint. Creates a [Microsoft Graph subscription](https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions). The webhook URL is derived as `{endPoint}/4dnk-graph-notification?state={uuid}`.
- **Pull** (polling): Periodic polling of the [delta query API](https://learn.microsoft.com/en-us/graph/delta-query-messages). No external endpoint needed.

The subscription is automatically closed when the notifier object is destroyed. Callbacks are dispatched in the 4D worker where `start()` was originally called.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Webhook URL for **push** mode. If omitted, uses **pull** mode. Must be a publicly accessible HTTPS endpoint. See [endPoint management in Office365Calendar](./Office365Calendar.md#endpoint-management). |
| onCreate | 4D.Function | Callback for a mail creation *(optional)*. |
| onDelete | 4D.Function | Callback for a mail deletion *(optional)*. |
| onModify | 4D.Function | Callback for a mail modification *(optional)*. |
| timer | Integer | Polling interval in seconds for pull mode (default: 30) *(optional)*. |

Callback functions receive two parameters:

| Parameter | Type | Description |
|---|---|---|
| office365 | cs.NetKit.Office365 | The current [Office365](./Office365.md) object. |
| event | Object | Object with `type` (Text: `"mailCreated"`, `"mailDeleted"`, or `"mailModified"`) and `ids` (Collection of affected mail IDs). |

#### Returned object

The returned [GraphNotification](./GraphNotification.md) object contains the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Publicly accessible HTTPS endpoint that receives notifications. |
| expiration | Text | Expiration date and time (timestamp). Read-only. |
| isStarted | Boolean | `true` when notifications are active. Read-only. |
| start() | 4D.Function | Starts the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| stop() | 4D.Function | Stops the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| timer | Integer | Polling interval in seconds (pull mode). |

#### Example

Mail notifications via webhook (push mode):

```4d
var $notif:=$office365.mail.notifier({ \
    endPoint: "https://myserver.com"; \
    onCreate: Formula(ALERT("New mail: "+String($2.ids))); \
    onDelete: Formula(ALERT("Mail deleted: "+String($2.ids))) \
})
$status:=$notif.start()
```

## Well-known folder names

Outlook creates certain folders for users by default. Instead of using the folder ID, you can use the well-known folder name when accessing these folders. Well-known names work regardless of the locale of the user's mailbox. For example, you can get the Drafts folder using `"draft"`. For the full list, see [Microsoft's documentation](https://docs.microsoft.com/en-us/graph/api/resources/mailfolder?view=graph-rest-1.0).

## Microsoft mail object properties

When you send or create an email with the `"Microsoft"` mail type, you must pass an object. For a comprehensive list, see the [Microsoft documentation](https://learn.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0#properties). Most common properties:

| Property | Type | Description |
|---|---|---|
| attachments | Collection | The [GraphAttachment](./GraphAttachment.md) objects for the email. Each must have `@odata.type` set to `"#microsoft.graph.fileAttachment"` (use `[""]` syntax). |
| bccRecipients | Collection | The Bcc recipients. Each item is a [GraphRecipient](./GraphRecipient.md) object. |
| body | Object | The body: `content` (Text) and `contentType` (`"text"` or `"html"`). |
| ccRecipients | Collection | The Cc recipients. Each item is a [GraphRecipient](./GraphRecipient.md) object. |
| flag | Object | Followup flag: `flagStatus`, `startDateTime`, `dueDateTime`. |
| from | Object | The sender. A [GraphRecipient](./GraphRecipient.md) object. |
| id | Text | Unique identifier for the message. |
| importance | Text | `"low"`, `"normal"`, or `"high"`. |
| internetMessageHeaders | Collection | Message headers per RFC 5322. Each item has `name` (Text) and `value` (Text). |
| isDeliveryReceiptRequested | Boolean | Whether a delivery receipt is requested. |
| isReadReceiptRequested | Boolean | Whether a read receipt is requested. |
| replyTo | Collection | Email addresses to use when replying. Collection of [GraphRecipient](./GraphRecipient.md) objects. |
| sender | Object | The account used to generate the message. A [GraphRecipient](./GraphRecipient.md) object. |
| subject | Text | The subject of the message. |
| toRecipients | Collection | The To recipients. Collection of [GraphRecipient](./GraphRecipient.md) objects. |

## Status object

Several `Office365Mail` functions return a `status` object containing the following properties:

| Property | Type | Description |
|---|---|---|
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the server or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |
| id | Text | Returned by [`copy()`](#copy), [`move()`](#move): ID of the mail. Returned by [`createFolder()`](#createfolder), [`renameFolder()`](#renamefolder): ID of the folder. |

## See also

* [GraphMessage](./GraphMessage.md)
* [GraphMessageList](./GraphMessageList.md)
* [GraphFolderList](./GraphFolderList.md)
* [GraphAttachment](./GraphAttachment.md)
* [GraphRecipient](./GraphRecipient.md)
* [GraphNotification](./GraphNotification.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365](./Office365.md)
