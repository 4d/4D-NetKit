# GraphAttachment Class

## Overview

Represents a Microsoft Graph file attachment on a message or calendar event.
`contentBytes` is fetched lazily via `getContent()` when not already present.
Can be built from a `4D.MailAttachment` via `fromMailAttachment()`.

## Table of Contents

### Initialization

* [cs.NetKit.GraphAttachment.new()](#csnetkitgraphattachmentnew)

### Functions

* [GraphAttachment.getContent()](#graphattachmentgetcontent)
* [GraphAttachment.setContent()](#graphattachmentsetcontent)
* [GraphAttachment.fromMailAttachment()](#graphattachmentfrommailattachment)

## **cs.NetKit.GraphAttachment.new()**

**cs.NetKit.GraphAttachment.new**( *$inProvider* : cs.OAuth2Provider ; *$inParams* : Object ; *$inObject* : Object ) : cs.NetKit.GraphAttachment

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inParams | Object | -> | Context: - `userId` {Text} — Graph user ID or UPN - `messageId` {Text} — Parent message ID (exclusive with `eventId`) - `eventId` {Text} — Parent event ID (exclusive with `messageId`) |
| $inObject | Object | -> | Raw Graph API attachment object to hydrate from |
| Result | cs.NetKit.GraphAttachment | <- | Object of the GraphAttachment class |

### Properties

The returned `GraphAttachment` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text |  |
| contentBytes | Text |  |
| size | Integer |  |
| contentId | Text |  |
| isInline | Boolean |  |
| name | Text |  |
| contentType | Text |  |

### GraphAttachment.getContent()

**GraphAttachment.getContent**() : 4D.Blob

#### Description

Downloads attachment bytes via
`GET /me/messages/{id}/attachments/{attachmentId}` or
`GET /me/events/{id}/attachments/{attachmentId}`

### GraphAttachment.setContent()

**GraphAttachment.setContent**( *$inContent* : 4D.Blob )

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inContent | 4D.Blob | -> | Binary content to attach |

#### Description

Base64-encodes `$inContent` and stores it in `contentBytes`;
also updates `size`. No-op when the blob is empty.

### GraphAttachment.fromMailAttachment()

**GraphAttachment.fromMailAttachment**( *$inObject* : 4D.MailAttachment )

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inObject | 4D.MailAttachment | -> | 4D mail attachment to convert |

#### Description

Populates `This` from a `4D.MailAttachment`; sets `@odata.type`,
`contentId`, `isInline`, `name`, `contentType`, and `contentBytes`.
No-op when `$inObject` is not a `4D.MailAttachment` instance.


## See also

* [GraphEvent](./GraphEvent.md)
* [GraphMessage](./GraphMessage.md)
