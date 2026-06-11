# GoogleMail Class

## Overview

Gmail API client; provides send, append, read, delete, label management,
and change-notification operations. Supports both JMAP (4D mail object) and MIME
(raw RFC 2822) output formats, controlled by the `mailType` property.

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
| mailType | Text |  |
| userId | Text |  |

## Mails

### .append()

**.append**( *$inMail* : Variant { ; *$inLabelIds* : Collection } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMail | Variant | -> | Mail to store; BLOB or Text (MIME) when `mailType` is `"MIME"`, Object (JMAP) when `mailType` is `"JMAP"` |
| $inLabelIds | Collection | -> | Label IDs to apply; defaults to `["DRAFT"]` when omitted or empty |
| Result | Object | <- | Status object `{success; statusText; ?id}` where `id` is the Gmail message ID of the stored message on success |

#### Description

Stores a mail message without sending it via
`POST users/{userId}/messages/`; useful for importing existing messages or saving
drafts with custom labels

### .delete()

**.delete**( { *$inMailId* : Text ; *$permanently* : Boolean } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | Gmail message ID to delete; pushes error 10 when not a Text, error 9 when empty |
| $permanently | Boolean | -> | When True, permanently deletes the message via `DELETE`; when False (default), moves it to Trash via `POST .../trash` |
| Result | Object | <- | Status object `{success; statusText}` |

#### Description

Deletes a mail message, either permanently or by trashing it

### .getMail()

**.getMail**( { *$inMailId* : Text ; *$inParameters* : Object } ) : Variant

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | Gmail message ID to fetch; pushes error 10 when not a Text, error 9 when empty |
| $inParameters | Object | -> | Options; recognised properties: - `mailType` {Text} — Override instance `mailType` for this call - `format` {Text} — Gmail response format: `"raw"` (default), `"minimal"`, or `"metadata"` |
| Result | Variant | <- | JMAP object (4D mail), BLOB, or Text depending on `mailType` and `format`; `Null` on error or when required parameters are missing |

#### Description

Fetches a single message via `GET users/{userId}/messages/{id}` and
converts the response via `_extractRawMessage`

### .getMailIds()

**.getMailIds**( *$inParameters* : Object ) : [cs.NetKit.GoogleMailIdList](./GoogleMailIdList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options forwarded to `_getURLParamsFromObject`; see the Gmail `users.messages.list` API for supported parameters (e.g. `q`, `labelIds`, `maxResults`, `pageToken`) |
| Result | [cs.NetKit.GoogleMailIdList](./GoogleMailIdList.md) | <- | Paginated list of Gmail message IDs; use `next()` / `previous()` to navigate pages |

#### Description

Returns a `GoogleMailIdList` for the first page of matching messages

### .getMails()

**.getMails**( { *$inMailIds* : Collection ; *$inParameters* : Object } ) : Collection

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailIds | Collection | -> | Collection of Gmail message IDs (Text) or objects with an `id` property; pushes error 10 when not a Collection, error 9 when empty |
| $inParameters | Object | -> | Options forwarded to `getMail` or the batch request; same properties as `getMail.$inParameters` |
| Result | Collection | <- | Collection of mail items (JMAP objects, BLOBs, or Texts); `Null` on error |

#### Description

Fetches multiple messages: uses a single `getMail` call for one ID,
or a `_GoogleBatchRequest` for multiple IDs to reduce round-trips

### .send()

**.send**( *$inMail* : Variant ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMail | Variant | -> | Mail to send; BLOB or Text (MIME) when `mailType` is `"MIME"`, Object (JMAP) when `mailType` is `"JMAP"` |
| Result | Object | <- | Status object `{success; statusText}` |

#### Description

Sends a mail message via `POST users/{userId}/messages/send`

### .untrash()

**.untrash**( { *$inMailId* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailId | Text | -> | Gmail message ID to restore; pushes error 10 when not a Text, error 9 when empty |
| Result | Object | <- | Status object `{success; statusText}` |

#### Description

Removes a message from Trash via `POST users/{userId}/messages/{id}/untrash`

### .update()

**.update**( { *$inMailIds* : Collection ; *$inParameters* : Object } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMailIds | Collection | -> | Collection of Gmail message IDs (Text) or objects with an `id` property; pushes error 10 when not a Collection, error 9 when empty, error 13 when more than 1000 IDs are supplied |
| $inParameters | Object | -> | Modification options; recognised properties: - `addLabelIds` {Collection} — Label IDs to add to the messages - `removeLabelIds` {Collection} — Label IDs to remove from the messages Pushes error 10 when `$inParameters` is not an Object |
| Result | Object | <- | Status object `{success; statusText}` |

#### Description

Batch-modifies labels on up to 1000 messages via
`POST users/{userId}/messages/batchModify`

## Labels

### .createLabel()

**.createLabel**( { *$inLabelInfo* : Object } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inLabelInfo | Object | -> | Label properties to create (e.g. `name`, `messageListVisibility`, `labelListVisibility`); pushes error 10 when not an Object, error 9 when empty |
| Result | Object | <- | Status object `{success; statusText; ?label}` where `label` is the created label resource on success |

#### Description

Creates a new label via `POST users/{userId}/labels`

### .deleteLabel()

**.deleteLabel**( { *$inLabelId* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inLabelId | Text | -> | Gmail label ID to delete; pushes error 10 when not a Text, error 9 when empty |
| Result | Object | <- | Status object `{success; statusText}` |

#### Description

Permanently deletes a label via `DELETE users/{userId}/labels/{labelId}`

### .getLabel()

**.getLabel**( { *$inLabelId* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inLabelId | Text | -> | Gmail label ID to fetch; pushes error 10 when not a Text, error 9 when empty |
| Result | Object | <- | Label resource object from the Gmail API, or `Null` when validation fails |

#### Description

Fetches a single label's details via `GET users/{userId}/labels/{labelId}`

### .getLabelList()

**.getLabelList**( { *$inParameters* : Object } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Options; recognised properties: - `ids` {Collection} — Specific label IDs to fetch (Text or objects with `id`); when omitted, fetches all labels via `GET users/{userId}/labels` - `withCounters` {Boolean} — When True, includes `threadsTotal`, `threadsUnread`, `messagesTotal`, and `messagesUnread` in each label (requires individual `GET users/{userId}/labels/{id}` requests via batch) |
| Result | Object | <- | Status object `{success; statusText; ?labels}` where `labels` is an array of label objects |

#### Description

Retrieves one or more labels; when `ids` are provided or `withCounters`
is True, individual label details are fetched via a `_GoogleBatchRequest`

### .updateLabel()

**.updateLabel**( { *$inLabelId* : Text ; *$inLabelInfo* : Object } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inLabelId | Text | -> | Gmail label ID to update; pushes error 10 when not a Text, error 9 when empty |
| $inLabelInfo | Object | -> | Updated label properties; pushes error 10 when not an Object, error 9 when empty |
| Result | Object | <- | Status object `{success; statusText; ?label}` where `label` is the updated label resource on success |

#### Description

Fully replaces a label's properties via `PUT users/{userId}/labels/{labelId}`

## Notifications

### .notifier()

**.notifier**( { *$inParameters* : Object } ) : cs.GoogleNotification

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Notification options (see inline documentation): `onCreate`, `onDelete`, `onModify` callbacks; optional `topicName` (Pub/Sub topic for push mode); optional `labelIds` filter; optional `timer` (seconds) for pull mode |
| Result | cs.GoogleNotification | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted`; call `start()` to begin monitoring |

#### Description

Factory that creates a `GoogleNotification` for Gmail change monitoring.
Push mode requires a Google Cloud Pub/Sub topic (`topicName`); pull mode polls
the Gmail history API at a configurable interval.

## See also

* [GoogleMailIdList](./GoogleMailIdList.md)
* [GoogleNotification](./GoogleNotification.md)
* [Google](./Google.md)
