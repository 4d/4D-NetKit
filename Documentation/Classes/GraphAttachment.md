# GraphAttachment Class

## Overview

`GraphAttachment` represents a Microsoft Graph file attachment on a mail message or calendar event. It exposes attachment metadata and provides lazy download of the binary content via `.getContent()`. A `GraphAttachment` can also be built from a `4D.MailAttachment` via `.fromMailAttachment()`.

Attachments are accessed via the `attachments` property of a [GraphMessage](./GraphMessage.md) or [GraphEvent](./GraphEvent.md) object. To include attachments when creating or updating events and messages, add them to the `attachments` collection of the object.

## Table of Contents

### Functions

* [.fromMailAttachment()](#frommailattachment)
* [.getContent()](#getcontent)
* [.setContent()](#setcontent)

## Properties

A `GraphAttachment` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text | The attachment ID (cid). |
| name | Text | The name displayed below the icon representing the embedded attachment. Does not need to be the actual file name. |
| contentType | Text | The content type of the attachment (MIME type). |
| contentBytes | Text | The base64-encoded contents of the attachment. Used when sending mails. Populated lazily by `.getContent()` when not already present. |
| contentId | Text | The ID of the attachment in the Exchange store. Used for inline attachments. |
| isInline | Boolean | `true` if this is an inline attachment (embedded in the message body). |
| size | Integer | Size in bytes of the attachment. |

## Functions

### .fromMailAttachment()

**.fromMailAttachment**( *attachment* : 4D.MailAttachment )

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| attachment | 4D.MailAttachment | -> | 4D mail attachment to convert into a `GraphAttachment`. |

#### Description

`.fromMailAttachment()` populates the `GraphAttachment` object from a `4D.MailAttachment`. It sets `@odata.type` to `"#microsoft.graph.fileAttachment"`, and maps `contentId`, `isInline`, `name`, `contentType`, and `contentBytes`. No-op when the argument is not a `4D.MailAttachment` instance.

> Note: the `@odata.type` property must be set to `"#microsoft.graph.fileAttachment"` for Microsoft Graph API calls (use the `[""]` syntax since the property name contains a special character).

### .getContent()

**.getContent**() : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | 4D.Blob | <- | The attachment binary content; `Null` if the download fails. |

#### Description

`.getContent()` downloads the attachment binary content via the Microsoft Graph API on first access and caches the result in `contentBytes`. Subsequent calls return the cached content without making a new HTTP request.

### .setContent()

**.setContent**( *content* : 4D.Blob )

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| content | 4D.Blob | -> | Binary content to attach. |

#### Description

`.setContent()` base64-encodes the provided blob and stores it in `contentBytes`, and also updates `size`. No-op when the blob is empty.

#### Example

Create an email with a file attachment and send it:

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
$email.subject:="Hello with attachment"
$email.body:=New object("content"; "Please find the file attached."; "contentType"; "html")

// Create attachment
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

## See also

* [GraphEvent](./GraphEvent.md)
* [GraphMessage](./GraphMessage.md)
* [Office365Mail](./Office365Mail.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365](./Office365.md)
