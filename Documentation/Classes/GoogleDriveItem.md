# GoogleDriveItem Class

## Overview

`GoogleDriveItem` represents a Google Drive file item returned by [`GoogleDrive.getItem()`](./GoogleDrive.md#getitem). It exposes file metadata and provides lazy download of the binary content via `.getContent()`.

## Table of Contents

### Functions

* [.getContent()](#getcontent)
* [.getThumbnail()](#getthumbnail)

## Properties

A `GoogleDriveItem` object exposes all properties returned by the Google Drive API for a [File](https://developers.google.com/drive/api/reference/rest/v3/files) resource. The most common ones are:

| Property | Type | Description |
|---|---|---|
| id | Text | The unique identifier of the file. |
| name | Text | The name of the file. |
| mimeType | Text | The MIME type of the file (e.g. `image/jpeg`, `application/pdf`). |
| size | Integer | Size of the file in bytes (not present for Google Docs formats). |
| modifiedTime | Text | The last time the file was modified (RFC 3339). |
| webViewLink | Text | A link for opening the file in a relevant Google editor or viewer in a browser. |
| parents | Collection | Collection of parent folder IDs. |

> Additional properties may be present depending on the `fields` parameter used when calling `getItem()`.

## Functions

### .getContent()

**.getContent**() : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | 4D.Blob | <- | The file binary content; empty blob on error. |

#### Description

`.getContent()` downloads the file binary content via the Google Drive API (`GET /drive/v3/files/{id}?alt=media`). The request is authenticated using the OAuth2 provider supplied when the item was created.

Returns an empty `4D.Blob` without making any network request if:
- the item has no `id`,
- or the item's `mimeType` is a **Google-native format** (`application/vnd.google-apps.*`) — this includes folders, Google Docs, Sheets, Slides, etc.

> **Note:** Google-native formats have no binary content downloadable via `alt=media`. Use the [export endpoint](https://developers.google.com/drive/api/guides/manage-downloads#export-content) instead to convert them to a standard format (PDF, XLSX, etc.).

#### Example

```4d
var $google : cs.NetKit.Google
var $item : cs.NetKit.GoogleDriveItem

$google:=cs.NetKit.Google.new($oAuth2)

// Get item metadata
$item:=$google.drive.getItem({itemId: "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms"})

If ($item#Null)
    // Download file content
    var $content : 4D.Blob:=$item.getContent()

    // Save to disk
    var $file : 4D.File:=File("/PACKAGE/"+$item.name)
    $file.setContent($content)
End if
```

### .getThumbnail()

**.getThumbnail**() : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | 4D.Blob | <- | Thumbnail image content; empty blob for folders or on error. |

#### Description

`.getThumbnail()` downloads the thumbnail image for the drive item. Uses `thumbnailLink` from the item metadata if available; otherwise fetches it first via `GET /drive/v3/files/{id}?fields=thumbnailLink`.

Returns an empty `4D.Blob` if the item is a folder or has no `id`.

> **Note:** `thumbnailLink` is short-lived. If you need to download thumbnails long after fetching metadata, call `.getThumbnail()` which re-fetches the link automatically.

#### Example

```4d
var $item : cs.NetKit.GoogleDriveItem:=$google.drive.getItem({itemId: "abc123"})
var $thumb : 4D.Blob:=$item.getThumbnail()
File("/PACKAGE/thumb.jpg").setContent($thumb)
```

## See also
* [Google](./Google.md)
