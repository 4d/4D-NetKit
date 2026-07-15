# GoogleDrive Class

## Overview

`GoogleDrive` is the Google Drive API client for file operations in 4D NetKit.

A `GoogleDrive` object is accessed via the `drive` property of a [Google](./Google.md) object: `$google.drive`.

This class provides basic operations:

* list files
* get file metadata
* download a file
* upload a file

## Table of Contents

### Functions

* [.list()](#list)
* [.getItem()](#getitem)
* [.getFile()](#getfile)
* [.uploadFile()](#uploadfile)
* [.createFolder()](#createfolder)
* [.delete()](#delete)
* [.move()](#move)
* [.rename()](#rename)
* [.copy()](#copy)

## Properties

A `GoogleDrive` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text | Reserved for compatibility with other Google clients. |

## Functions

### .list()

**.list**( { *param* : Object } ) : [cs.NetKit.GoogleDriveFileList](./GoogleDriveFileList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Options to filter, page, and sort files (optional). |
| Result | [cs.NetKit.GoogleDriveFileList](./GoogleDriveFileList.md) | <- | Paginated list of files. Use `next()` / `previous()` to navigate pages. |

#### Description

`.list()` retrieves files from Google Drive.

In *param*, you can pass:

| Property | Type | Description |
|---|---|---|
| search | Text | Drive query string (`q`). |
| top | Integer | Maximum number of files per page (`pageSize`). |
| orderBy | Text | Sort expression (for example: `modifiedTime desc`). |
| spaces | Text | Spaces to query (for example: `drive`). |
| fields | Text | Response projection. |
| pageToken | Text | Token for the next page. |
| supportsAllDrives | Boolean | Enables shared-drive support. |
| includeItemsFromAllDrives | Boolean | Includes items from all drives. |

### .getItem()

**.getItem**( *param* : Object ) : cs.GoogleDriveItem

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | File selector (`itemId`) and optional options. |
| Result | [cs.GoogleDriveItem](./GoogleDriveItem.md) | <- | Drive file item with `.getContent()` method, or `Null` on failure. |

#### Description

`.getItem()` returns a [`GoogleDriveItem`](./GoogleDriveItem.md) object for a Google Drive file. Call `.getContent()` on the returned object to download the file bytes.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | **Required.** Google Drive file ID. |
| fields | Text | Response projection. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

### .getFile()

**.getFile**( *param* : Object ) : 4D.Blob

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | File selector (`itemId`) and optional options. |
| Result | 4D.Blob | <- | Downloaded file content. |

#### Description

`.getFile()` downloads a Google Drive file content.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | **Required.** Google Drive file ID. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

### .uploadFile()

**.uploadFile**( *param* : Object ; *content* : Variant ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Upload options. |
| content | Variant | -> | File content (`Text`, native `Blob`, or `4D.Blob`). |
| Result | Object | <- | [Status object](#status-object) with uploaded file information when available. |

#### Description

`.uploadFile()` uploads file content to Google Drive.

Behavior:

* if `fileId` is provided, updates the existing file content
* otherwise, creates a new file metadata resource then uploads content

In *param*, you can pass:

| Property | Type | Description |
|---|---|---|
| fileId | Text | Existing file ID to update. |
| name | Text | File name (required when creating). |
| mimeType | Text | MIME type of the file. |
| parents | Collection | Parent folder IDs. |
| folderId | Text | Parent folder ID shortcut. |
| fields | Text | Response projection. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

#### Returned object

The method returns a [status object](#status-object) with optional additional properties:

| Property | Type | Description |
|---|---|---|
| id | Text | Uploaded file ID. |
| name | Text | Uploaded file name. |
| mimeType | Text | Uploaded file MIME type. |
| webViewLink | Text | Browser URL of the file. |
| size | Integer | File size in bytes. |

#### Example

```4d
// Create and upload
$status:=$google.drive.uploadFile({name: "notes.txt"; mimeType: "text/plain"}; "Hello from NetKit")

// Update existing file content
$status:=$google.drive.uploadFile({fileId: $fileId; mimeType: "application/pdf"}; $pdfBlob)
```

### .createFolder()

**.createFolder**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Folder creation options. |
| Result | Object | <- | [Status object](#status-object) with created folder info. |

#### Description

`.createFolder()` creates a new folder in Google Drive.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| name | Text | **Required.** Folder name. |
| parents | Collection | Parent folder IDs (defaults to root). |
| folderId | Text | Single parent folder ID (shortcut when `parents` is omitted). |
| fields | Text | Response projection. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

### .delete()

**.delete**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Item selector. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.delete()` permanently deletes a file or folder from Google Drive.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | **Required.** File/folder ID to delete. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

### .move()

**.move**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Move options. |
| Result | Object | <- | [Status object](#status-object) with updated file info. |

#### Description

`.move()` moves a file or folder to a different parent folder. The item is removed from its current parent(s) and added to the destination.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | **Required.** File/folder ID to move. |
| destinationId | Text | **Required.** Destination parent folder ID. |
| fields | Text | Response projection. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

### .rename()

**.rename**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Rename options. |
| Result | Object | <- | [Status object](#status-object) with updated file info. |

#### Description

`.rename()` renames a file or folder.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | **Required.** File/folder ID to rename. |
| name | Text | **Required.** New name. |
| fields | Text | Response projection. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

### .copy()

**.copy**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Copy options. |
| Result | Object | <- | [Status object](#status-object) with copied file info. |

#### Description

`.copy()` copies a file to a destination folder.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | **Required.** File ID to copy. |
| name | Text | Name for the copy (optional; keeps original if omitted). |
| destinationId | Text | Destination parent folder ID (optional; same folder if omitted). |
| fields | Text | Response projection. |
| supportsAllDrives | Boolean | Enables shared-drive support. |

> **Note:** Google Drive does not support copying folders, only files.

## Status object

| Property | Type | Description |
|---|---|---|
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Google server or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |

## Permissions

Typical Google Drive scopes:

| Scope | Description |
|---|---|
| `https://www.googleapis.com/auth/drive.readonly` | Read files and metadata. |
| `https://www.googleapis.com/auth/drive.file` | Read/write files created or opened by the app. |
| `https://www.googleapis.com/auth/drive` | Full Drive read/write access. |

## See also

* [GoogleDriveFileList](./GoogleDriveFileList.md)
* [Google](./Google.md)