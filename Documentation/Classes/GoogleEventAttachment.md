# GoogleEventAttachment Class

## Overview

`GoogleEventAttachment` represents a file attachment on a Google Calendar event. It exposes metadata from the API response and provides lazy, cached download of the attachment binary via `.getContent()`.

Attachments are accessed via the `attachments` property of a [GoogleEvent](./GoogleEvent.md) object. To include attachments when creating or updating an event, set `supportsAttachments: true` in the request parameter.

## Table of Contents

### Functions

* [.getContent()](#getcontent)
* [.getIcon()](#geticon)

## Properties

A `GoogleEventAttachment` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| fileUrl | Text | URL to the attachment file. |
| title | Text | Display name of the attachment. |
| mimeType | Text | MIME type of the attachment. |
| iconLink | Text | URL to the attachment's icon image. |
| contentBytes | 4D.Blob | Cached binary content of the attachment (populated after `.getContent()` is called). |

## Functions

### .getContent()

**.getContent**() : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | 4D.Blob | <- | The attachment binary; `Null` if the download fails. |

#### Description

`.getContent()` downloads the attachment from `fileUrl` on first call and caches the result in `contentBytes`. Subsequent calls return the cached blob without making a new HTTP request.

### .getIcon()

**.getIcon**() : Picture

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Picture | <- | The attachment icon as a 4D Picture; `Null` if the download fails. |

#### Description

`.getIcon()` downloads the icon image from `iconLink` and converts the blob to a 4D Picture. The result is not cached — a new HTTP request is made on each call.

## See also

* [GoogleEvent](./GoogleEvent.md)
* [GoogleCalendar](./GoogleCalendar.md)
