# Office365Drive Class

## Overview

`Office365Drive` is the Microsoft Graph API client for OneDrive and SharePoint Drive operations within 4D NetKit.

An `Office365Drive` object is accessed via the `drive` property of an [Office365](./Office365.md) object: `$office365.drive`.

This class provides file operations:

* list files and folders
* get file/folder metadata
* download a file
* upload a file (including large files with upload session)

## Table of Contents

### Functions

* [.list()](#list)
* [.getItem()](#getitem)
* [.getFile()](#getfile)
* [.uploadFile()](#uploadfile)
* [.uploadLargeFile()](#uploadlargefile)

## Properties

An `Office365Drive` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text | User identifier used in Service mode. Can be the `id` or the `userPrincipalName`. |
| driveId | Text | Optional drive identifier. If omitted, the default drive is used. |

## Functions

### .list()

**.list**( { *param* : Object } ) : [cs.NetKit.GraphDriveItemList](./GraphDriveItemList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Options defining which folder to list and query options (optional). |
| Result | [cs.NetKit.GraphDriveItemList](./GraphDriveItemList.md) | <- | Paginated list of drive items. Use `next()` / `previous()` to navigate pages. |

#### Description

`.list()` lists the children of the drive root, or of a specific folder selected by `itemId` or `path`.

### .getItem()

**.getItem**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Item selector (`itemId` or `path`) and optional `select`. |
| Result | Object | <- | Drive item metadata object, or `Null` on failure. |

#### Description

`.getItem()` returns metadata for a file or folder.

### .getFile()

**.getFile**( *param* : Object ) : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Item selector (`itemId` or `path`). |
| Result | 4D.Blob | <- | Downloaded file content as a `4D.Blob`. |

#### Description

`.getFile()` downloads a file from Microsoft Graph Drive.

### .uploadFile()

**.uploadFile**( *param* : Object ; *content* : Variant ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Destination and behavior options. |
| content | Variant | -> | File content (`Text`, native `Blob`, or `4D.Blob`). |
| Result | Object | <- | [Status object](#status-object) with uploaded item information when available. |

#### Description

`.uploadFile()` uploads file content to Microsoft Graph Drive.

The function chooses the upload mode automatically:

* simple upload (`PUT .../content`) for smaller files
* upload session (chunked) for large files

In *param*, you can pass:

| Property | Type | Description |
|---|---|---|
| path | Text | Destination path including filename (for example: `Documents/report.pdf`). |
| fileName | Text | Filename to upload (used when `path` is not provided). |
| folderId | Text | Parent folder item ID. |
| folderPath | Text | Parent folder path relative to root. |
| conflictBehavior | Text | Conflict policy: `replace` (default), `rename`, or `fail`. |
| useUploadSession | Boolean | Forces upload session mode even for small files. |
| uploadSessionThreshold | Integer | Size threshold in bytes for automatic upload session mode. Default: `4194304` (4 MiB). |
| chunkSize | Integer | Chunk size in bytes for upload session. Should be a multiple of `327680` (320 KiB). Default: `1638400`. |

#### Returned object

The method returns a [status object](#status-object) with optional additional properties when returned by Graph:

| Property | Type | Description |
|---|---|---|
| id | Text | Uploaded drive item ID. |
| name | Text | Uploaded item name. |
| webUrl | Text | Browser URL of the uploaded item. |
| size | Integer | Uploaded item size in bytes. |

#### Example

```4d
// Automatic mode (simple or upload session depending on size)
$status:=$office365.drive.uploadFile({path: "Documents/big-report.zip"}; $blob)

// Force upload session for resilient large upload
$status:=$office365.drive.uploadFile({path: "Documents/video.mp4"; useUploadSession: True; chunkSize: 3276800}; $videoBlob)
```

### .uploadLargeFile()

**.uploadLargeFile**( *param* : Object ; *content* : Variant ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Destination and behavior options. |
| content | Variant | -> | File content (`Text`, native `Blob`, or `4D.Blob`). |
| Result | Object | <- | [Status object](#status-object) with uploaded item information when available. |

#### Description

`.uploadLargeFile()` uploads file content using Microsoft Graph upload session mode only (chunked upload).

In *param*, you can pass:

| Property | Type | Description |
|---|---|---|
| path | Text | Destination path including filename (for example: `Documents/video.mp4`). |
| fileName | Text | Filename to upload (used when `path` is not provided). |
| folderId | Text | Parent folder item ID. |
| folderPath | Text | Parent folder path relative to root. |
| conflictBehavior | Text | Conflict policy: `replace` (default), `rename`, or `fail`. |
| chunkSize | Integer | Chunk size in bytes. Should be a multiple of `327680` (320 KiB). Default: `1638400`. |

#### Example

```4d
$status:=$office365.drive.uploadLargeFile({path: "Documents/very-large-video.mp4"; chunkSize: 3276800}; $videoBlob)
If (Not($status.success))
	ALERT($status.statusText)
End if
```

## Status object

| Property | Type | Description |
|---|---|---|
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |

## Permissions

Typical Microsoft Graph permissions for Drive operations are:

| Type | Permission |
|---|---|
| Delegated (Work/School) | `Files.Read`, `Files.ReadWrite` |
| Delegated (Personal) | `Files.Read`, `Files.ReadWrite` |
| Application | `Files.Read.All`, `Files.ReadWrite.All` |

## See also

* [GraphDriveItemList](./GraphDriveItemList.md)
* [Office365](./Office365.md)