# GraphAttachment Class

## Overview

Represents a Microsoft Graph file attachment on a message or calendar event.
`contentBytes` is fetched lazily via `getContent()` when not already present.
Can be built from a `4D.MailAttachment` via `fromMailAttachment()`.

## Table of Contents

### Functions

* [.fromMailAttachment()](#frommailattachment)
* [.getContent()](#getcontent)
* [.setContent()](#setcontent)

## Properties

A `GraphAttachment` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text |  |
| contentBytes | Text |  |
| size | Integer |  |
| contentId | Text |  |
| isInline | Boolean |  |
| name | Text |  |
| contentType | Text |  |

## Functions

### .fromMailAttachment()

**.fromMailAttachment**( *$inObject* : 4D.MailAttachment )

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inObject | 4D.MailAttachment | -> | 4D mail attachment to convert |

#### Description

Populates `This` from a `4D.MailAttachment`; sets `@odata.type`,
`contentId`, `isInline`, `name`, `contentType`, and `contentBytes`.
No-op when `$inObject` is not a `4D.MailAttachment` instance.

### .getContent()

**.getContent**() : 4D.Blob

#### Description

Downloads attachment bytes via
`GET /me/messages/{id}/attachments/{attachmentId}` or
`GET /me/events/{id}/attachments/{attachmentId}`

### .setContent()

**.setContent**( *$inContent* : 4D.Blob )

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inContent | 4D.Blob | -> | Binary content to attach |

#### Description

Base64-encodes `$inContent` and stores it in `contentBytes`;
also updates `size`. No-op when the blob is empty.

## See also

* [GraphEvent](./GraphEvent.md)
* [GraphMessage](./GraphMessage.md)
