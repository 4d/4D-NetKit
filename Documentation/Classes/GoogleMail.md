# GoogleMail Class

## Overview

`GoogleMail` is the Gmail API client within 4D NetKit. It provides send, append, read, delete, label management, and change-notification operations.

Both JMAP (4D mail object) and MIME (raw RFC 2822) formats are supported, controlled by the `mailType` property set when creating the [Google](./Google.md) object.

A `GoogleMail` object is accessed via the `mail` property of a [Google](./Google.md) object: `$google.mail`.

## Table of Contents

### Mails

* [.append()](#append)
* [.delete()](#delete)
* [.getMail()](#getmail)
* [.getMailIds()](#getmailids)
* [.getMails()](#getmails)
* [.send()](#send)
* [.untrash()](#untrash)
* [.update()](#update)

### Labels

* [.createLabel()](#createlabel)
* [.deleteLabel()](#deletelabel)
* [.getLabel()](#getlabel)
* [.getLabelList()](#getlabellist)
* [.updateLabel()](#updatelabel)

### Notifications

* [.notifier()](#notifier)

## Properties

A `GoogleMail` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| mailType | Text | (read-only) Mail type used to send and receive emails. Can be `"MIME"` or `"JMAP"`. Set via the `mailType` option in [`cs.NetKit.Google.new()`](./Google.md#csnetkitgooglenew). |
| userId | Text | User identifier used to identify the user in Service mode. Can be the `id` or the `userPrincipalName`. |

## Mails

### .append()

**.append**( *mail* : Text { ; *labelIds* : Collection } ) : Object<br/>
**.append**( *mail* : Blob { ; *labelIds* : Collection } ) : Object<br/>
**.append**( *mail* : Object { ; *labelIds* : Collection } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mail | Text \| Blob \| Object | -> | Email to store. BLOB or Text for MIME format; Object (JMAP) for JMAP format. |
| labelIds | Collection | -> | Collection of label IDs to apply. Defaults to `["DRAFT"]` when omitted or empty. |
| Result | Object | <- | [Status object](#status-object) with an additional `id` property. |

#### Description

`.append()` stores a mail message in the user's mailbox without sending it. Useful for importing existing messages or saving drafts with custom labels.

> If `labelIds` is passed and the mail has a `from` or `sender` header, the Gmail server automatically adds the `SENT` label.

#### Returned object

The method returns a [status object](#status-object) with an additional `id` property:

| Property | Type | Description |
|---|---|---|
| id | Text | ID of the email created on the server. |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Example

```4d
// Append a mail as a draft (default)
$status:=$google.mail.append($mail)

// Append a mail directly to the inbox
$status:=$google.mail.append($mail; ["INBOX"])
```

### .delete()

**.delete**( *mailID* : Text { ; *permanently* : Boolean } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailID | Text | -> | ID of the mail to delete. |
| permanently | Boolean | -> | If `true`, deletes permanently. If `false` (default), moves the message to Trash. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.delete()` deletes the specified message from the user's mailbox, either permanently or by moving it to Trash.

#### Returned object

The method returns a standard [status object](#status-object).

#### Permissions

This method requires one of the following OAuth scopes:

```
https://mail.google.com/
https://www.googleapis.com/auth/gmail.modify
```

#### Example

```4d
// Delete permanently
$status:=$google.mail.delete($mailId; True)
```

### .getMail()

**.getMail**( *mailID* : Text { ; *param* : Object } ) : Object<br/>
**.getMail**( *mailID* : Text { ; *param* : Object } ) : Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailID | Text | -> | ID of the message to retrieve. |
| param | Object | -> | Options for the message to retrieve (optional). |
| Result | Object \| Blob | <- | Downloaded mail; `Null` on error. |

#### Description

`.getMail()` gets the specified message from the user's mailbox.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| format | Text | The format to return the message in. Can be: `"raw"` (default, full email), `"minimal"` (ID and labels only), `"metadata"` (ID, labels, and headers only). |
| headers | Collection | Collection of header names to return. Only used when `format` is `"metadata"`. |
| mailType | Text | Override the instance `mailType` for this call. Can be `"MIME"` or `"JMAP"`. |

#### Returned object

The method returns a mail in one of the following formats depending on `mailType`:

| Format | Type | Comment |
|---|---|---|
| MIME | Blob | |
| JMAP | Object | Contains an `id` attribute. |

### .getMailIds()

**.getMailIds**( { *param* : Object } ) : [cs.NetKit.GoogleMailIdList](./GoogleMailIdList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Options for filtering messages (optional). |
| Result | [cs.NetKit.GoogleMailIdList](./GoogleMailIdList.md) | <- | Paginated list of Gmail message IDs. Use `next()` / `previous()` to navigate pages. |

#### Description

`.getMailIds()` returns an object containing a collection of message IDs in the user's mailbox.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| top | Integer | Maximum number of messages to return. Default is 100, maximum is 500. |
| search | Text | Only return messages matching the specified query. Supports Gmail search syntax. See [Gmail search operators](https://support.google.com/mail/answer/7190). |
| labelIds | Collection | Only return messages that have all the specified label IDs. |
| includeSpamTrash | Boolean | Include messages from SPAM and TRASH. Default is `false`. |

#### Returned object

The method returns a [GoogleMailIdList](./GoogleMailIdList.md) object with the following properties:

| Property | Type | Description |
|---|---|---|
| mailIds | Collection | Collection of objects, each with `id` (Text) and `threadId` (Text). Empty if no mail is returned. |
| isLastPage | Boolean | `true` if the last page is reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 10 (configurable via `top`). |
| next() | 4D.Function | Loads the next page. Returns `true` if successful, `false` otherwise. |
| previous() | 4D.Function | Loads the previous page. Returns `true` if successful, `false` otherwise. |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Permissions

This method requires one of the following OAuth scopes:

```
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/gmail.readonly
https://www.googleapis.com/auth/gmail.metadata
```

### .getMails()

**.getMails**( *mailIDs* : Collection { ; *param* : Object } ) : Collection

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailIDs | Collection | -> | Collection of mail IDs (Text), or collection of objects each with an `id` property. |
| param | Object | -> | Options (same properties as `.getMail()`) (optional). |
| Result | Collection | <- | Collection of mails (JMAP objects or Blobs depending on `mailType`). `Null` on error. |

#### Description

`.getMails()` gets a collection of emails based on the specified `mailIDs` collection.

> The maximum number of IDs supported is 100. For more than 100 mails, call the function multiple times.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| format | Text | The format to return the messages in. Can be: `"raw"` (default), `"minimal"`, or `"metadata"`. |
| headers | Collection | Collection of header names to return. Only used when `format` is `"metadata"`. |
| mailType | Text | Override the instance `mailType` for this call. Can be `"MIME"` or `"JMAP"`. |

#### Returned value

The method returns a collection of mails in one of the following formats depending on `mailType`:

| Format | Type | Comment |
|---|---|---|
| MIME | Blob | |
| JMAP | Object | Contains an `id` attribute. |

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

`.send()` sends an email using the MIME or JMAP format.

In *email*, pass the email to send:
- **Text or Blob**: sent using MIME format.
- **Object**: sent using JMAP format, following the [4D email object format](https://developer.4d.com/docs/API/EmailObjectClass.html#email-object).

The data type passed in `email` must be compatible with the `mailType` property.

> To avoid authentication errors, ensure your application has appropriate authorizations. One of the following OAuth scopes is required: [`gmail.modify`](https://www.googleapis.com/auth/gmail.modify), [`gmail.compose`](https://www.googleapis.com/auth/gmail.compose), or [`gmail.send`](https://www.googleapis.com/auth/gmail.send).

#### Returned object

The method returns a standard [status object](#status-object).

#### Example

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider

var $credential:={}
$credential.name:="Google"
$credential.permission:="signedIn"
$credential.clientId:="your-client-id"
$credential.clientSecret:="your-client-secret"
$credential.redirectURI:="http://127.0.0.1:50993/authorize/"
$credential.scope:="https://www.googleapis.com/auth/gmail.send"

$oAuth2:=cs.NetKit.OAuth2Provider.new($credential)

var $email:={}
$email.from:="noreply.mail@gmail.com"
$email.to:="address1@mail.com,address2@mail.com"
$email.cc:={name: "Stephen"; email: "address3@mail.com"}
$email.subject:="Hello world"
$email.textBody:="Test mail \r\n This is just a test e-mail \r\n Please ignore it"
$email.attachments:=[MAIL New attachment($filePath)]

var $Google:=cs.NetKit.Google.new($oAuth2; {mailType: "JMAP"})
var $status:=$Google.mail.send($email)
```

### .untrash()

**.untrash**( *mailID* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailID | Text | -> | ID of the message to remove from Trash. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.untrash()` removes the specified message from Trash.

#### Returned object

The method returns a standard [status object](#status-object).

#### Permissions

This method requires one of the following OAuth scopes:

```
https://mail.google.com/
https://www.googleapis.com/auth/gmail.modify
```

### .update()

**.update**( *mailIDs* : Collection ; *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| mailIDs | Collection | -> | Collection of mail IDs (Text), or collection of objects each with an `id` property. Limited to 1000 IDs per request. |
| param | Object | -> | Modification options. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.update()` adds or removes labels on the specified messages to help categorize emails. Labels can be system labels (e.g., `INBOX`, `SPAM`, `TRASH`, `UNREAD`, `STARRED`, `IMPORTANT`) or custom labels. Multiple labels can be applied simultaneously.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| addLabelIds | Collection | Collection of label IDs to add to the messages. |
| removeLabelIds | Collection | Collection of label IDs to remove from the messages. |

#### Returned object

The method returns a standard [status object](#status-object).

#### Example

```4d
// Mark a collection of emails as unread
$result:=$google.mail.update($mailIds; {addLabelIds: ["UNREAD"]})
```

## Labels

### .createLabel()

**.createLabel**( *labelInfo* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| labelInfo | Object | -> | [labelInfo object](#labelinfo-object) containing label properties to create. |
| Result | Object | <- | [Status object](#status-object) with an additional `label` property. |

#### Description

`.createLabel()` creates a new label.

#### Returned object

The method returns a [status object](#status-object) with an additional `label` property:

| Property | Type | Description |
|---|---|---|
| label | Object | Newly created label instance (see [labelInfo object](#labelinfo-object)). |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Example

```4d
$status:=$google.mail.createLabel({name: "Backup"})
$labelId:=$status.label.id
```

### .deleteLabel()

**.deleteLabel**( *labelId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| labelId | Text | -> | ID of the label to delete. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.deleteLabel()` immediately and permanently deletes the specified label and removes it from any messages and threads it is applied to.

> This method is only available for labels with `type="user"`.

#### Returned object

The method returns a standard [status object](#status-object).

#### Example

```4d
$status:=$google.mail.deleteLabel($labelId)
```

### .getLabel()

**.getLabel**( *labelId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| labelId | Text | -> | ID of the label to retrieve. |
| Result | Object | <- | [labelInfo object](#labelinfo-object) with additional counter properties. |

#### Description

`.getLabel()` returns the information of a label.

#### Returned object

The returned [labelInfo object](#labelinfo-object) includes the following additional properties:

| Property | Type | Description |
|---|---|---|
| messagesTotal | Integer | Total number of messages with this label. |
| messagesUnread | Integer | Number of unread messages with this label. |
| threadsTotal | Integer | Total number of threads with this label. |
| threadsUnread | Integer | Number of unread threads with this label. |

#### Example

```4d
$info:=$google.mail.getLabel($labelId)
$name:=$info.name
$emailNumber:=$info.messagesTotal
$unread:=$info.messagesUnread
```

### .getLabelList()

**.getLabelList**() : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Object | <- | [Status object](#status-object) with an additional `labels` property. |

#### Description

`.getLabelList()` returns an object containing the collection of all labels in the user's mailbox.

#### Returned object

The method returns a [status object](#status-object) with an additional `labels` property:

| Property | Type | Description |
|---|---|---|
| labels | Collection | Collection of [`mailLabel` objects](#maillabel-object). |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### mailLabel object

A `mailLabel` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| name | Text | Display name of the label. |
| id | Text | Immutable ID of the label. |
| messageListVisibility | Text | Visibility in the message list. Can be `"show"` or `"hide"`. |
| labelListVisibility | Text | Visibility in the label list. Can be `"labelShow"`, `"labelShowIfUnread"`, or `"labelHide"`. |
| type | Text | Owner type: `"user"` (custom, modifiable) or `"system"` (created by Gmail, cannot be modified or deleted). |

### .updateLabel()

**.updateLabel**( *labelId* : Text ; *labelInfo* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| labelId | Text | -> | ID of the label to update. |
| labelInfo | Object | -> | [labelInfo object](#labelinfo-object) containing updated label properties. |
| Result | Object | <- | [Status object](#status-object) with an additional `label` property. |

#### Description

`.updateLabel()` updates the specified label.

> This method is only available for labels with `type="user"`.

#### Returned object

The method returns a [status object](#status-object) with an additional `label` property:

| Property | Type | Description |
|---|---|---|
| label | Object | Updated label instance (see [labelInfo object](#labelinfo-object)). |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Example

```4d
$status:=$google.mail.updateLabel($labelId; {name: "Backup January"})
```

## Notifications

### .notifier()

**.notifier**( *param* : Object { ; *folderId* : Text } ) : [cs.NetKit.GoogleNotification](./GoogleNotification.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Callback and mode definitions (see below). |
| folderId | Text | -> | *(optional)* Subscribe only to changes in that mail folder. If omitted, subscribe to all folders. |
| Result | [cs.NetKit.GoogleNotification](./GoogleNotification.md) | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted`. Call `start()` to begin monitoring. |

#### Description

`.notifier()` creates and returns a [GoogleNotification](./GoogleNotification.md) object allowing you to configure, start, and stop subscriptions to mail change notifications.

Two modes are available:

- **Push** (webhook): Real-time notifications via HTTP callbacks. Requires a publicly accessible HTTPS endpoint. The webhook URL is derived as `{endPoint}/4dnk-google-notification?state={uuid}`.
- **Pull** (polling): Periodic polling of change APIs. No external endpoint needed. Polls the Gmail history API at the configured interval.

When a resource changes, user-defined callbacks are dispatched in the 4D worker where the notifier's `start()` function was originally called. The subscription is automatically closed when the notifier object is destroyed.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Webhook URL for **push** mode. If omitted, uses **pull** mode. Must be a publicly accessible HTTPS endpoint. See [endPoint management](./GoogleCalendar.md#endpoint-management). |
| onCreate | 4D.Function | Callback for a mail creation *(optional)*. |
| onDelete | 4D.Function | Callback for a mail deletion *(optional)*. |
| onModify | 4D.Function | Callback for a mail modification *(optional)*. |
| timer | Integer | Polling interval in seconds for pull mode (default: 30) *(optional)*. |

Callback functions receive two parameters:

| Parameter | Type | Description |
|---|---|---|
| google | cs.NetKit.Google | The current [Google](./Google.md) object. |
| event | Object | Object with `type` (Text: `"mailCreated"`, `"mailDeleted"`, or `"mailModified"`) and `ids` (Collection of affected mail IDs). |

#### Returned object

The returned [GoogleNotification](./GoogleNotification.md) object contains the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Publicly accessible HTTPS endpoint that receives notifications. |
| expiration | Text | Expiration date and time (timestamp). Read-only. |
| isStarted | Boolean | `true` when notifications are active, `false` when stopped. Read-only. |
| start() | 4D.Function | Starts the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| stop() | 4D.Function | Stops the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| timer | Integer | Interval in seconds between delta query checks (pull mode). |

#### Example

Mail notifications via webhook (push mode):

```4d
var $notif:=$google.mail.notifier({ \
    endPoint: "https://myserver.com"; \
    onCreate: Formula(ALERT("New mail: "+String($2.ids))); \
    onDelete: Formula(ALERT("Mail deleted: "+String($2.ids))) \
})
$status:=$notif.start()
```

## labelInfo object

Several `.GoogleMail` label management methods use a `labelInfo` object, containing the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text | ID of the label. |
| name | Text | Display name of the label. **Mandatory** when creating a label. |
| messageListVisibility | Text | Visibility in the message list. Can be `"show"` or `"hide"`. |
| labelListVisibility | Text | Visibility in the label list. Can be `"labelShow"`, `"labelShowIfUnread"`, or `"labelHide"`. |
| [color](https://developers.google.com/gmail/api/reference/rest/v1/users.labels?hl=en#color) | Object | Color for the label (only available for `type="user"` labels). Contains `textColor` (Text, hex) and `backgroundColor` (Text, hex, e.g., `"#000000"`). |
| type | Text | Owner type: `"system"` (Gmail-created) or `"user"` (custom, modifiable). |

## Status object

Several `GoogleMail` functions return a `status` object containing the following properties:

| Property | Type | Description |
|---|---|---|
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Gmail server or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |

## See also

* [GoogleMailIdList](./GoogleMailIdList.md)
* [GoogleNotification](./GoogleNotification.md)
* [Google](./Google.md)
