# Office365Mail Class

## Overview

Microsoft Graph API client for mail operations.
Supports reading, sending, moving, copying, replying, updating, and deleting messages,
as well as managing mail folders and setting up change notifications.
Accepts messages in Microsoft Graph JSON (`"Microsoft"`), JMAP (`"JMAP"`), or MIME
(`"MIME"`) format, controlled by the `mailType` property.

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

A `Office365Mail` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| mailType | Text |  |
| userId | Text |  |

## Mails

### .append()

**.append**( *$inMail* : Variant { ; *$inFolderId* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMail | Variant | -> | Mail to save; type must match `mailType` |
| $inFolderId | Text | -> | Target folder ID; uses `me/messages` (draft) when empty |
| Result | Object | <- | Status object; includes `id` of the saved message |

#### Description

Saves a message to a mail folder without sending it via
`POST /me/mailFolders/{id}/messages` (or `/users/{id}/...`)

### .copy()

**.copy**( *$inMailId* : Text ; *$inFolderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | ID of the message to copy |
| $inFolderId | Text | -> | Destination folder ID |
| Result | Object | <- | Status object; includes `id` of the new copy |

#### Description

Copies a message to another folder via
`POST /me/messages/{id}/copy`

### .delete()

**.delete**( *$inMailId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | ID of the message to delete permanently |
| Result | Object | <- | Status object |

#### Description

Permanently deletes a message via `DELETE /me/messages/{id}`

### .getMail()

**.getMail**( *$inMailId* : Text { ; *$inOptions* : Object } ) : Variant

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | ID of the message to retrieve |
| $inOptions | Object | -> | Optional overrides: - `mailType` {Text} — `"Microsoft"` (Graph object), `"JMAP"` (converted via `MAIL Convert from MIME`), or `"MIME"` (raw MIME text) - `contentType` {Text} — `"text"` or `"html"` (sets `Prefer: outlook.body-content-type`) |
| Result | Variant | <- | `GraphMessage` object, JMAP Object, or MIME Text depending on `mailType`; `Null` on error or when not found |

#### Description

Fetches a single message via `GET /me/messages/{id}` (or `/$value` for MIME)

### .getMails()

**.getMails**( *$inParameters* : Object ) : [cs.NetKit.GraphMessageList](./GraphMessageList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options: - `folderId` {Text} — Folder ID to filter by - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`) - `filter`, `select`, `top`, `orderBy`, `skip` — standard OData parameters |
| Result | [cs.NetKit.GraphMessageList](./GraphMessageList.md) | <- | Pageable list of messages |

#### Description

Lists messages via `GET /me/messages` (or `/mailFolders/{id}/messages`)

### .move()

**.move**( *$inMailId* : Text ; *$inFolderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | ID of the message to move |
| $inFolderId | Text | -> | Destination folder ID |
| Result | Object | <- | Status object; includes `id` of the moved message |

#### Description

Moves a message to another folder via
`POST /me/messages/{id}/move`

### .reply()

**.reply**( *$inMail* : Object ; *$inMailId* : Text ; *$bReplyAll* : Boolean ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMail | Object | -> | Reply body; for MIME/JMAP types, uses `$inMail.message` |
| $inMailId | Text | -> | ID of the message to reply to |
| $bReplyAll | Boolean | -> | When `True`, uses `replyAll`; otherwise uses `reply` |
| Result | Object | <- | Status object |

#### Description

Replies to a message via
`POST /me/messages/{id}/reply` or `/replyAll`

### .send()

**.send**( *$inMail* : Variant ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMail | Variant | -> | Mail to send; type must match `mailType` |
| Result | Object | <- | Status object |

#### Description

Sends a mail message via `POST /me/sendMail`

### .update()

**.update**( *$inMailId* : Text ; *$inMail* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | ID of the message to update |
| $inMail | Object | -> | Partial message object with properties to update |
| Result | Object | <- | Status object |

#### Description

Updates message properties via `PATCH /me/messages/{id}`

## Folders

### .createFolder()

**.createFolder**( *$inFolderName* : Text ; *$bIsHidden* : Boolean { ; *$inParentFolderId* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inFolderName | Text | -> | Display name for the new folder |
| $bIsHidden | Boolean | -> | When `True`, the folder is hidden |
| $inParentFolderId | Text | -> | Parent folder ID; creates a top-level folder when empty |
| Result | Object | <- | Status object; includes `id` of the created folder |

#### Description

Creates a mail folder via `POST /me/mailFolders` (or `/childFolders`)

### .deleteFolder()

**.deleteFolder**( *$inFolderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inFolderId | Text | -> | ID of the folder to delete |
| Result | Object | <- | Status object |

#### Description

Permanently deletes a mail folder via `DELETE /me/mailFolders/{id}`

### .getFolder()

**.getFolder**( *$inFolderId* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inFolderId | Text | -> | ID of the folder to retrieve |
| Result | Object | <- | Cleaned folder object, or `Null` on error |

#### Description

Fetches a single mail folder via `GET /me/mailFolders/{id}`

### .getFolderList()

**.getFolderList**( *$inParameters* : Object ) : [cs.NetKit.GraphFolderList](./GraphFolderList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options: - `folderId` {Text} — Parent folder ID to list child folders - `search`, `filter`, `select`, `top`, `orderBy` — standard OData parameters |
| Result | [cs.NetKit.GraphFolderList](./GraphFolderList.md) | <- | Pageable list of mail folders |

#### Description

Lists mail folders via `GET /me/mailFolders`
(or `/mailFolders/{id}/childFolders`)

### .renameFolder()

**.renameFolder**( *$inFolderId* : Text ; *$inNewFolderName* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inFolderId | Text | -> | ID of the folder to rename |
| $inNewFolderName | Text | -> | New display name for the folder |
| Result | Object | <- | Status object; includes `id` of the renamed folder |

#### Description

Renames a mail folder via `PATCH /me/mailFolders/{id}`

## Notifications

### .notifier()

**.notifier**( *$inParameters* : Object { ; *$inFolderId* : Text } ) : cs.GraphNotification

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Notification callbacks and options: - `onCreate` {4D.Function} — Called when a mail is created; receives the `mailId` - `onDelete` {4D.Function} — Called when a mail is deleted; receives the `mailId` - `onModify` {4D.Function} — Called when a mail is modified; receives the `mailId` - `endPoint` {Text} — Webhook URL for push mode; omit to use pull (delta query) mode |
| $inFolderId | Text | -> | Folder to subscribe to; defaults to `inbox` when empty |
| Result | cs.GraphNotification | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted` |

#### Description

Creates a `GraphNotification` for mail change notifications via the
Microsoft Graph subscription API. See inline comment for full parameter details.

## See also

* [GraphMessage](./GraphMessage.md)
* [GraphMessageList](./GraphMessageList.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365](./Office365.md)
