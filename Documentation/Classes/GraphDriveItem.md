# GraphDriveItem Class

## Overview

`GraphDriveItem` represents a Microsoft Graph Drive item (file or folder) returned by [`Office365Drive.getItem()`](./Office365Drive.md#getitem). It exposes item metadata and provides lazy download of the binary content via `.getContent()`.

## Table of Contents

### Functions

* [.getContent()](#getcontent)
* [.getThumbnail()](#getthumbnail)

## Properties

A `GraphDriveItem` object exposes all properties returned by the Microsoft Graph API for a [driveItem](https://learn.microsoft.com/en-us/graph/api/resources/driveitem) resource. The most common ones are:

| Property | Type | Description |
|---|---|---|
| id | Text | The unique identifier of the item within the Drive. |
| name | Text | The name of the item (filename and extension). |
| size | Integer | Size of the item in bytes. |
| webUrl | Text | URL that displays the resource in the browser. |
| createdDateTime | Text | Date and time of item creation (ISO 8601). |
| lastModifiedDateTime | Text | Date and time the item was last modified (ISO 8601). |
| file | Object | File metadata (present only for files, not folders). Includes `mimeType` and `hashes`. |
| folder | Object | Folder metadata (present only for folders). Includes `childCount`. |
| parentReference | Object | Parent folder reference containing `driveId`, `id`, and `path`. |

> Additional properties may be present depending on the `select` parameter used when calling `getItem()`.

## Functions

### .getContent()

**.getContent**() : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | 4D.Blob | <- | The file binary content; empty blob on error or for folders. |

#### Description

`.getContent()` downloads the file binary content via the Microsoft Graph API (`GET /drive/items/{id}/content`). The request is authenticated using the OAuth2 provider supplied when the item was created.

Returns an empty `4D.Blob` if:
- the item has no `id`,
- the item is a **folder** (the `folder` property is present in metadata),
- or if the download fails.

#### Example

```4d
var $office : cs.NetKit.Office365
var $item : cs.NetKit.GraphDriveItem

$office:=cs.NetKit.Office365.new($oAuth2)

// Get item metadata
$item:=$office.drive.getItem({path: "Documents/report.pdf"})

If ($item#Null)
    // Download file content
    var $content : 4D.Blob:=$item.getContent()

    // Save to disk
    var $file : 4D.File:=File("/PACKAGE/report.pdf")
    $file.setContent($content)
End if
```

### .getThumbnail()

**.getThumbnail**( *size* : Text ) : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| size | Text | -> | Thumbnail size: `"small"`, `"medium"` (default), or `"large"`. |
| Result | 4D.Blob | <- | Thumbnail image content; empty blob for folders or on error. |

#### Description

`.getThumbnail()` downloads a thumbnail image for the drive item via `GET /drive/items/{id}/thumbnails/0/{size}/content`.

Returns an empty `4D.Blob` if the item is a folder or has no `id`.

#### Example

```4d
var $item : cs.NetKit.GraphDriveItem:=$office.drive.getItem({path: "photo.jpg"})
var $thumb : 4D.Blob:=$item.getThumbnail("large")
File("/PACKAGE/thumb.jpg").setContent($thumb)
```

## See also
* [GraphDriveItemList](./GraphDriveItemList.md)
* [Office365](./Office365.md)
