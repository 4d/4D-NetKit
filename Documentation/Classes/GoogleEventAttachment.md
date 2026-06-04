# GoogleEventAttachment Class

## Overview

Represents a file attachment on a Google Calendar event.
Exposes metadata from the API response and provides lazy, cached download
of the attachment binary via `getContent()`.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleEventAttachment.new()](#csnetkitgoogleeventattachmentnew)

### Functions

* [GoogleEventAttachment.getContent()](#googleeventattachmentgetcontent)
* [GoogleEventAttachment.getIcon()](#googleeventattachmentgeticon)

## **cs.NetKit.GoogleEventAttachment.new()**

**cs.NetKit.GoogleEventAttachment.new**( *$inAttachment* : Object ) : cs.NetKit.GoogleEventAttachment

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inAttachment | Object | -> | Raw attachment object from the Calendar API event response; expected properties: `fileUrl`, `title`, `mimeType`, `iconLink` |
| Result | cs.NetKit.GoogleEventAttachment | <- | Object of the GoogleEventAttachment class |

### Properties

The returned `GoogleEventAttachment` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| fileUrl | Text |  |
| title | Text |  |
| mimeType | Text |  |
| iconLink | Text |  |
| contentBytes | 4D.Blob |  |

### GoogleEventAttachment.getContent()

**GoogleEventAttachment.getContent**() : 4D.Blob

#### Description

Downloads the attachment from `fileUrl` on first call and caches the
result in `contentBytes`; subsequent calls return the cached blob without
making a new HTTP request

### GoogleEventAttachment.getIcon()

**GoogleEventAttachment.getIcon**() : Picture

#### Description

Downloads the icon image from `iconLink` and converts the blob to a
4D Picture via `BLOB TO PICTURE`; not cached — a new HTTP request is made on each call


## See also

* [GoogleEvent](./GoogleEvent.md)
