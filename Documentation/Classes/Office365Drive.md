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
* [.createFolder()](#createfolder)
* [.delete()](#delete)
* [.move()](#move)
* [.rename()](#rename)
* [.copy()](#copy)
* [.search()](#search)
* [.share()](#share)
* [.getShareLink()](#getsharelink)

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

**.getItem**( *param* : Object ) : cs.GraphDriveItem

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Item selector (`itemId` or `path`) and optional `select`. |
| Result | [cs.GraphDriveItem](./GraphDriveItem.md) | <- | Drive item with `.getContent()` method, or `Null` on failure. |

#### Description

`.getItem()` returns a [`GraphDriveItem`](./GraphDriveItem.md) object for a file or folder. Call `.getContent()` on the returned object to download the file bytes.

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

### .createFolder()

**.createFolder**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Folder creation options. |
| Result | Object | <- | [Status object](#status-object) with created folder info. |

#### Description

`.createFolder()` creates a new folder in the drive.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| name | Text | **Required.** Folder name. |
| parentId | Text | Parent folder item ID. Defaults to root. |
| parentPath | Text | Parent folder path relative to root (alternative to `parentId`). |
| conflictBehavior | Text | `fail` (default), `replace`, or `rename`. |

### .delete()

**.delete**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Item selector (`itemId` or `path`). |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.delete()` permanently deletes a file or folder from the drive.

### .move()

**.move**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Move options. |
| Result | Object | <- | [Status object](#status-object) with updated item info. |

#### Description

`.move()` moves a file or folder to a different parent folder.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | Item ID to move (or use `path`). |
| path | Text | Item path to move (alternative to `itemId`). |
| destinationId | Text | **Required.** Destination folder ID. |

### .rename()

**.rename**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Rename options. |
| Result | Object | <- | [Status object](#status-object) with updated item info. |

#### Description

`.rename()` renames a file or folder.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | Item ID to rename (or use `path`). |
| path | Text | Item path to rename (alternative to `itemId`). |
| name | Text | **Required.** New name. |

### .copy()

**.copy**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Copy options. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.copy()` copies a file to a destination folder.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | Item ID to copy (or use `path`). |
| path | Text | Item path to copy (alternative to `itemId`). |
| destinationId | Text | **Required.** Destination folder ID. |
| name | Text | **Required.** New name for the copy (optional for `.copy()`). |

### .search()

**.search**( *param* : Object ) : cs.GraphDriveItemList

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Search options. |
| Result | [cs.GraphDriveItemList](./GraphDriveItemList.md) | <- | Pageable list of matching items. |

#### Description

`.search()` searches for drive items matching a text query.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| query | Text | **Required.** Search text. |
| top | Integer | Max results per page. |
| select | Text \| Collection | OData `$select`. |
| orderBy | Text | OData `$orderby`. |

### .share()

**.share**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Sharing options. |
| Result | Object | <- | [Status object](#status-object) with `link` URL. |

#### Description

`.share()` creates a sharing link for a drive item.

In *param*, pass:

| Property | Type | Description |
|---|---|---|
| itemId | Text | Item ID (or use `path`). |
| path | Text | Item path (alternative to `itemId`). |
| type | Text | Link type: `view` (default) or `edit`. |
| scope | Text | Link scope: `anonymous` (default) or `organization`. |
| password | Text | Optional link password. |
| expirationDateTime | Text | Optional expiration (ISO 8601). |

The returned status object includes:

| Property | Type | Description |
|---|---|---|
| link | Text | The sharing URL. |
| type | Text | Link type. |
| scope | Text | Link scope. |

### .getShareLink()

**.getShareLink**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Item selector (`itemId` or `path`). |
| Result | Object | <- | [Status object](#status-object) with `link` URL. |

#### Description

`.getShareLink()` creates an anonymous view link for a drive item. This is a convenience shortcut for `.share({type: "view"; scope: "anonymous"})`.

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