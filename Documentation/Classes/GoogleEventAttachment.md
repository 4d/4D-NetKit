# GoogleEventAttachment Class

## Overview

Represents a file attachment on a Google Calendar event.
Exposes metadata from the API response and provides lazy, cached download
of the attachment binary via `getContent()`.

## Table of Contents

### Functions

* [.getContent()](#getcontent)
* [.getIcon()](#geticon)

## Properties

A `GoogleEventAttachment` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| fileUrl | Text |  |
| title | Text |  |
| mimeType | Text |  |
| iconLink | Text |  |
| contentBytes | 4D.Blob |  |

## Functions

### .getContent()

**.getContent**() : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | 4D.Blob | <- | The attachment binary; `Null` if the download fails |

#### Description

Downloads the attachment from `fileUrl` on first call and caches the
result in `contentBytes`; subsequent calls return the cached blob without
making a new HTTP request

### .getIcon()

**.getIcon**() : Picture

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Picture | <- | The attachment icon as a 4D Picture; `Null` if the download fails |

#### Description

Downloads the icon image from `iconLink` and converts the blob to a
4D Picture via `BLOB TO PICTURE`; not cached — a new HTTP request is made on each call

## See also

* [GoogleEvent](./GoogleEvent.md)
